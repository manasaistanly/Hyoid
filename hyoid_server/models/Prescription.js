const mongoose = require('mongoose');

const prescriptionItemSchema = new mongoose.Schema({
  medicineName: {
    type: String,
    required: true,
  },
  dosage: {
    type: String,
    required: true,
  },
  frequency: {
    type: String,
    required: true,
  },
  duration: {
    type: Number, // in days
    required: true,
  },
  instructions: {
    type: String,
    required: true,
  },
  genericAlternative: {
    type: String,
  },
});

const prescriptionSchema = new mongoose.Schema({
  consultationId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Consultation',
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
  issuedAt: {
    type: Date,
    default: Date.now,
  },
  diagnosis: {
    type: String,
    required: true,
  },
  medicines: [prescriptionItemSchema],
  notes: {
    type: String,
  },
  doctorSignature: {
    type: String,
    required: true,
  },
  isDigital: {
    type: Boolean,
    default: true,
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('Prescription', prescriptionSchema);