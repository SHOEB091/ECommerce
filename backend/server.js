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
const orderRoutes = require("./routes/orderRoutes");
const categoryRoutes = require("./routes/categoryRoutes");
const productRoutes = require("./routes/productRoutes");
const cartRoutes = require('./routes/cartRoutes');
const profileRoutes = require("./routes/profile.routes");
const addressRoutes = require("./routes/address.routes");
const adminRoutes = require("./routes/adminRoutes");
const voucherRoutes = require("./routes/voucherRoutes");
const appRatingRoutes = require("./routes/appRatingRoutes");





// Initialize app
const app = express();
const port = process.env.PORT || 5000;

// Middleware
const allowedOrigins = process.env.FRONTEND_URL 
  ? process.env.FRONTEND_URL.split(',')
  : (process.env.NODE_ENV === 'production' ? [] : ['http://localhost:3000', 'http://localhost:8080']);

app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? allowedOrigins 
    : "*", // Allow all in development
  methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
  allowedHeaders: ["Content-Type", "Authorization"],
  credentials: true,
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
app.use("/api/v1/admin", adminRoutes);
app.use("/api/v1/vouchers", voucherRoutes);
app.use("/api/v1/ratings", appRatingRoutes);

app.use('/api/v1/payments', paymentRoutes);
app.use('/api/v1/orders', orderRoutes);


app.use((req, res) => res.status(404).json({ message: "Route not found" }));


app.listen(port, () => {
  console.log(`✅ Server is running on http://localhost:${port}`);
});
