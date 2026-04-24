const express = require('express');
const { getProfile, updateProfile, uploadAvatar } = require('../controllers/userController');
const { protect } = require('../middleware/auth');
const { upload } = require('../middleware/upload');

const router = express.Router();

router.route('/profile')
  .get(protect, getProfile)
  .put(protect, updateProfile);

router.post('/upload-avatar', protect, upload.single('profileImage'), uploadAvatar);

module.exports = router;
