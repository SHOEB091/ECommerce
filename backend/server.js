const express = require("express");
dotenv =  require("dotenv");
dotenv.config();
const app = express();
const port = process.env.PORT || 5000;
const bodyParser = require("body-parser");
const cors = require("cors");
const connectDB = require("./config/db");
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
app.use(bodyParser.json());
// Connect to MongoDB
connectDB();

app.use('/api/categories', require('./routes/categoryRoutes'));
app.use('/api/products', require('./routes/productRoutes'));
app.use(express.json());


connectDB();

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/payments', payments);


app.use((req, res) => res.status(404).json({ message: 'Not found' }));

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
