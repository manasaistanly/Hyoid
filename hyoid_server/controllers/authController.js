/**
 * controllers/authController.js
 * ─────────────────────────────────────────────────────────────
 * Handles all authentication flows:
 *   1. Email + Password  : register / login (existing)
 *   2. Google OAuth      : googleSignIn (NEW)
 *   3. Phone OTP         : sendOtp / verifyOtp (NEW)
 *   4. Token refresh     : refreshToken (existing)
 *   5. Profile           : getMe, updateDeviceToken (existing)
 *
 * All methods return JWT accessToken + refreshToken.
 * New/unpaid users also receive requiresPayment: true.
 * ─────────────────────────────────────────────────────────────
 */
const User = require('../models/User');
const OTP = require('../models/OTP');
const jwt = require('jsonwebtoken');
const { verifyGoogleToken } = require('../utils/googleVerify');
const { generateOtp, hashOtp, verifyOtpHash, sendSms } = require('../utils/otpHelper');
const admin = require('../utils/firebaseAdmin'); // Firebase Admin SDK

// ── Helpers ───────────────────────────────────────────────────

const generateToken = (id, secret, expiresIn) => {
  return jwt.sign({ id }, secret, { expiresIn });
};

const generateTokenPair = (userId) => ({
  accessToken: generateToken(userId, process.env.JWT_SECRET, process.env.JWT_EXPIRE),
  refreshToken: generateToken(userId, process.env.JWT_REFRESH_SECRET, process.env.JWT_REFRESH_EXPIRE),
});

const buildAuthResponse = (user, tokens) => ({
  success: true,
  data: {
    _id: user._id,
    name: user.name,
    email: user.email,
    phone: user.phone,
    role: user.role,
    authProvider: user.authProvider,
    isPaid: user.isPaid,
    isNewUser: user.isNewUser,
    requiresPayment: !user.isPaid,
    profileImage: user.profileImage,
    ...tokens,
  },
});

// ── Existing: Register ─────────────────────────────────────────

// @desc    Register user (email/password)
// @route   POST /api/auth/register
// @access  Public
exports.register = async (req, res, next) => {
  try {
    const { name, email, password, phone, age, role } = req.body;

    const user = await User.create({
      name,
      email,
      password,
      phone,
      age,
      role,
      authProvider: 'email',
    });

    res.status(200).json(buildAuthResponse(user, generateTokenPair(user._id)));
  } catch (err) {
    next(err);
  }
};

// ── Existing: Login ────────────────────────────────────────────

// @desc    Login user (email/password)
// @route   POST /api/auth/login
// @access  Public
exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide an email and password',
        errors: [],
      });
    }

    const user = await User.findOne({ email }).select('+password');
    if (!user) {
      return res.status(401).json({ success: false, message: 'Invalid credentials', errors: [] });
    }

    const isMatch = await user.matchPassword(password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid credentials', errors: [] });
    }

    res.status(200).json(buildAuthResponse(user, generateTokenPair(user._id)));
  } catch (err) {
    next(err);
  }
};

// ── New: Google Sign-In ────────────────────────────────────────

// @desc    Authenticate via Google ID token
// @route   POST /api/auth/google
// @access  Public
exports.googleSignIn = async (req, res, next) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json({ success: false, message: 'idToken is required', errors: [] });
    }

    // Verify the token server-side with Google
    const { googleId, email, name, picture } = await verifyGoogleToken(idToken);

    // Look for existing user by googleId or email
    let user = await User.findOne({ $or: [{ googleId }, { email }] });

    if (user) {
      // If existing user was created by email, link googleId
      if (!user.googleId) {
        user.googleId = googleId;
        user.authProvider = 'google';
        if (!user.profileImage || user.profileImage === 'default.jpg') {
          user.profileImage = picture;
        }
        await user.save();
      }
      // Existing user — isNewUser stays as-is (false after first login)
    } else {
      // New user — create record
      user = await User.create({
        name,
        email,
        googleId,
        profileImage: picture,
        authProvider: 'google',
        role: 'patient',
        isNewUser: true,
        isPaid: false,
      });
    }

    res.status(200).json(buildAuthResponse(user, generateTokenPair(user._id)));
  } catch (err) {
    if (err.message && err.message.includes('Invalid Google token')) {
      return res.status(401).json({ success: false, message: 'Invalid Google token', errors: [] });
    }
    next(err);
  }
};

// ── New: Send OTP ──────────────────────────────────────────────

// @desc    Generate and send a 6-digit OTP via SMS
// @route   POST /api/auth/send-otp
// @access  Public
exports.sendOtp = async (req, res, next) => {
  try {
    let { phoneNumber } = req.body;

    if (!phoneNumber) {
      return res.status(400).json({ success: false, message: 'phoneNumber is required', errors: [] });
    }

    // Normalise to E.164 (assume Indian numbers if no country code)
    if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+91' + phoneNumber.replace(/\D/g, '');
    }

    // Rate limit: max 3 OTP requests per phone per 15 minutes
    const fifteenMinsAgo = new Date(Date.now() - 15 * 60 * 1000);
    const recentCount = await OTP.countDocuments({
      phone: phoneNumber,
      createdAt: { $gte: fifteenMinsAgo },
    });

    if (recentCount >= 3) {
      return res.status(429).json({
        success: false,
        message: 'Too many OTP requests. Please wait 15 minutes before trying again.',
        errors: [],
      });
    }

    const otp = generateOtp();
    const otpHash = await hashOtp(otp);
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

    // Upsert: replace any existing OTP for this phone
    await OTP.findOneAndUpdate(
      { phone: phoneNumber },
      { otpHash, expiresAt, attempts: 0, createdAt: new Date() },
      { upsert: true, new: true }
    );

    // Send SMS
    await sendSms(
      phoneNumber,
      `Your Hyoid verification code is: ${otp}. Valid for 5 minutes. Do not share this code.`
    );

    res.status(200).json({
      success: true,
      message: 'OTP sent successfully',
      // In development, return otp for testing (remove in production)
      ...(process.env.NODE_ENV === 'development' && { otp }),
    });
  } catch (err) {
    next(err);
  }
};

