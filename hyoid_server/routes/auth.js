const express = require('express');
const router = express.Router();

// Mock Auth routes
router.post('/send-otp', (req, res) => {
    res.json({ success: true, message: 'OTP sent' });
});

router.post('/verify-otp', (req, res) => {
    res.json({ success: true, token: 'mock_jwt_token', user: { id: 'mock_id', phone: req.body.phone } });
});

router.post('/google', (req, res) => {
    res.json({ success: true, token: 'mock_jwt_token', user: { id: 'mock_google_id', email: req.body.email } });
});

router.post('/register', (req, res) => {
    res.json({ success: true, token: 'mock_jwt_token', user: req.body });
});

module.exports = router;
