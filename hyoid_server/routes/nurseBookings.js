const express = require('express');
const router = express.Router();
const Booking = require('../models/Booking');
const auth = require('../middleware/auth');

// POST /nurse-bookings - Create nurse booking
router.post('/', auth, async (req, res) => {
  try {
    const booking = new Booking(req.body);
    await booking.save();

    // Send notification to user
    if (global.sendNotification) {
      await global.sendNotification(req.user.id, {
        title: 'Nurse Booking Confirmed!',
        message: 'Your nurse booking has been confirmed. The nurse will contact you soon.',
        type: 'nurse_booking',
        data: { bookingId: booking._id },
        priority: 'high'
      });
    }

    res.status(201).json(booking);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// GET /nurse-bookings/:id - Get booking by ID
router.get('/:id', auth, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id)
      .populate('userId', 'name phone')
      .populate('nurseId', 'userId hourlyRate');
    if (!booking) return res.status(404).json({ error: 'Booking not found' });
    res.json(booking);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /user/nurse-bookings - Get user's nurse bookings
router.get('/user/bookings', auth, async (req, res) => {
  try {
    const bookings = await Booking.find({ userId: req.user.id })
      .populate('nurseId', 'userId hourlyRate')
      .sort({ createdAt: -1 });
    res.json(bookings);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// PATCH /nurse-bookings/:id/status - Update booking status
router.patch('/:id/status', auth, async (req, res) => {
  try {
    const { status } = req.body;
    const booking = await Booking.findByIdAndUpdate(req.params.id, { status }, { new: true });

    if (!booking) return res.status(404).json({ error: 'Booking not found' });

    // Send notification based on status change
    if (global.sendNotification) {
      let notificationData = {
        type: 'nurse_booking',
        data: { bookingId: booking._id }
      };

      switch (status) {
        case 'assigned':
          notificationData.title = 'Nurse Assigned';
          notificationData.message = 'A nurse has been assigned to your booking and is on the way.';
          notificationData.priority = 'high';
          break;
        case 'in_progress':
          notificationData.title = 'Service Started';
          notificationData.message = 'Your nurse has arrived and service has begun.';
          notificationData.priority = 'medium';
          break;
        case 'completed':
          notificationData.title = 'Service Completed';
          notificationData.message = 'Your nurse service has been completed successfully.';
          notificationData.priority = 'medium';
          break;
        case 'cancelled':
          notificationData.title = 'Booking Cancelled';
          notificationData.message = 'Your nurse booking has been cancelled.';
          notificationData.priority = 'low';
          break;
      }

      if (notificationData.title) {
        await global.sendNotification(booking.userId.toString(), notificationData);
      }
    }

    res.json(booking);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;