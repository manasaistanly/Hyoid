/**
 * models/User.js
 * ─────────────────────────────────────────────────────────────
 * Core user document. Extended to support three auth providers:
 *   - email   : traditional email + password
 *   - google  : Google OAuth (no password stored)
 *   - phone   : OTP-based phone authentication (no password)
 *
 * Payment fields gate access to the app for new users:
 *   isPaid, paymentId, paymentDate
 *
 * email, password, phone, age are optional at schema level but
 * enforced in the controller per authProvider.
 * ─────────────────────────────────────────────────────────────
 */
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const UserSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Please add a name'],
      minlength: [2, 'Name must be at least 2 characters'],
    },

    // Optional for phone-auth users who may not have email
    email: {
      type: String,
      sparse: true,   // allows multiple null values (phone users won't have email)
      unique: true,
      match: [
        /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
        'Please add a valid email',
      ],
    },

    // Optional for Google/email users (not stored for Google/phone)
    password: {
      type: String,
      minlength: [8, 'Password must be at least 8 characters'],
      select: false,
    },

    // Optional for email-auth users; required for phone-auth users
    phone: {
      type: String,
      sparse: true,
      unique: true,
    },

    age: {
      type: Number,
      min: 1,
      max: 120,
    },

    gender: {
      type: String,
      enum: ['Male', 'Female', 'Other', ''],
      default: '',
    },

    bloodGroup: {
      type: String,
      default: '',
    },

    address: {
      type: String,
      default: '',
    },

    dateOfBirth: {
      type: String,
      default: '',
    },

    emergencyContact: {
      type: String,
      default: '',
    },

    role: {
      type: String,
      enum: ['patient', 'doctor', 'nurse', 'admin'],
      default: 'patient',
    },

    profileImage: {
      type: String,
      default: 'default.jpg',
    },

    isActive: {
      type: Boolean,
      default: true,
    },

    deviceToken: {
      type: String, // Firebase Cloud Messaging token
    },

    // ── Auth Provider ─────────────────────────────────────────
    authProvider: {
      type: String,
      enum: ['email', 'google', 'phone'],
      default: 'email',
    },

    // Google-specific — stores the Google `sub` ID
    googleId: {
      type: String,
      sparse: true,
      unique: true,
    },

    // ── Payment ───────────────────────────────────────────────
    isPaid: {
      type: Boolean,
      default: false,
    },

    paymentId: {
      type: String, // Razorpay payment_id after successful payment
    },

    paymentDate: {
      type: Date,
    },

    // Flag set to true on first creation, cleared after onboarding
    isNewUser: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

// Encrypt password before save (only when password field is present and modified)
UserSchema.pre('save', async function (next) {
  if (!this.isModified('password') || !this.password) {
    return next();
  }
  const salt = await bcrypt.genSalt(12);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

// Compare entered password with stored hash
UserSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('User', UserSchema);
