require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./models/User');

async function addTestData() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    // 1. Create a Test Doctor
    const testDoctor = {
      name: 'Dr. Alice Brown',
      phone: '1112223330',
      role: 'doctor',
      specialty: 'Dermatologist',
      qualifications: 'MBBS, MD',
      licenseNumber: 'DOC-998877',
      experienceYears: 8,
      consultationFee: 600,
      bio: 'Expert in skin care and laser treatments.',
      safetyNumber: '+919876543211'
    };

    // 2. Create a Test Patient
    const testPatient = {
      name: 'Bob Wilson',
      phone: '5556667770',
      role: 'patient',
      bloodGroup: 'B+',
      dob: new Date('1995-08-25'),
      emergencyContact: '+917776665550',
      patientId: 'HY-556677'
    };

    // Upsert (update if exists, insert if not) based on phone
    await User.findOneAndUpdate({ phone: testDoctor.phone }, testDoctor, { upsert: true, new: true });
    console.log('✅ Test Doctor added/updated: Dr. Alice Brown (1112223330)');

    await User.findOneAndUpdate({ phone: testPatient.phone }, testPatient, { upsert: true, new: true });
    console.log('✅ Test Patient added/updated: Bob Wilson (5556667770)');

    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  } catch (err) {
    console.error('❌ Error adding test data:', err);
    process.exit(1);
  }
}

addTestData();
