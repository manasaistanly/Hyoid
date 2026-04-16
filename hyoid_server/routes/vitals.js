const express = require('express');
const router = express.Router();

router.get('/:patientId', (req, res) => {
    res.json({ success: true, vitals: { heartRate: 75, spO2: 98, temperature: 98.6 } });
});

module.exports = router;
