const mongoose = require('mongoose');
const Notification = require('./models/Notification');
require('dotenv').config();

// Test notification creation
const testNotifications = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    // Create a test notification
    const notification = new Notification({
      userId: '507f1f77bcf86cd799439011',
      title: 'Test Real-time Notification',
      message: 'This is a test notification to demonstrate real-time functionality.',
      type: 'system',
      data: { test: true },
      isRead: false,
      priority: 'medium'
    });

    await notification.save();
    console.log('Test notification created:', notification._id);

    // Simulate what happens when sendNotification is called
    console.log('Notification would be sent to user room via WebSocket');

    mongoose.connection.close();
  } catch (error) {
    console.error('Error:', error);
  }
};

testNotifications();