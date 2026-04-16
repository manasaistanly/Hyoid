const express = require('express');
const router = express.Router();

router.get('/slots/:doctorId/:date', (req, res) => {
    res.json({ success: true, slots: ['09:00', '10:00', '11:00'] });
});

router.post('/', (req, res) => {
    res.json({ success: true, message: 'Booking confirmed' });
});

module.exports = router;
