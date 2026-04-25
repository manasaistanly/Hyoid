require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: '*' } });

app.use(cors());
app.use(express.json());

// Logging Middleware
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
    next();
});

// Routes mapping
app.use('/api/auth', require('./routes/auth'));
app.use('/api/bookings', require('./routes/bookings'));
app.use('/api/sos', require('./routes/sos'));
app.use('/api/tracking', require('./routes/tracking'));
app.use('/api/vitals', require('./routes/vitals'));
app.use('/api/doctor', require('./routes/doctor'));
app.use('/api/services', require('./routes/services'));
app.use('/api/labs', require('./routes/labs'));

// Initializing WebSockets
require('./sockets/vitals')(io);
require('./sockets/tracking')(io);

mongoose.connect(process.env.MONGODB_URI)
    .then(() => console.log('MongoDB Connected'))
    .catch(err => console.error(err));

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
