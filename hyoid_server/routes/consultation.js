const express = require('express');
const router = express.Router();
const Doctor = require('../models/Doctor');
const Appointment = require('../models/Appointment');
const Consultation = require('../models/Consultation');
const Prescription = require('../models/Prescription');

// Get all doctors with optional filters
router.get('/doctors', async (req, res) => {
  try {
    const { specialization, search } = req.query;
    let query = {};

    if (specialization && specialization !== 'All') {
      query.specialization = specialization;
    }

    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { specialization: { $regex: search, $options: 'i' } }
      ];
    }

    const doctors = await Doctor.find(query);
    res.json(doctors);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get doctor by ID
router.get('/doctors/:id', async (req, res) => {
  try {
    const doctor = await Doctor.findById(req.params.id);
    if (!doctor) {
      return res.status(404).json({ error: 'Doctor not found' });
    }
    res.json(doctor);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create appointment
router.post('/appointments', async (req, res) => {
  try {
    const { doctorId, patientId, scheduledAt, type } = req.body;

    // Check if slot is available (basic check)
    const existingAppointment = await Appointment.findOne({
      doctorId,
      scheduledAt: new Date(scheduledAt),
      status: { $in: ['scheduled', 'confirmed'] }
    });

    if (existingAppointment) {
      return res.status(409).json({ error: 'Time slot not available' });
    }

    const appointment = new Appointment({
      doctorId,
      patientId,
      scheduledAt: new Date(scheduledAt),
      type,
      status: 'scheduled'
    });

    await appointment.save();
    res.status(201).json(appointment);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get user appointments
router.get('/appointments/:userId', async (req, res) => {
  try {
    const appointments = await Appointment.find({ patientId: req.params.userId })
      .populate('doctorId')
      .sort({ createdAt: -1 });
    res.json(appointments);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Start consultation
router.post('/consultations/start', async (req, res) => {
  try {
    const { appointmentId, doctorId, patientId, type } = req.body;

    // Update appointment status
    await Appointment.findByIdAndUpdate(appointmentId, { status: 'in_progress' });

    const consultation = new Consultation({
      appointmentId,
      doctorId,
      patientId,
      type,
      status: 'waiting',
      queuePosition: 1, // Simplified queue
      estimatedWaitTime: 120, // 2 minutes
    });

    await consultation.save();
    res.status(201).json(consultation);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// End consultation
router.post('/consultations/end', async (req, res) => {
  try {
    const { consultationId } = req.body;

    const consultation = await Consultation.findByIdAndUpdate(
      consultationId,
      {
        status: 'completed',
        endedAt: new Date()
      },
      { new: true }
    );

    if (!consultation) {
      return res.status(404).json({ error: 'Consultation not found' });
    }

    // Update appointment status
    await Appointment.findByIdAndUpdate(consultation.appointmentId, { status: 'completed' });

    res.json({ message: 'Consultation ended successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create prescription
router.post('/prescriptions', async (req, res) => {
  try {
    const { consultationId, doctorId, patientId, diagnosis, medicines, notes } = req.body;

    const prescription = new Prescription({
      consultationId,
      doctorId,
      patientId,
      diagnosis,
      medicines,
      notes,
    });

    await prescription.save();
    res.status(201).json(prescription);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get user prescriptions
router.get('/prescriptions/:userId', async (req, res) => {
  try {
    const prescriptions = await Prescription.find({ patientId: req.params.userId })
      .populate('doctorId')
      .populate('consultationId')
      .sort({ issuedAt: -1 });
    res.json(prescriptions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;