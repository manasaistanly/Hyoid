const mongoose = require('mongoose');
const Notification = require('./models/Notification');
require('dotenv').config();

const notifications = [
  {
    userId: '507f1f77bcf86cd799439011', // Dummy user ID - should match a real user
    title: 'Booking Confirmed!',
    message: 'Your appointment with Dr. Sarah Jenkins is confirmed for today.',
    type: 'booking',
    data: { appointmentId: 'appt_123', doctorId: 'doc_456' },
    isRead: false,
    priority: 'medium',
  },
  {
    userId: '507f1f77bcf86cd799439011',
    title: 'Nurse Assigned',
    message: 'Priya Sharma has been assigned to your home care service.',
    type: 'nurse_booking',
    data: { bookingId: 'booking_789', nurseId: 'nurse_101' },
    isRead: false,
    priority: 'high',
  },
  {
    userId: '507f1f77bcf86cd799439011',
    title: 'Upcoming Consultation',
    message: 'Reminder: You have a general consultation scheduled tomorrow.',
    type: 'reminder',
    data: { appointmentId: 'appt_124' },
    isRead: true,
    priority: 'low',
  },
  {
    userId: '507f1f77bcf86cd799439011',
    title: 'Rate Your Experience',
    message: 'How was your last visit? Leave a rating for Dr. Sarah Jenkins.',
    type: 'system',
    data: { appointmentId: 'appt_123' },
    isRead: true,
    priority: 'low',
  },
];

const seedNotifications = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    // Clear existing notifications
    await Notification.deleteMany({});
    console.log('Cleared existing notifications');

    await Notification.insertMany(notifications);
    console.log('Notifications seeded successfully');

    mongoose.connection.close();
    console.log('Database connection closed');
  } catch (error) {
    console.error('Error seeding notifications:', error);
    process.exit(1);
  }
};

if (require.main === module) {
  seedNotifications();
}