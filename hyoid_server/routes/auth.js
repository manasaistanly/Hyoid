const express = require('express');
const router = express.Router();

// Mock Auth routes — role field added for Flutter role-based routing
router.post('/send-otp', (req, res) => {
    res.json({ success: true, message: 'OTP sent' });
});

router.post('/verify-otp', (req, res) => {
    const role = req.body.role || 'patient'; // Flutter sends selected role
    const token = role === 'doctor' ? 'doctor_mock_jwt_token' : 'patient_mock_jwt_token';
    res.json({
        success: true,
        token,
        user: { id: `mock_${role}_id`, phone: req.body.phone, role },
    });
});

router.post('/google', (req, res) => {
    const role = req.body.role || 'patient';
    const token = role === 'doctor' ? 'doctor_mock_jwt_token' : 'patient_mock_jwt_token';
    res.json({
        success: true,
        token,
        user: { id: `mock_google_${role}_id`, email: req.body.email, role },
    });
});

router.post('/register', (req, res) => {
    const role = req.body.role || 'patient';
    res.json({ success: true, token: `${role}_mock_jwt_token`, user: { ...req.body, role } });
});

module.exports = router;
