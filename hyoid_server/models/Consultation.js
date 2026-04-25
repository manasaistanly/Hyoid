const mongoose = require('mongoose');

const ConsultationSchema = new mongoose.Schema({
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  assistantId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  symptoms: {
    type: String,
    required: true
  },
  vitals: {
    bp: String,
    sugar: String,
    temperature: String
  },
  assistantNotes: String,
  images: [String],
  status: {
    type: String,
    enum: ['pending', 'accepted', 'rejected', 'completed', 'lab_requested', 'hospital_referred'],
    default: 'pending'
  },
  isEmergency: {
    type: Boolean,
    default: false
  },
  prescription: {
    medicines: [
      {
        name: String,
        dosage: String,
        duration: String
      }
    ],
    notes: String
  },
  labTests: [String],
  hospitalReferral: {
    suggested: {
      type: Boolean,
      default: false
    },
    hospitalName: String
  }
}, { timestamps: true });

// Performance Indexes
ConsultationSchema.index({ status: 1 });
ConsultationSchema.index({ doctorId: 1 });
ConsultationSchema.index({ createdAt: -1 });
ConsultationSchema.index({ isEmergency: -1, createdAt: -1 }); // Compound index for sorting

module.exports = mongoose.model('Consultation', ConsultationSchema);
