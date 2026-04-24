/**
 * controllers/paymentController.js
 * ─────────────────────────────────────────────────────────────
 * Handles Razorpay payment lifecycle:
 *   1. createOrder   — creates a Razorpay order (amount in paise)
 *   2. verifyPayment — verifies HMAC signature from Flutter SDK
 *   3. getStatus     — returns current user's isPaid status
 *
 * All routes are protected (JWT required).
 * verifyPayment sets user.isPaid = true on successful verification.
 *
 * Connects to: routes/payment.js → PaymentService (Flutter)
 * Requires: RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET in .env
 * ─────────────────────────────────────────────────────────────
 */
const crypto = require('crypto');
const Razorpay = require('razorpay');
const User = require('../models/User');

// Lazy-load Razorpay instance
let razorpay;
const getRazorpay = () => {
  if (!razorpay) {
    if (!process.env.RAZORPAY_KEY_ID || !process.env.RAZORPAY_KEY_SECRET) {
      throw new Error('Razorpay credentials not configured in .env');
    }
    razorpay = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID,
      key_secret: process.env.RAZORPAY_KEY_SECRET,
    });
  }
  return razorpay;
};

// Plan configuration — update amount as needed (amount in paise: 99900 = ₹999)
const PLAN = {
  amount: 99900,       // ₹999 in paise
  currency: 'INR',
  name: 'Hyoid Health Plan',
  description: 'Full access to Hyoid healthcare services',
};

// @desc    Create a Razorpay order
// @route   POST /api/payment/create-order
// @access  Private (protect)
exports.createOrder = async (req, res, next) => {
  try {
    const rz = getRazorpay();

    const options = {
      amount: PLAN.amount,
      currency: PLAN.currency,
      receipt: `hyoid_${req.user._id}_${Date.now()}`,
      notes: {
        userId: req.user._id.toString(),
        userEmail: req.user.email || '',
      },
    };

    const order = await rz.orders.create(options);

    res.status(200).json({
      success: true,
      data: {
        orderId: order.id,
        amount: order.amount,
        currency: order.currency,
        keyId: process.env.RAZORPAY_KEY_ID,
        plan: PLAN,
      },
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Verify Razorpay payment signature and mark user as paid
// @route   POST /api/payment/verify
// @access  Private (protect)
exports.verifyPayment = async (req, res, next) => {
  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;

    if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
      return res.status(400).json({
        success: false,
        message: 'razorpay_order_id, razorpay_payment_id and razorpay_signature are required',
        errors: [],
      });
    }

    // Build expected HMAC-SHA256 signature
    const generatedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(`${razorpay_order_id}|${razorpay_payment_id}`)
      .digest('hex');

    if (generatedSignature !== razorpay_signature) {
      return res.status(400).json({
        success: false,
        message: 'Payment verification failed. Invalid signature.',
        errors: [],
      });
    }

    // Mark user as paid in DB
    const user = await User.findByIdAndUpdate(
      req.user._id,
      {
        isPaid: true,
        isNewUser: false,
        paymentId: razorpay_payment_id,
        paymentDate: new Date(),
      },
      { new: true }
    );

    res.status(200).json({
      success: true,
      message: 'Payment verified successfully',
      data: {
        isPaid: user.isPaid,
        paymentId: user.paymentId,
        paymentDate: user.paymentDate,
      },
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get current user payment status
// @route   GET /api/payment/status
// @access  Private (protect)
exports.getStatus = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id).select('isPaid paymentId paymentDate');

    res.status(200).json({
      success: true,
      data: {
        isPaid: user.isPaid,
        requiresPayment: !user.isPaid,
        paymentId: user.paymentId,
        paymentDate: user.paymentDate,
      },
    });
  } catch (err) {
    next(err);
  }
};
