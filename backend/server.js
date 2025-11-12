// server.js (or index.js)

const express = require("express");
const dotenv = require("dotenv");
dotenv.config();
const cors = require("cors");
const bodyParser = require("body-parser");
const connectDB = require("./config/db");

// Import routes
const authRoutes = require("./routes/authRoutes");
const paymentRoutes = require('./routes/paymentRoutes');
const categoryRoutes = require("./routes/categoryRoutes");
const productRoutes = require("./routes/productRoutes");
const cartRoutes = require('./routes/cartRoutes');
const profileRoutes = require("./routes/profile.routes");
const addressRoutes = require("./routes/address.routes");


// Initialize environment variables


// Initialize app
const app = express();
const port = process.env.PORT || 5000;

// Middleware
app.use(cors({
  origin: "*", // for testing — allow all origins
  methods: ["GET", "POST", "PUT", "DELETE"],
  allowedHeaders: ["Content-Type", "Authorization"],
}));
app.use(express.json());
app.use(bodyParser.json());

// Connect to database
connectDB();

// Register Routes
app.use("/api/v1/auth", authRoutes);

app.use("/api/categories", categoryRoutes);
app.use("/api/products", productRoutes);
app.use('/api/v1/cart', cartRoutes);
app.use("/api/address", addressRoutes);
app.use("/api/profile", profileRoutes);

app.use('/api/v1/payments', paymentRoutes);


app.use((req, res) => res.status(404).json({ message: "Route not found" }));


app.listen(port, () => {
  console.log(`✅ Server is running on http://localhost:${port}`);
});
