require('dotenv').config();
const mongoose = require('mongoose');
const Consultation = require('./models/Consultation');
const Service = require('./models/Service');
const LabTest = require('./models/LabTest');
const User = require('./models/User');

const doctorId = new mongoose.Types.ObjectId("662867890123456789012345");
const patientId1 = new mongoose.Types.ObjectId("662867890123456789012346");
const patientId2 = new mongoose.Types.ObjectId("662867890123456789012347");
const patientId3 = new mongoose.Types.ObjectId("662867890123456789012348");

async function seed() {
  await mongoose.connect(process.env.MONGODB_URI);
  console.log('Connected to MongoDB');

  // Clear existing
  await Consultation.deleteMany({});
  await Service.deleteMany({});
  await LabTest.deleteMany({});
  await User.deleteMany({});

  // 1. Seed Users
  const users = [
    {
      _id: doctorId,
      name: 'Dr. Sarah Jenkins',
      role: 'doctor',
      specialty: 'Cardiologist',
      qualifications: 'MBBS, MD (Cardiology), FACC',
      bio: 'Senior cardiologist with 12+ years of experience in interventional cardiology and heart failure management.',
      consultationFee: 800,
      acceptingBookings: true,
      safetyNumber: '+919876543210',
      rating: 4.9,
      totalPatients: 1240,
      licenseNumber: 'MC-12345'
    },
    {
      _id: patientId1,
      name: 'John Doe',
      role: 'patient',
      phone: '9876543210',
      bloodGroup: 'O+',
      dob: new Date('1990-05-15'),
      emergencyContact: '+919998887770',
      patientId: 'HY-293812'
    },
    {
      _id: patientId2,
      name: 'Jane Smith',
      role: 'patient',
      phone: '9123456780',
      bloodGroup: 'A-',
      dob: new Date('1985-11-20'),
      emergencyContact: '+918887776660',
      patientId: 'HY-102938'
    }
  ];
  await User.insertMany(users);
  console.log('Seeded Users');

  // 2. Seed Services
  const services = [
    { 
      name: 'Doctor Visit', 
      description: 'In-person consultation at clinic', 
      type: 'consultation', 
      price: 500, 
      icon: 'medical_services_rounded', 
      color: '#60A5FA' 
    },
    { 
      name: 'Online Consult', 
      description: 'Video call with a specialist', 
      type: 'online', 
      price: 300, 
      icon: 'videocam_rounded', 
      color: '#F97316' 
    },
    { 
      name: 'Home Visit', 
      description: 'Doctor visit at your home', 
      type: 'home_visit', 
      price: 1000, 
      icon: 'home_rounded', 
      color: '#10B981' 
    }
  ];
  await Service.insertMany(services);
  console.log('Seeded Services');

  // 2. Seed Lab Tests
  const labs = [
    { name: 'Blood Test', description: 'Complete Blood Count (CBC)', specimen: 'Blood', price: 450, category: 'General', icon: 'biotech_rounded' },
    { name: 'Sugar Test', description: 'Fasting Blood Sugar', specimen: 'Blood', price: 150, category: 'Diabetes', icon: 'opacity_rounded' },
    { name: 'ECG', description: 'Electrocardiogram', specimen: 'Non-invasive', price: 600, category: 'Cardiology', icon: 'monitor_heart_rounded' }
  ];
  await LabTest.insertMany(labs);
  console.log('Seeded Lab Tests');

  // 3. Seed Consultations
  const consultations = [
    {
      patientId: patientId1,
      doctorId: doctorId,
      symptoms: 'High fever and persistent cough',
      vitals: { bp: '120/80', sugar: '95', temperature: '102 F' },
      assistantNotes: 'Patient has been symptomatic for 3 days. Lung sounds slightly congested.',
      isEmergency: false,
      status: 'pending'
    },
    {
      patientId: patientId2,
      doctorId: doctorId,
      symptoms: 'Chest pain and shortness of breath',
      vitals: { bp: '150/95', sugar: '110', temperature: '98.6 F' },
      assistantNotes: 'Urgent: Patient reporting sharp pain. History of hypertension.',
      isEmergency: true,
      status: 'pending'
    },
    {
      patientId: patientId1,
      doctorId: doctorId,
      symptoms: 'Follow up - Blood pressure check',
      vitals: { bp: '140/90', sugar: '90', temperature: '98.4 F' },
      assistantNotes: 'Routine checkup. Vitals stable.',
      status: 'completed',
      prescription: {
        medicines: [{ name: 'Amlodipine', dosage: '5mg', duration: '30 days' }],
        notes: 'Continue current medication.'
      }
    }
  ];

  await Consultation.insertMany(consultations);
  console.log('Seeded Consultations');
  
  await mongoose.disconnect();
}

seed().catch(err => console.error(err));
