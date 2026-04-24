/**
 * utils/googleVerify.js
 * ─────────────────────────────────────────────────────────────
 * Verifies a Google ID token sent from the Flutter app after
 * a successful Google Sign-In on device.
 *
 * Used by: controllers/authController.js → googleSignIn()
 * Requires: GOOGLE_CLIENT_ID in .env
 * ─────────────────────────────────────────────────────────────
 */
const { OAuth2Client } = require('google-auth-library');

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

/**
 * Verifies a Google ID token and returns the payload.
 * @param {string} idToken - ID token from Flutter's GoogleSignInAuthentication
 * @returns {Promise<{googleId, email, name, picture}>}
 */
const verifyGoogleToken = async (idToken) => {
  const ticket = await client.verifyIdToken({
    idToken,
    audience: process.env.GOOGLE_CLIENT_ID,
  });

  const payload = ticket.getPayload();

  if (!payload) {
    throw new Error('Invalid Google token payload');
  }

  return {
    googleId: payload.sub,
    email: payload.email,
    name: payload.name,
    picture: payload.picture,
  };
};

module.exports = { verifyGoogleToken };
