const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  nurseId: { type: mongoose.Schema.Types.ObjectId, ref: 'Nurse', required: true },
  serviceType: { type: String, required: true }, // e.g., 'injection', 'wound care'
  date: { type: Date, required: true },
  time: { type: String, required: true },
  duration: { type: Number, required: true }, // in hours
  notes: { type: String },
  status: { type: String, enum: ['pending', 'assigned', 'on_way', 'arrived', 'completed', 'cancelled'], default: 'pending' },
  location: {
    address: { type: String, required: true },
    coordinates: { type: [Number], default: [0, 0] } // [longitude, latitude]
  },
  payment: {
    amount: { type: Number, required: true },
    status: { type: String, enum: ['pending', 'paid', 'refunded'], default: 'pending' },
    method: { type: String }
  },
  recurring: {
    isRecurring: { type: Boolean, default: false },
    frequency: { type: String, enum: ['daily', 'weekly'] },
    endDate: { type: Date }
  },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Booking', bookingSchema);