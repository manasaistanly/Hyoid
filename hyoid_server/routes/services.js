const express = require('express');
const router = express.Router();
const Service = require('../models/Service');

// GET /api/services
router.get('/', async (req, res) => {
    try {
        const services = await Service.find({});
        res.json({ success: true, data: services });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

module.exports = router;
