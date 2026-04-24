const mongoose = require('mongoose');

const AppointmentSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: true,
  },
  name: {
    type: String,
    required: true,
  },
  age: {
    type: Number,
    required: true,
  },
  contact: {
    type: String,
    required: true,
  },
  symptoms: {
    type: String,
    required: true,
  },
  status: {
    type: String,
    enum: ['pending', 'contacted', 'assigned', 'confirmed', 'completed', 'cancelled'],
    default: 'pending',
  },
  assignedTo: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
  },
  type: {
    type: String,
    enum: ['doctor', 'nurse'],
    required: true,
  },
  notes: {
    type: String,
  },
  preferredTime: {
    type: String,
    required: true,
  },
  priority: {
    type: String,
    enum: ['urgent', 'normal'],
    default: 'normal',
  },
  adminNotes: {
    type: String,
  },
  staffNotes: {
    type: String,
  }
}, {
  timestamps: true,
});

module.exports = mongoose.model('Appointment', AppointmentSchema);