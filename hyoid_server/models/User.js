const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  phone: {
    type: String,
    unique: true,
    sparse: true
  },
  email: {
    type: String,
    unique: true,
    sparse: true
  },
  role: {
    type: String,
    enum: ['patient', 'doctor', 'assistant', 'admin'],
    required: true
  },
  name: String,
  
  // Patient specific
  bloodGroup: String,
  dob: Date,
  emergencyContact: String,
  patientId: String, // e.g. HY-123456
  
  // Doctor specific
  specialty: String,
  qualifications: String,
  licenseNumber: String,
  experienceYears: Number,
  consultationFee: Number,
  bio: String,
  rating: { type: Number, default: 0 },
  totalPatients: { type: Number, default: 0 },
  acceptingBookings: { type: Boolean, default: true },
  safetyNumber: String,
  
}, { timestamps: true });

module.exports = mongoose.model('User', UserSchema);