// ── New: Verify OTP ────────────────────────────────────────────

// @desc    Verify OTP and authenticate user
// @route   POST /api/auth/verify-otp
// @access  Public
exports.verifyOtp = async (req, res, next) => {
  try {
    let { phoneNumber, otp } = req.body;

    if (!phoneNumber || !otp) {
      return res.status(400).json({
        success: false,
        message: 'phoneNumber and otp are required',
        errors: [],
      });
    }

    // Normalise phone
    if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+91' + phoneNumber.replace(/\D/g, '');
    }

    // Find OTP record
    const otpRecord = await OTP.findOne({ phone: phoneNumber });

    if (!otpRecord) {
      return res.status(400).json({
        success: false,
        message: 'OTP not found or expired. Please request a new OTP.',
        errors: [],
      });
    }

    // Check expiry
    if (otpRecord.expiresAt < new Date()) {
      await OTP.deleteOne({ phone: phoneNumber });
      return res.status(400).json({
        success: false,
        message: 'OTP has expired. Please request a new one.',
        errors: [],
      });
    }

    // Check attempt limit
    if (otpRecord.attempts >= 3) {
      await OTP.deleteOne({ phone: phoneNumber });
      return res.status(400).json({
        success: false,
        message: 'Too many failed attempts. Please request a new OTP.',
        errors: [],
      });
    }

    // Verify hash
    const isValid = await verifyOtpHash(otp, otpRecord.otpHash);

    if (!isValid) {
      // Increment attempts
      otpRecord.attempts += 1;
      await otpRecord.save();

      const attemptsLeft = 3 - otpRecord.attempts;
      return res.status(400).json({
        success: false,
        message: `Invalid OTP. ${attemptsLeft} attempt(s) remaining.`,
        errors: [],
      });
    }

    // OTP verified — delete it (single-use)
    await OTP.deleteOne({ phone: phoneNumber });

    // Find or create user by phone number
    let user = await User.findOne({ phone: phoneNumber });

    if (!user) {
      // New user via phone
      user = await User.create({
        name: 'Hyoid User', // Will be updated in onboarding
        phone: phoneNumber,
        authProvider: 'phone',
        role: 'patient',
        isNewUser: true,
        isPaid: false,
      });
    } else {
      // Existing user — mark as not new if returning
      if (user.isNewUser) {
        // Keep isNewUser as true until payment complete
      }
    }

    res.status(200).json(buildAuthResponse(user, generateTokenPair(user._id)));
  } catch (err) {
    next(err);
  }
};

// ── Existing: Refresh Token ────────────────────────────────────

// @desc    Refresh access token
// @route   POST /api/auth/refresh-token
// @access  Public
exports.refreshToken = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return res.status(401).json({ success: false, message: 'No refresh token provided', errors: [] });
    }

    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    const user = await User.findById(decoded.id);

    if (!user) {
      return res.status(401).json({ success: false, message: 'Invalid refresh token', errors: [] });
    }

    const tokens = generateTokenPair(user._id);

    res.status(200).json({
      success: true,
      data: {
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      },
    });
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid refresh token', errors: [] });
  }
};

// ── Existing: Get Me ───────────────────────────────────────────

// @desc    Get current logged-in user
// @route   GET /api/auth/me
// @access  Private
exports.getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);
    res.status(200).json({
      success: true,
      data: {
        ...user.toObject(),
        requiresPayment: !user.isPaid,
      },
    });
  } catch (err) {
    next(err);
  }
};

// ── Existing: Update Device Token ─────────────────────────────

// @desc    Update Firebase device token
// @route   PUT /api/auth/device-token
// @access  Private
exports.updateDeviceToken = async (req, res, next) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.user.id,
      { deviceToken: req.body.deviceToken },
      { new: true, runValidators: true }
    );
    res.status(200).json({ success: true, data: user });
  } catch (err) {
    next(err);
  }
};

// @desc    Verify Firebase ID Token (Phone Auth)
// @route   POST /api/auth/verify-firebase
// @access  Public
exports.verifyFirebaseToken = async (req, res, next) => {
  try {
    const { firebaseToken } = req.body;

    if (!firebaseToken) {
      return res.status(400).json({ success: false, message: 'firebaseToken is required', errors: [] });
    }

    // Verify token with Firebase Admin SDK
    const decodedToken = await admin.auth().verifyIdToken(firebaseToken);
    const phoneNumber = decodedToken.phone_number;

    if (!phoneNumber) {
      return res.status(400).json({ success: false, message: 'Phone number not found in token', errors: [] });
    }

    // Find or create user by phone number
    let user = await User.findOne({ phone: phoneNumber });

    if (!user) {
      // New user via phone
      user = await User.create({
        name: 'Hyoid User',
        phone: phoneNumber,
        authProvider: 'phone',
        role: 'patient',
        isNewUser: true,
        isPaid: false,
      });
    }

    res.status(200).json(buildAuthResponse(user, generateTokenPair(user._id)));
  } catch (err) {
    console.error('Firebase verify error:', err);
    res.status(401).json({ success: false, message: 'Invalid Firebase token', errors: [] });
  }
};
