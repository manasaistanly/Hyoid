const Appointment = require('../models/Appointment');
const Notification = require('../models/Notification');
const sendNotification = require('../utils/sendNotification');
const User = require('../models/User');

// Helper to emit and notify
const triggerNotification = async (req, userId, title, body, type, appointmentId) => {
  // Save to DB
  await Notification.create({ userId, title, body, type, appointmentId });
  // Emit to socket
  const io = req.app.get('io');
  if (io) {
    io.to(`user:${userId}`).emit(type, { title, body, appointmentId });
  }
  // Send push
  const targetUser = await User.findById(userId);
  if (targetUser && targetUser.deviceToken) {
    await sendNotification(targetUser.deviceToken, title, body, { appointmentId: appointmentId.toString(), type });
  }
};

// @desc    Create appointment
// @route   POST /api/appointments
// @access  Private (Patient)
exports.createAppointment = async (req, res, next) => {
  try {
    req.body.userId = req.user.id; // auto-set
    
    const appointment = await Appointment.create(req.body);

    res.status(201).json({
      success: true,
      data: appointment
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get logged in user appointments
// @route   GET /api/appointments/my
// @access  Private (Patient)
exports.getMyAppointments = async (req, res, next) => {
  try {
    const appointments = await Appointment.find({ userId: req.user.id }).sort('-createdAt');
    res.status(200).json({
      success: true,
      count: appointments.length,
      data: appointments
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Cancel appointment
// @route   DELETE /api/appointments/:id
// @access  Private
exports.cancelAppointment = async (req, res, next) => {
  try {
    let appointment = await Appointment.findById(req.params.id);

    if (!appointment) return res.status(404).json({ success: false, message: 'Not found', errors: [] });
    if (appointment.userId.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ success: false, message: 'Not authorized', errors: [] });
    }

    appointment.status = 'cancelled';
    await appointment.save();

    res.status(200).json({
      success: true,
      data: appointment
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get single appointment
// @route   GET /api/appointments/:id
// @access  Private
exports.getAppointment = async (req, res, next) => {
  try {
    const appointment = await Appointment.findById(req.params.id).populate('userId', 'name email').populate('assignedTo', 'name email');
    if (!appointment) return res.status(404).json({ success: false, message: 'Not found', errors: [] });

    res.status(200).json({
      success: true,
      data: appointment
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get all appointments (Admin)
// @route   GET /api/appointments
// @access  Private/Admin
exports.getAppointments = async (req, res, next) => {
  try {
    const appointments = await Appointment.find().populate('userId', 'name').sort('-createdAt');
    res.status(200).json({
      success: true,
      count: appointments.length,
      data: appointments
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Update appointment (Admin)
// @route   PUT /api/appointments/:id
// @access  Private/Admin
exports.updateAppointment = async (req, res, next) => {
  try {
    let appointment = await Appointment.findById(req.params.id);
    if (!appointment) return res.status(404).json({ success: false, message: 'Not found', errors: [] });

    appointment = await Appointment.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });

    // Notify Patient
    await triggerNotification(req, appointment.userId, 'Appointment Updated', `Your appointment status changed to ${req.body.status || appointment.status}`, 'appointment:updated', appointment._id);

    // If suddenly assigned to a doctor, notify them
    if (appointment.assignedTo) {
      await triggerNotification(req, appointment.assignedTo, 'New Patient Assigned', 'You have been assigned a new appointment', 'appointment:assigned', appointment._id);
    }

    res.status(200).json({
      success: true,
      data: appointment
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get assigned appointments (Doctor/Nurse)
// @route   GET /api/appointments/assigned
// @access  Private (Staff)
exports.getAssignedAppointments = async (req, res, next) => {
  try {
    const appointments = await Appointment.find({ assignedTo: req.user.id }).populate('userId', 'name age phone').sort('-createdAt');
    res.status(200).json({
      success: true,
      count: appointments.length,
      data: appointments
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Respond to appointment (accept/reject)
// @route   PUT /api/appointments/:id/respond
// @access  Private (Staff)
exports.respondToAppointment = async (req, res, next) => {
  try {
    let appointment = await Appointment.findById(req.params.id);
    if (!appointment) return res.status(404).json({ success: false, message: 'Not found', errors: [] });

    if (appointment.assignedTo.toString() !== req.user.id) {
       return res.status(403).json({ success: false, message: 'Not assigned to you', errors: [] });
    }

    appointment.status = req.body.status || appointment.status;
    appointment.staffNotes = req.body.staffNotes || appointment.staffNotes;
    
    await appointment.save();

    // Notify patient
    await triggerNotification(req, appointment.userId, 'Staff Responded', `Your assigned staff has updated the status to ${appointment.status}`, 'appointment:updated', appointment._id);

    res.status(200).json({
      success: true,
      data: appointment
    });
  } catch (err) {
    next(err);
  }
};
