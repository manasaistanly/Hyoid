/**
 * routes/auth.js
 * ─────────────────────────────────────────────────────────────
 * Auth routes — mounted at /api/auth in server.js
 *
 * Public routes (no token needed):
 *   POST /api/auth/register       — email/password registration
 *   POST /api/auth/login          — email/password login
 *   POST /api/auth/google         — Google ID token verification (NEW)
 *   POST /api/auth/send-otp       — send SMS OTP (NEW)
 *   POST /api/auth/verify-otp     — verify OTP (NEW)
 *   POST /api/auth/refresh-token  — exchange refresh token for new access token
 *
 * Protected routes (JWT required):
 *   GET  /api/auth/me             — current user profile + requiresPayment flag
 *   PUT  /api/auth/device-token   — update FCM push token
 * ─────────────────────────────────────────────────────────────
 */
const express = require('express');
const {
  register,
  login,
  googleSignIn,
  sendOtp,
  verifyOtp,
  refreshToken,
  getMe,
  updateDeviceToken,
  verifyFirebaseToken,
} = require('../controllers/authController');
const { protect } = require('../middleware/auth');

const router = express.Router();

// Public
router.post('/register', register);
router.post('/login', login);
router.post('/google', googleSignIn);
router.post('/send-otp', sendOtp);
router.post('/verify-otp', verifyOtp);
router.post('/verify-firebase', verifyFirebaseToken);
router.post('/refresh-token', refreshToken);

// Protected
router.get('/me', protect, getMe);
router.put('/device-token', protect, updateDeviceToken);

module.exports = router;
