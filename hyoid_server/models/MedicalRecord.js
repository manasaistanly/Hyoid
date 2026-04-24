const mongoose = require('mongoose');

const medicalRecordSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  bookingId: { type: mongoose.Schema.Types.ObjectId, ref: 'Booking', required: true },
  nurseId: { type: mongoose.Schema.Types.ObjectId, ref: 'Nurse', required: true },
  vitals: {
    bloodPressure: { type: String },
    sugar: { type: Number },
    temperature: { type: Number },
    pulse: { type: Number }
  },
  notes: { type: String },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('MedicalRecord', medicalRecordSchema);