const mongoose = require('mongoose');

const labTestSchema = new mongoose.Schema({
    name: { type: String, required: true },
    description: { type: String },
    specimen: { type: String },
    price: { type: Number, required: true },
    category: { type: String },
    icon: { type: String },
});

module.exports = mongoose.model('LabTest', labTestSchema);
