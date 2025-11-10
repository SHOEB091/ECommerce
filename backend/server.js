const express = require("express");
dotenv =  require("dotenv");
dotenv.config();
const app = express();
const port = process.env.PORT || 5000;
const bodyParser = require("body-parser");
const cors = require("cors");
const connectDB = require("./config/db");

// Middleware
app.use(cors());
app.use(bodyParser.json());
// Connect to MongoDB
connectDB();

app.use('/api/categories', require('./routes/categoryRoutes'));
app.use('/api/products', require('./routes/productRoutes'));

//server conection
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});