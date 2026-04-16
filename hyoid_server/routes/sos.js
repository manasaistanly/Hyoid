const express = require('express');
const router = express.Router();

router.post('/', (req, res) => {
    const { patientId, lat, lng } = req.body;
    console.log(`SOS Received from ${patientId} at [${lat}, ${lng}]`);
    res.json({ success: true, message: 'SOS Alert Broadcasted' });
});

module.exports = router;
