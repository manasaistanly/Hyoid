require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./models/User');
const Consultation = require('./models/Consultation');

async function createAssistant() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    // 1. Create Test Assistant
    const assistantPhone = '9999999999';
    const assistant = {
      name: 'Test Assistant',
      phone: assistantPhone,
      role: 'assistant',
    };

    const savedAssistant = await User.findOneAndUpdate(
      { phone: assistantPhone }, 
      assistant, 
      { upsert: true, new: true }
    );
    console.log('✅ Test Assistant created/updated: Test Assistant (9999999999)');

    // 2. Create a dummy patient if not exists for the consultation
    const patientPhone = '8888888888';
    const patient = await User.findOneAndUpdate(
      { phone: patientPhone },
      { name: 'Demo Patient', role: 'patient', phone: patientPhone, patientId: 'HY-000001' },
      { upsert: true, new: true }
    );

    // 3. Create an assigned consultation so the list isn't empty
    const consultation = {
      patientId: patient._id,
      assistantId: savedAssistant._id,
      symptoms: 'Patient has mild cough and fatigue.',
      status: 'assigned',
    };

    await Consultation.findOneAndUpdate(
      { assistantId: savedAssistant._id, status: 'assigned' },
      consultation,
      { upsert: true }
    );
    console.log('✅ Assigned a test consultation to the assistant.');

    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  } catch (err) {
    console.error('❌ Error:', err);
  }
}

createAssistant();
