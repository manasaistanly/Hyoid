const admin = require('./firebaseAdmin');

const sendNotification = async (deviceToken, title, body, data) => {
  if (!admin.apps.length) return false;

  const message = {
    notification: {
      title,
      body,
    },
    data: data || {},
    token: deviceToken,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
    return true;
  } catch (error) {
    console.error('Error sending message:', error);
    return false;
  }
};

module.exports = sendNotification;
