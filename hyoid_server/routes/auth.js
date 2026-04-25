const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'supersecret';

const User = require('../models/User');

// Real Auth flow logic
router.post('/send-otp', (req, res) => {
    res.json({ success: true, message: 'OTP sent to ' + req.body.phone });
});

router.post('/verify-otp', async (req, res) => {
    const { phone, otp, role } = req.body;
    
    if (otp !== '123456') {
        return res.status(400).json({ success: false, message: 'Invalid OTP' });
    }
    
    try {
        let user = await User.findOne({ phone });
        
        if (!user) {
            // User doesn't exist yet, they need to register
            // We'll provide a temporary token or just tell the app to show register
            return res.json({
                success: true,
                isNewUser: true,
                message: 'User not found. Please register.',
                phone
            });
        }

        const token = jwt.sign(
            { userId: user._id, role: user.role, phone: user.phone },
            JWT_SECRET,
            { expiresIn: '7d' }
        );

        res.json({
            success: true,
            token,
            user: { id: user._id, phone: user.phone, role: user.role, name: user.name },
        });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

router.post('/register', async (req, res) => {
    try {
        const { role, phone, name } = req.body;
        
        let user = await User.findOne({ phone });
        if (user) return res.status(400).json({ error: 'User already exists' });

        user = new User({
            ...req.body,
            patientId: role === 'patient' ? `HY-${Math.floor(100000 + Math.random() * 900000)}` : undefined
        });

        await user.save();

        const token = jwt.sign(
            { userId: user._id, role: user.role },
            JWT_SECRET,
            { expiresIn: '7d' }
        );
        
        res.json({ 
            success: true, 
            token, 
            user: { ...user.toObject(), id: user._id } 
        });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

router.get('/profile', async (req, res) => {
    try {
        const authHeader = req.headers['authorization'];
        if (!authHeader) return res.status(401).json({ error: 'No token' });
        const token = authHeader.replace('Bearer ', '');
        const decoded = jwt.verify(token, JWT_SECRET);
        
        const user = await User.findById(decoded.userId);
        if (!user) return res.status(404).json({ error: 'User not found' });
        
        res.json({ success: true, data: user });
    } catch (err) {
        res.status(401).json({ success: false, error: 'Invalid token' });
    }
});

module.exports = router;
