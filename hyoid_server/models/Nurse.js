const mongoose = require('mongoose');

const nurseSchema = new mongoose.Schema({
  name: { type: String, required: true },
  phone: { type: String, required: true },
  qualifications: [{ type: String }],
  experience: { type: Number, required: true }, // in years
  specializations: [{ type: String }],
  languages: [{ type: String }],
  verified: { type: Boolean, default: false },
  rating: { type: Number, default: 0 },
  reviewCount: { type: Number, default: 0 },
  hourlyRate: { type: Number, required: true },
  availability: { type: Boolean, default: true },
  location: {
    type: { type: String, enum: ['Point'], default: 'Point' },
    coordinates: { type: [Number], default: [0, 0] } // [longitude, latitude]
  },
  documents: {
    license: { type: String },
    aadhaar: { type: String },
    certifications: [{ type: String }]
  },
  createdAt: { type: Date, default: Date.now }
});

nurseSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('Nurse', nurseSchema);