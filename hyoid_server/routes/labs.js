const express = require('express');
const router = express.Router();
const LabTest = require('../models/LabTest');

// GET /api/labs
router.get('/', async (req, res) => {
    try {
        const labs = await LabTest.find({});
        res.json({ success: true, data: labs });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

module.exports = router;
