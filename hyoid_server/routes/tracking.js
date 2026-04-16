const express = require('express');
const router = express.Router();

router.get('/:appointmentId', (req, res) => {
    res.json({ success: true, lat: 12.9715987, lng: 77.5945627 });
});

module.exports = router;
