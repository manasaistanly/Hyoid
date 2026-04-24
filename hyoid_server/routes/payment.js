/**
 * routes/payment.js
 * ─────────────────────────────────────────────────────────────
 * Payment routes — mounted at /api/payment in server.js
 *
 * All routes are protected (JWT required via `protect` middleware).
 * These routes are EXCLUDED from the checkPayment middleware so that
 * unpaid users can still create orders and verify payments.
 *
 *   POST /api/payment/create-order  — creates a Razorpay order
 *   POST /api/payment/verify        — verifies payment signature + marks user paid
 *   GET  /api/payment/status        — returns current user's payment status
 * ─────────────────────────────────────────────────────────────
 */
const express = require('express');
const { createOrder, verifyPayment, getStatus } = require('../controllers/paymentController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.post('/create-order', protect, createOrder);
router.post('/verify', protect, verifyPayment);
router.get('/status', protect, getStatus);

module.exports = router;
