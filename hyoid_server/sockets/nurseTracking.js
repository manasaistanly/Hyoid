const Booking = require('../models/Booking');

module.exports = (io) => {
  io.on('connection', (socket) => {
    console.log('Nurse tracking client connected:', socket.id);

    socket.on('join-booking', (bookingId) => {
      socket.join(`booking-${bookingId}`);
      console.log(`Client joined booking room: ${bookingId}`);
    });

    socket.on('update-location', (data) => {
      const { bookingId, location, status } = data;
      // Update booking status and location in DB
      Booking.findByIdAndUpdate(bookingId, {
        status: status || 'on_way',
        'location.coordinates': location
      }).then(() => {
        // Emit to user
        io.to(`booking-${bookingId}`).emit('nurse-location-update', {
          location,
          status: status || 'on_way',
          timestamp: new Date()
        });
      });
    });

    socket.on('update-status', (data) => {
      const { bookingId, status } = data;
      Booking.findByIdAndUpdate(bookingId, { status }).then(() => {
        io.to(`booking-${bookingId}`).emit('booking-status-update', {
          status,
          timestamp: new Date()
        });
      });
    });

    socket.on('disconnect', () => {
      console.log('Nurse tracking client disconnected:', socket.id);
    });
  });
};