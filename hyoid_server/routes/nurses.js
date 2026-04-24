const express = require('express');
const router = express.Router();
const Nurse = require('../models/Nurse');
const auth = require('../middleware/auth'); // Assuming auth middleware exists

// GET /nurses - Get all nurses with filters
router.get('/', async (req, res) => {
  try {
    const { service, experience, gender, language, rating, sort, page = 1, limit = 10 } = req.query;
    let query = { verified: true, availability: true };

    if (service) query.specializations = { $in: [service] };
    if (experience) query.experience = { $gte: parseInt(experience) };
    if (rating) query.rating = { $gte: parseFloat(rating) };

    let sortOption = {};
    if (sort === 'price') sortOption.hourlyRate = 1;
    else if (sort === 'rating') sortOption.rating = -1;
    else if (sort === 'distance') sortOption.location = 1; // Need to implement geo sorting

    const nurses = await Nurse.find(query)
      .sort(sortOption)
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Nurse.countDocuments(query);

    res.json({ nurses, totalPages: Math.ceil(total / limit), currentPage: page });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /nurses/:id - Get nurse by ID
router.get('/:id', async (req, res) => {
  try {
    const nurse = await Nurse.findById(req.params.id);
    if (!nurse) return res.status(404).json({ error: 'Nurse not found' });
    res.json(nurse);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /nurses - Create nurse (admin approval required)
router.post('/', auth, async (req, res) => {
  try {
    const nurse = new Nurse(req.body);
    await nurse.save();
    res.status(201).json(nurse);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// PATCH /nurses/:id/verify - Verify nurse (admin only)
router.patch('/:id/verify', auth, async (req, res) => {
  try {
    const nurse = await Nurse.findByIdAndUpdate(req.params.id, { verified: true }, { new: true });
    if (!nurse) return res.status(404).json({ error: 'Nurse not found' });
    res.json(nurse);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;