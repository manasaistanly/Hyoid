const mongoose = require('mongoose');
const Doctor = require('./models/Doctor');
require('dotenv').config();

const sampleDoctors = [
  {
    name: 'Dr. Sarah Jenkins',
    specialization: 'Cardiology',
    experience: '12 years',
    rating: 4.8,
    reviewCount: 156,
    profileImage: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400',
    bio: 'Experienced cardiologist specializing in preventive care and heart disease management.',
    qualifications: ['MBBS', 'MD Cardiology', 'FACC'],
    languages: ['English', 'Hindi'],
    availabilityStatus: 'available',
    isOnline: true,
    consultationFee: 800,
    availableSlots: [
      { dateTime: new Date(Date.now() + 24 * 60 * 60 * 1000), isAvailable: true }, // Tomorrow
      { dateTime: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000), isAvailable: true }, // Day after
    ],
  },
  {
    name: 'Dr. Michael Chen',
    specialization: 'General Medicine',
    experience: '8 years',
    rating: 4.6,
    reviewCount: 89,
    profileImage: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400',
    bio: 'Family physician providing comprehensive healthcare for all ages.',
    qualifications: ['MBBS', 'MD General Medicine'],
    languages: ['English', 'Tamil'],
    availabilityStatus: 'busy',
    isOnline: true,
    consultationFee: 500,
    availableSlots: [
      { dateTime: new Date(Date.now() + 12 * 60 * 60 * 1000), isAvailable: true }, // 12 hours from now
    ],
  },
  {
    name: 'Dr. Priya Sharma',
    specialization: 'Dermatology',
    experience: '10 years',
    rating: 4.9,
    reviewCount: 203,
    profileImage: 'https://images.unsplash.com/photo-1594824804732-ca8db723f8fa?w=400',
    bio: 'Dermatologist specializing in skin care, acne treatment, and cosmetic procedures.',
    qualifications: ['MBBS', 'MD Dermatology', 'DDV'],
    languages: ['English', 'Hindi', 'Tamil'],
    availabilityStatus: 'available',
    isOnline: false,
    consultationFee: 700,
    availableSlots: [
      { dateTime: new Date(Date.now() + 48 * 60 * 60 * 1000), isAvailable: true }, // 2 days from now
    ],
  },
  {
    name: 'Dr. Rajesh Kumar',
    specialization: 'Pediatrics',
    experience: '15 years',
    rating: 4.7,
    reviewCount: 178,
    profileImage: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400',
    bio: 'Pediatrician dedicated to child health and development.',
    qualifications: ['MBBS', 'MD Pediatrics', 'DCH'],
    languages: ['English', 'Tamil', 'Telugu'],
    availabilityStatus: 'offline',
    isOnline: false,
    consultationFee: 600,
    availableSlots: [
      { dateTime: new Date(Date.now() + 72 * 60 * 60 * 1000), isAvailable: true }, // 3 days from now
    ],
  },
];

async function seedDoctors() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    // Clear existing doctors
    await Doctor.deleteMany({});
    console.log('Cleared existing doctors');

    // Insert sample doctors
    await Doctor.insertMany(sampleDoctors);
    console.log('Sample doctors inserted successfully');

    mongoose.connection.close();
    console.log('Database connection closed');
  } catch (error) {
    console.error('Error seeding doctors:', error);
    process.exit(1);
  }
}

if (require.main === module) {
  seedDoctors();
}

module.exports = { seedDoctors, sampleDoctors };