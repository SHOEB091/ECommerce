// server.js (or index.js)
const express = require("express");
const dotenv = require("dotenv");
const cors = require("cors");
const bodyParser = require("body-parser");
const connectDB = require("./config/db");

// Import routes
const authRoutes = require("./routes/authRoutes");
const payments = require("./routes/payments");
const categoryRoutes = require("./routes/categoryRoutes");
const productRoutes = require("./routes/productRoutes");

// Initialize environment variables
dotenv.config();

// Initialize app
const app = express();
const port = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(bodyParser.json());

// Connect to database
connectDB();

// Register Routes
app.use("/api/v1/auth", authRoutes);
app.use("/api/v1/payments", payments);
app.use("/api/categories", categoryRoutes);
app.use("/api/products", productRoutes);

// Handle invalid routes
app.use((req, res) => res.status(404).json({ message: "Route not found" }));

// Start Server
app.listen(port, () => {
  console.log(`✅ Server is running on http://localhost:${port}`);
});
