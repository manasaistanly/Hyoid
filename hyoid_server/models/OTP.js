/**
 * models/OTP.js
 * ─────────────────────────────────────────────────────────────
 * Stores hashed, expiring OTP records for phone authentication.
 * Position in flow: created by POST /api/auth/send-otp,
 *                   consumed by POST /api/auth/verify-otp.
 *
 * Auto-cleanup: TTL index on expiresAt removes docs after expiry.
 * Rate-limit enforcement: attempts field caps tries per document.
 * ─────────────────────────────────────────────────────────────
 */
const mongoose = require('mongoose');

const OTPSchema = new mongoose.Schema(
  {
    // E.164 phone number e.g. "+919876543210"
    phone: {
      type: String,
      required: true,
      unique: true,
    },

    // bcrypt hash of the 6-digit OTP
    otpHash: {
      type: String,
      required: true,
    },

    // OTP becomes invalid after this date (5 minutes from creation)
    expiresAt: {
      type: Date,
      required: true,
      // TTL index: MongoDB auto-deletes document 0 seconds after expiresAt
      index: { expires: 0 },
    },

    // Number of failed verification attempts for this OTP
    attempts: {
      type: Number,
      default: 0,
      max: 3,
    },

    // ISO timestamp of when the OTP was requested (for rate limiting)
    createdAt: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: false }
);

module.exports = mongoose.model('OTP', OTPSchema);
