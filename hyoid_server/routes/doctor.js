const express = require('express');
const router = express.Router();

// ── Mock role middleware ──────────────────────────────────────────────────────
// In production: verify JWT and check request.user.role === 'doctor'
const doctorOnly = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  if (!authHeader) return res.status(401).json({ error: 'Unauthorized' });
  // Mock: any token that starts with 'doctor_' is a doctor
  // Real app: jwt.verify(token) and check role
  next();
};

router.use(doctorOnly);

// ── Dashboard Stats ───────────────────────────────────────────────────────────
router.get('/stats', (req, res) => {
  res.json({
    success: true,
    data: {
      todayCount: 8,
      pendingCount: 3,
      completedCount: 5,
      weeklyCount: 34,
      cancellationRate: 12.5, // percent
      nextAppointment: {
        id: 'appt_001',
        patientName: 'Arjun Sharma',
        patientAge: 34,
        time: '11:30 AM',
        type: 'in-person',
        status: 'confirmed',
      },
    },
  });
});

// ── Patient Requests (Doctor Dashboard) ───────────────────────────────────────
const mockRequests = [
  {
    id: 'req_001',
    patientId: 'p_001',
    patientName: 'Ravi',
    age: 45,
    symptoms: 'Fever, cough, body pain since 3 days',
    priority: 'normal',
    status: 'pending',
    time: '2026-04-22T10:30:00Z',
    assistantNotes: 'Patient has mild wheezing. Temperature: 101F.',
  },
  {
    id: 'req_002',
    patientId: 'p_002',
    patientName: 'Anita',
    age: 32,
    symptoms: 'Severe abdominal pain, vomiting',
    priority: 'emergency',
    status: 'pending',
    time: '2026-04-22T11:15:00Z',
    assistantNotes: 'Tenderness in lower right abdomen.',
  }
];

router.get('/requests', (req, res) => {
  res.json({ success: true, data: mockRequests });
});

router.get('/patient/:id', (req, res) => {
  const { id } = req.params;
  // Mock patient data
  const patients = {
    'p_001': { id: 'p_001', name: 'Ravi', age: 45, medicalHistory: ['Hypertension'], vitals: { BP: '130/85', Temp: '101 F' } },
    'p_002': { id: 'p_002', name: 'Anita', age: 32, medicalHistory: [], vitals: { BP: '110/70', Temp: '99 F' } },
  };
  const patient = patients[id] || { id, name: 'Unknown', age: 0 };
  res.json({ success: true, data: patient });
});

router.post('/prescription', (req, res) => {
  const { patientId, medicines, notes } = req.body;
  console.log(`Prescription for ${patientId}: ${medicines.join(', ')}`);
  res.json({ success: true, message: 'Prescription submitted successfully' });
});

router.post('/lab', (req, res) => {
  const { patientId, testName } = req.body;
  console.log(`Lab suggestion for ${patientId}: ${testName}`);
  res.json({ success: true, message: 'Lab test suggested' });
});

router.post('/hospital', (req, res) => {
  const { patientId, reason } = req.body;
  console.log(`Hospital referral for ${patientId}: ${reason}`);
  res.json({ success: true, message: 'Hospital referral sent' });
});

// ── Appointments ──────────────────────────────────────────────────────────────
const mockAppointments = [
  { id: 'appt_001', patientName: 'Arjun Sharma', patientAge: 34, date: '2026-04-17', time: '11:30 AM', duration: 30, type: 'in-person', status: 'confirmed', reason: 'Chest pain follow-up', notes: '' },
  { id: 'appt_002', patientName: 'Priya Menon', patientAge: 28, date: '2026-04-17', time: '02:00 PM', duration: 30, type: 'online', status: 'pending', reason: 'Routine checkup', notes: '' },
  { id: 'appt_003', patientName: 'Rahul Dev', patientAge: 45, date: '2026-04-17', time: '04:30 PM', duration: 45, type: 'in-person', status: 'pending', reason: 'Hypertension management', notes: '' },
  { id: 'appt_004', patientName: 'Kavya Nair', patientAge: 31, date: '2026-04-18', time: '10:00 AM', duration: 30, type: 'online', status: 'confirmed', reason: 'Cardiology consultation', notes: '' },
  { id: 'appt_005', patientName: 'Suresh Kumar', patientAge: 52, date: '2026-04-16', time: '09:00 AM', duration: 30, type: 'in-person', status: 'completed', reason: 'ECG review', notes: 'Prescribed Metoprolol 25mg. Follow up in 2 weeks.' },
  { id: 'appt_006', patientName: 'Ananya Singh', patientAge: 22, date: '2026-04-15', time: '03:00 PM', duration: 30, type: 'online', status: 'cancelled', reason: 'Palpitations', notes: '' },
  { id: 'appt_007', patientName: 'Mohan Raj', patientAge: 60, date: '2026-04-14', time: '11:00 AM', duration: 60, type: 'in-person', status: 'completed', reason: 'Post-surgery follow-up', notes: 'Recovery on track. Resume normal activity.' },
];

