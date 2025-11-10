// server.js (fixed)
require('dotenv').config(); // MUST be first

const express = require('express');
const app = express();

const cors = require('cors');
const connectDB = require('./config/db');
const authRoutes = require('./routes/authRoutes');
const payments = require('./routes/payments');

const port = process.env.PORT || 4000;


app.use(cors());
app.use(express.json());


connectDB();

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/payments', payments);


app.use((req, res) => res.status(404).json({ message: 'Not found' }));

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
