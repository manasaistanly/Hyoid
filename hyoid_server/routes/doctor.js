const express = require('express');
const router = express.Router();
const Consultation = require('../models/Consultation');
const mongoose = require('mongoose');

// ── Doctor Auth Middleware ───────────────────────────────────────────────────
const doctorOnly = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  if (!authHeader) return res.status(401).json({ error: 'Unauthorized: No token provided' });
  
  // In this production-like mock, we assume the token IS the doctorId
  // or contains it. We'll attach it to the request.
  // Real app: const decoded = jwt.verify(token, secret); req.doctorId = decoded.id;
  const token = authHeader.replace('Bearer ', '');
  
  // For the purpose of this task, if token is 'doctor_mock_jwt_token', we use a static ID
  if (token === 'doctor_mock_jwt_token' || token.startsWith('mock_doctor_')) {
    req.doctorId = new mongoose.Types.ObjectId("662867890123456789012345"); // Fixed mock doctor ID
    return next();
  }
  
  try {
    req.doctorId = new mongoose.Types.ObjectId(token);
    next();
  } catch (e) {
    res.status(401).json({ error: 'Unauthorized: Invalid doctor ID/token' });
  }
};

router.use(doctorOnly);

// ── Dashboard Stats ───────────────────────────────────────────────────────────
router.get('/stats', async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const stats = await Consultation.aggregate([
      { $match: { doctorId: req.doctorId } },
      {
        $facet: {
          totalToday: [
            { $match: { createdAt: { $gte: today } } },
            { $count: "count" }
          ],
          pending: [
            { $match: { status: 'pending', assistantNotes: { $exists: true, $ne: "" } } },
            { $count: "count" }
          ],
          emergency: [
            { $match: { isEmergency: true, status: 'pending' } },
            { $count: "count" }
          ],
          completed: [
            { $match: { status: 'completed' } },
            { $count: "count" }
          ]
        }
      }
    ]);

    const result = {
      totalToday: stats[0].totalToday[0]?.count || 0,
      pending: stats[0].pending[0]?.count || 0,
      emergency: stats[0].emergency[0]?.count || 0,
      completed: stats[0].completed[0]?.count || 0
    };

    // Get Next Case (Highest priority pending)
    const nextCase = await Consultation.findOne({
      doctorId: req.doctorId,
      status: 'pending',
      assistantNotes: { $exists: true, $ne: "" }
    }).sort({ isEmergency: -1, createdAt: 1 });

    const doctor = await User.findById(req.doctorId);
    res.json({ 
      success: true, 
      data: { 
        ...result, 
        nextCase, 
        safetyNumber: doctor?.safetyNumber || '+910000000000' 
      } 
    });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// ── Patient Requests ─────────────────────────────────────────────────────────
router.get('/requests', async (req, res) => {
  try {
    const { status } = req.query; // 'pending', 'accepted', 'completed'
    let query = { doctorId: req.doctorId };

    if (status === 'pending') {
      query.status = 'pending';
      query.assistantNotes = { $exists: true, $ne: "" }; // Rule: Only show if assistant notes exist
    } else if (status) {
      query.status = status;
    }

    const requests = await Consultation.find(query)
      .sort({ isEmergency: -1, createdAt: -1 });

    res.json({ success: true, data: requests });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// ── Consultation History ─────────────────────────────────────────────────────
router.get('/history', async (req, res) => {
  try {
    const history = await Consultation.find({
      doctorId: req.doctorId,
      status: { $in: ['completed', 'rejected'] }
    }).sort({ updatedAt: -1 });

    res.json({ success: true, data: history });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// ── Patient Details ──────────────────────────────────────────────────────────
router.get('/patient/:id', async (req, res) => {
  try {
    const consultation = await Consultation.findById(req.params.id);
    if (!consultation) return res.status(404).json({ error: 'Consultation not found' });
    
    // In a real app, we would also fetch patient profile from User collection
    res.json({ success: true, data: consultation });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// ── Decision Actions ──────────────────────────────────────────────────────────

// Helper for status updates with validation
const updateConsultationStatus = async (id, doctorId, fromStatus, toStatus, extraData = {}) => {
  const consultation = await Consultation.findOne({ _id: id, doctorId });
  if (!consultation) throw new Error('Consultation not found or unauthorized');
  
  if (consultation.status !== fromStatus) {
    throw new Error(`Invalid transition: Current status is ${consultation.status}, expected ${fromStatus}`);
  }

  Object.assign(consultation, { status: toStatus, ...extraData });
  return await consultation.save();
};

router.post('/accept', async (req, res) => {
  try {
    const data = await updateConsultationStatus(req.body.id, req.doctorId, 'pending', 'accepted');
    res.json({ success: true, data });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

router.post('/reject', async (req, res) => {
  try {
    const data = await updateConsultationStatus(req.body.id, req.doctorId, 'pending', 'rejected');
    res.json({ success: true, data });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

router.post('/prescription', async (req, res) => {
  try {
    const { id, prescription } = req.body;
    const data = await updateConsultationStatus(id, req.doctorId, 'accepted', 'completed', { prescription });
    res.json({ success: true, message: 'Prescription submitted and consultation completed', data });
  } catch (err) {
    // If it was still pending, allow direct completion too? Rule says pending -> accepted -> completed
    // Let's stick to the rule but allow direct if desired. 
    // The user said: "pending -> accepted -> completed"
    res.status(400).json({ success: false, error: err.message });
  }
});

router.post('/lab', async (req, res) => {
  try {
    const { id, labTests } = req.body;
    const data = await updateConsultationStatus(id, req.doctorId, 'accepted', 'lab_requested', { labTests });
    res.json({ success: true, message: 'Lab tests requested', data });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

router.post('/hospital', async (req, res) => {
  try {
    const { id, hospitalReferral } = req.body;
    const data = await updateConsultationStatus(id, req.doctorId, 'accepted', 'hospital_referred', { hospitalReferral });
    res.json({ success: true, message: 'Hospital referral sent', data });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

const User = require('../models/User');

// ── Doctor Profile ────────────────────────────────────────────────────────────

router.get('/profile', async (req, res) => {
  try {
    const doctor = await User.findById(req.doctorId);
    if (!doctor) return res.status(404).json({ error: 'Doctor profile not found' });
    res.json({ success: true, data: doctor });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

router.put('/profile', async (req, res) => {
  try {
    const doctor = await User.findByIdAndUpdate(
      req.doctorId, 
      { $set: req.body }, 
      { new: true, runValidators: true }
    );
    if (!doctor) return res.status(404).json({ error: 'Doctor profile not found' });
    res.json({ success: true, data: doctor });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