router.get('/appointments', (req, res) => {
  const { status, date } = req.query;
  let filtered = [...mockAppointments];
  if (status) filtered = filtered.filter(a => a.status === status);
  if (date) filtered = filtered.filter(a => a.date === date);
  res.json({ success: true, data: filtered });
});

router.patch('/appointments/:id', (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  const validStatuses = ['confirmed', 'completed', 'cancelled', 'no_show'];
  if (!validStatuses.includes(status)) {
    return res.status(400).json({ error: `Invalid status. Must be one of: ${validStatuses.join(', ')}` });
  }
  const appt = mockAppointments.find(a => a.id === id);
  if (!appt) return res.status(404).json({ error: 'Appointment not found' });
  appt.status = status;
  res.json({ success: true, data: appt });
});

router.post('/appointments/:id/notes', (req, res) => {
  const { id } = req.params;
  const { notes } = req.body;
  const appt = mockAppointments.find(a => a.id === id);
  if (!appt) return res.status(404).json({ error: 'Appointment not found' });
  appt.notes = notes;
  res.json({ success: true, data: appt });
});

// ── Availability Rules ────────────────────────────────────────────────────────
const availabilityRules = [
  { id: 'rule_001', dayOfWeek: 1, startTime: '09:00', endTime: '17:00', slotDuration: 30 }, // Monday
  { id: 'rule_002', dayOfWeek: 2, startTime: '09:00', endTime: '13:00', slotDuration: 30 }, // Tuesday
  { id: 'rule_003', dayOfWeek: 3, startTime: '10:00', endTime: '18:00', slotDuration: 45 }, // Wednesday
  { id: 'rule_004', dayOfWeek: 5, startTime: '09:00', endTime: '12:00', slotDuration: 30 }, // Friday
];

router.get('/availability', (req, res) => {
  res.json({ success: true, data: availabilityRules });
});

router.post('/availability', (req, res) => {
  const { dayOfWeek, startTime, endTime, slotDuration } = req.body;
  // Check for overlap
  const overlap = availabilityRules.find(r => r.dayOfWeek === dayOfWeek);
  if (overlap) return res.status(409).json({ error: 'Availability rule for this day already exists. Update or delete the existing one.' });
  const newRule = { id: `rule_${Date.now()}`, dayOfWeek, startTime, endTime, slotDuration };
  availabilityRules.push(newRule);
  res.status(201).json({ success: true, data: newRule });
});

router.put('/availability/:id', (req, res) => {
  const rule = availabilityRules.find(r => r.id === req.params.id);
  if (!rule) return res.status(404).json({ error: 'Rule not found' });
  Object.assign(rule, req.body);
  res.json({ success: true, data: rule });
});

router.delete('/availability/:id', (req, res) => {
  const idx = availabilityRules.findIndex(r => r.id === req.params.id);
  if (idx === -1) return res.status(404).json({ error: 'Rule not found' });
  availabilityRules.splice(idx, 1);
  res.json({ success: true, message: 'Rule deleted' });
});

// ── Blocked Dates ─────────────────────────────────────────────────────────────
const blockedDates = [
  { id: 'block_001', date: '2026-04-21', reason: 'National Holiday' },
  { id: 'block_002', date: '2026-04-25', reason: 'Conference' },
];

router.get('/blocked-dates', (req, res) => {
  res.json({ success: true, data: blockedDates });
});

router.post('/blocked-dates', (req, res) => {
  const { date, reason } = req.body;
  const newBlock = { id: `block_${Date.now()}`, date, reason };
  blockedDates.push(newBlock);
  res.status(201).json({ success: true, data: newBlock });
});

router.delete('/blocked-dates/:id', (req, res) => {
  const idx = blockedDates.findIndex(b => b.id === req.params.id);
  if (idx === -1) return res.status(404).json({ error: 'Blocked date not found' });
  blockedDates.splice(idx, 1);
  res.json({ success: true, message: 'Unblocked' });
});

// ── Doctor Profile ────────────────────────────────────────────────────────────
let doctorProfile = {
  id: 'doc_001',
  name: 'Dr. Sarah Jenkins',
  email: 'sarah.jenkins@hyoid.com',
  phone: '+91 98765 43210',
  specialty: 'Cardiologist',
  qualifications: 'MBBS, MD (Cardiology), FACC',
  bio: 'Senior cardiologist with 12+ years of experience in interventional cardiology and heart failure management.',
  consultationFee: 800,
  hospital: 'Generic Hospital, Chennai',
  rating: 4.9,
  totalPatients: 1240,
  acceptingBookings: true,
};

router.get('/profile', (req, res) => {
  res.json({ success: true, data: doctorProfile });
});

router.put('/profile', (req, res) => {
  doctorProfile = { ...doctorProfile, ...req.body };
  res.json({ success: true, data: doctorProfile });
});

module.exports = router;
