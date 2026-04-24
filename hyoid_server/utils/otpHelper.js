/**
 * utils/otpHelper.js
 * ─────────────────────────────────────────────────────────────
 * Utilities for OTP lifecycle:
 *   - Generate a cryptographically random 6-digit OTP
 *   - Hash and verify OTPs using bcryptjs
 *   - Send OTPs via Twilio SMS
 *
 * Used by: controllers/authController.js → sendOtp(), verifyOtp()
 * Requires: TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_PHONE_NUMBER in .env
 * ─────────────────────────────────────────────────────────────
 */
const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const twilio = require('twilio');

// Lazy-load Twilio client so server boots even without Twilio creds (dev mode)
let twilioClient;
const getTwilioClient = () => {
  if (!twilioClient) {
    if (!process.env.TWILIO_ACCOUNT_SID || !process.env.TWILIO_AUTH_TOKEN) {
      throw new Error('Twilio credentials not configured in .env');
    }
    twilioClient = twilio(
      process.env.TWILIO_ACCOUNT_SID,
      process.env.TWILIO_AUTH_TOKEN
    );
  }
  return twilioClient;
};

/**
 * Generates a 6-digit OTP string using crypto for security.
 * @returns {string} e.g. "482031"
 */
const generateOtp = () => {
  // Random number in [0, 999999], zero-padded to 6 digits
  return String(crypto.randomInt(0, 1000000)).padStart(6, '0');
};

/**
 * Hashes an OTP using bcrypt (salt rounds = 10).
 * @param {string} otp
 * @returns {Promise<string>} bcrypt hash
 */
const hashOtp = async (otp) => {
  const salt = await bcrypt.genSalt(10);
  return bcrypt.hash(otp, salt);
};

/**
 * Compares a plain OTP against a stored bcrypt hash.
 * @param {string} otp - plain text OTP entered by user
 * @param {string} hash - stored bcrypt hash
 * @returns {Promise<boolean>}
 */
const verifyOtpHash = async (otp, hash) => {
  return bcrypt.compare(otp, hash);
};

/**
 * Sends an SMS via Twilio to the given phone number.
 * @param {string} to - E.164 phone number e.g. "+919876543210"
 * @param {string} message - SMS body text
 * @returns {Promise<void>}
 */
const sendSms = async (to, message) => {
  const client = getTwilioClient();
  await client.messages.create({
    body: message,
    from: process.env.TWILIO_PHONE_NUMBER,
    to,
  });
};

module.exports = { generateOtp, hashOtp, verifyOtpHash, sendSms };
