// server.js (fixed)
require('dotenv').config(); // MUST be first

const express = require('express');
const app = express();

const cors = require('cors');
const connectDB = require('./config/db');
const authRoutes = require('./routes/authRoutes');

const port = process.env.PORT || 4000;

// Middleware
app.use(cors());
app.use(express.json()); // built-in body parser

// Connect to MongoDB (MONGO_URL will now be available)
connectDB();

// Routes
app.use('/api/v1/auth', authRoutes);

// Fallback for unknown routes (optional)
app.use((req, res) => res.status(404).json({ message: 'Not found' }));

// Start server
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
