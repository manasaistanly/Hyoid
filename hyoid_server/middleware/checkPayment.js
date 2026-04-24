/**
 * middleware/checkPayment.js
 * ─────────────────────────────────────────────────────────────
 * Payment gate middleware.
 * Must be applied AFTER the `protect` middleware (JWT auth).
 *
 * Checks req.user.isPaid. If false → returns 402 with
 * { requiresPayment: true } so the Flutter app knows to redirect
 * the user to PaymentScreen.
 *
 * Excluded routes (bypass this check):
 *   - /api/auth/*   (login / register / OTP)
 *   - /api/payment/* (order creation / verification / status)
 *
 * Doctors are also excluded from the payment check.
 * ─────────────────────────────────────────────────────────────
 */

/**
 * Middleware to enforce payment for all patient routes.
 * Apply this after `protect` on any route that requires a paid account.
 */
exports.checkPayment = (req, res, next) => {
  const user = req.user;

  if (!user) {
    return res
      .status(401)
      .json({ success: false, message: 'Not authorised', errors: [] });
  }

  // Doctors and admins are not subject to the patient payment wall
  if (user.role === 'doctor' || user.role === 'admin' || user.role === 'nurse') {
    return next();
  }

  if (!user.isPaid) {
    return res.status(402).json({
      success: false,
      message: 'Payment required to access this resource',
      requiresPayment: true,
    });
  }

  next();
};
