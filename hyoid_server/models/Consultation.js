const mongoose = require('mongoose');

const consultationMessageSchema = new mongoose.Schema({
  senderId: {
    type: String,
    required: true,
  },
  senderType: {
    type: String,
    enum: ['doctor', 'patient'],
    required: true,
  },
  type: {
    type: String,
    enum: ['text', 'image', 'voice', 'file'],
    default: 'text',
  },
  content: {
    type: String,
    required: true,
  },
  timestamp: {
    type: Date,
    default: Date.now,
  },
  isRead: {
    type: Boolean,
    default: false,
  },
});

const consultationSchema = new mongoose.Schema({
  appointmentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Appointment',
    required: true,
  },
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Doctor',
    required: true,
  },
  patientId: {
    type: String,
    required: true,
  },
  startedAt: {
    type: Date,
    default: Date.now,
  },
  endedAt: {
    type: Date,
  },
  status: {
    type: String,
    enum: ['waiting', 'active', 'completed'],
    default: 'waiting',
  },
  type: {
    type: String,
    enum: ['chat', 'video'],
    required: true,
  },
  messages: [consultationMessageSchema],
  queuePosition: {
    type: Number,
    default: 1,
  },
  estimatedWaitTime: {
    type: Number, // in seconds
    default: 120,
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('Consultation', consultationSchema);