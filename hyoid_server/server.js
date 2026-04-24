require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const mongoSanitize = require('express-mongo-sanitize');
const rateLimit = require('express-rate-limit');
const http = require('http');
const { Server } = require('socket.io');

const connectDB = require('./config/db');
const errorHandler = require('./middleware/errorHandler');

// Connect to DB
connectDB();

const app = express();

// Security middlewares
app.use(helmet());
app.use(mongoSanitize());

const limiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 100 });
app.use(limiter);

// Body parser
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// CORS Configuration
app.use(cors({
  origin: '*', // Allow all origins for development
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

// Route files
const auth = require('./routes/auth');
const users = require('./routes/users');
const appointments = require('./routes/appointments');
const notifications = require('./routes/notifications');
const payment = require('./routes/payment');

// Mount routers
app.use('/api/auth', auth);
app.use('/api/users', users);
app.use('/api/appointments', appointments);
app.use('/api/notifications', notifications);
app.use('/api/payment', payment);

// Error handling middleware
app.use(errorHandler);

const server = http.createServer(app);

// Socket.io initialization
const io = new Server(server, { cors: { origin: '*' } });

// Attach io to app so default router / controller can use it
app.set('io', io);

io.on('connection', (socket) => {
  console.log(`Socket connected: ${socket.id}`);
  
  socket.on('join', (room) => {
    socket.join(room);
    console.log(`Socket ${socket.id} joined room: ${room}`);
  });

  socket.on('disconnect', () => {
    console.log('User disconnected', socket.id);
  });
});

const PORT = process.env.PORT || 3000;

server.listen(PORT, console.log(`Server running on port ${PORT}`));
