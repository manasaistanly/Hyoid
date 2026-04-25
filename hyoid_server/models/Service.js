const mongoose = require('mongoose');

const serviceSchema = new mongoose.Schema({
    name: { type: String, required: true },
    description: { type: String },
    type: { type: String, enum: ['consultation', 'home_visit', 'online'], default: 'consultation' },
    price: { type: Number, required: true },
    icon: { type: String }, // Icon name for Flutter
    color: { type: String }, // Hex color code
});

module.exports = mongoose.model('Service', serviceSchema);
