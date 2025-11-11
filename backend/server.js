const express = require("express");
require('dotenv').config();
const app = express();
const port = process.env.PORT || 5000;
const cors = require("cors");
const connectDB = require("./config/db");
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

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
