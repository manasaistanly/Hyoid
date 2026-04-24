const Notification = require('../models/Notification');

module.exports = (io) => {
  const notificationNamespace = io.of('/notifications');

  notificationNamespace.on('connection', (socket) => {
    console.log(`Notification Client Connected: ${socket.id}`);

    // Join user-specific room for notifications
    socket.on('join-user', (userId) => {
      socket.join(`user-${userId}`);
      console.log(`User ${userId} joined notification room`);
    });

    // Leave user room
    socket.on('leave-user', (userId) => {
      socket.leave(`user-${userId}`);
      console.log(`User ${userId} left notification room`);
    });

    // Mark notification as read
    socket.on('mark-read', async (data) => {
      try {
        const { notificationId, userId } = data;
        const notification = await Notification.findOneAndUpdate(
          { _id: notificationId, userId },
          { isRead: true },
          { new: true }
        );

        if (notification) {
          // Emit to user's room
          notificationNamespace.to(`user-${userId}`).emit('notification-updated', notification);
        }
      } catch (error) {
        console.error('Error marking notification as read:', error);
      }
    });

    socket.on('disconnect', () => {
      console.log(`Notification Client Disconnected: ${socket.id}`);
    });
  });

  // Function to send notification to user (can be called from other parts of the app)
  const sendNotification = async (userId, notificationData) => {
    try {
      // Save to database
      const notification = new Notification({
        userId,
        ...notificationData
      });
      await notification.save();

      // Emit to user's room in real-time
      notificationNamespace.to(`user-${userId}`).emit('new-notification', notification);

      return notification;
    } catch (error) {
      console.error('Error sending notification:', error);
      throw error;
    }
  };

  // Function to get unread count for user
  const getUnreadCount = async (userId) => {
    try {
      return await Notification.countDocuments({ userId, isRead: false });
    } catch (error) {
      console.error('Error getting unread count:', error);
      return 0;
    }
  };

  // Export functions for use in other modules
  return {
    sendNotification,
    getUnreadCount
  };
};