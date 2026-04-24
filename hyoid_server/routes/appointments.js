const express = require('express');
const { 
  createAppointment, 
  getMyAppointments, 
  getAppointment, 
  cancelAppointment, 
  getAppointments, 
  updateAppointment, 
  getAssignedAppointments, 
  respondToAppointment 
} = require('../controllers/appointmentController');
const { protect, authorize } = require('../middleware/auth');

const router = express.Router();

// Patient routes
router.post('/', protect, createAppointment);
router.get('/my', protect, getMyAppointments);
router.get('/:id', protect, getAppointment);
router.delete('/:id', protect, cancelAppointment);

// Admin routes
router.get('/', protect, authorize('admin'), getAppointments);
router.put('/:id', protect, authorize('admin', 'doctor', 'nurse'), updateAppointment); // shared route for updating

// Staff routes
router.get('/staff/assigned', protect, authorize('doctor', 'nurse'), getAssignedAppointments);
router.put('/:id/respond', protect, authorize('doctor', 'nurse'), respondToAppointment);

module.exports = router;
