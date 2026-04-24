const mongoose = require('mongoose');
const Nurse = require('./models/Nurse');
require('dotenv').config();

const nurses = [
  {
    name: 'Priya Sharma',
    phone: '+91-9876543210',
    qualifications: ['GNM', 'BSc Nursing'],
    experience: 5,
    specializations: ['injection', 'wound care'],
    languages: ['English', 'Hindi'],
    verified: true,
    rating: 4.5,
    reviewCount: 25,
    hourlyRate: 50,
    availability: true,
    location: {
      type: 'Point',
      coordinates: [77.5946, 12.9716] // Bangalore coordinates
    },
    documents: {
      license: 'LIC123456',
      aadhaar: '123456789012'
    }
  },
  {
    name: 'Anjali Kumar',
    phone: '+91-9876543211',
    qualifications: ['BSc Nursing'],
    experience: 3,
    specializations: ['elderly care', 'post-surgery care'],
    languages: ['English', 'Kannada'],
    verified: true,
    rating: 4.2,
    reviewCount: 18,
    hourlyRate: 45,
    availability: true,
    location: {
      type: 'Point',
      coordinates: [77.5946, 12.9716]
    },
    documents: {
      license: 'LIC789012',
      aadhaar: '987654321098'
    }
  }
];

const seedNurses = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    // Clear existing nurses
    await Nurse.deleteMany({});
    console.log('Cleared existing nurses');

    await Nurse.insertMany(nurses);
    console.log('Nurses seeded successfully');

    mongoose.connection.close();
    console.log('Database connection closed');
  } catch (error) {
    console.error('Error seeding nurses:', error);
    process.exit(1);
  }
};

if (require.main === module) {
  seedNurses();
}