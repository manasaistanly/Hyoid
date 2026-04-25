const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const Consultation = require('../models/Consultation');
const User = require('../models/User');

const JWT_SECRET = process.env.JWT_SECRET || 'supersecret';

// ── Assistant Auth Middleware ────────────────────────────────────────────────
const assistantOnly = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    if (!authHeader) return res.status(401).json({ success: false, error: 'No token provided' });

    const token = authHeader.replace('Bearer ', '');
    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        if (decoded.role !== 'assistant') {
            return res.status(403).json({ success: false, error: 'Forbidden: Assistant access only' });
        }
        req.user = decoded;
        next();
    } catch (err) {
        res.status(401).json({ success: false, error: 'Invalid token' });
    }
};

router.use(assistantOnly);

// ── GET /requests ───────────────────────────────────────────────────────────
router.get('/requests', async (req, res) => {
    try {
        const requests = await Consultation.find({
            assistantId: req.user.userId,
            status: 'assigned'
        }).populate('patientId', 'name phone');

        res.json({ success: true, data: requests });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// ── POST /submit ────────────────────────────────────────────────────────────
router.post('/submit', async (req, res) => {
    try {
        const { consultationId, symptoms, vitals, notes } = req.body;

        const consultation = await Consultation.findOne({
            _id: consultationId,
            assistantId: req.user.userId
        });

        if (!consultation) {
            return res.status(404).json({ success: false, error: 'Consultation not found or not assigned to you' });
        }

        if (consultation.status !== 'assigned') {
            return res.status(400).json({ success: false, error: 'Invalid state: Consultation must be in "assigned" status' });
        }

        // Update consultation
        consultation.symptoms = symptoms;
        consultation.vitals = {
            ...consultation.vitals,
            bp: vitals.bp,
            sugar: vitals.sugar
        };
        consultation.assistantNotes = notes;
        consultation.status = 'ready_for_doctor';

        await consultation.save();

        res.json({ success: true, message: 'Data submitted successfully. Consultation is now ready for doctor.' });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

module.exports = router;
