const admin = require('firebase-admin');
const path = require('path');

// Initialize only once
if (!admin.apps.length) {
  try {
    if (process.env.FIREBASE_SERVICE_ACCOUNT_KEY) {
      // If it's a path to a file
      const serviceAccount = require(path.resolve(process.env.FIREBASE_SERVICE_ACCOUNT_KEY));
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
      });
      console.log('Firebase Admin initialized from file');
    } else {
      console.warn('FIREBASE_SERVICE_ACCOUNT_KEY is not set. Firebase features will not work.');
    }
  } catch (e) {
    console.error('Firebase Admin initialization failed:', e.message);
  }
}

module.exports = admin;
