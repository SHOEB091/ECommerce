const express = require("express");
const dotenv = require("dotenv");
const cors = require("cors");
const bodyParser = require("body-parser");
const connectDB = require("./config/db");


const authRoutes = require("./routes/authRoutes");
const payments = require("./routes/payments");
const categoryRoutes = require("./routes/categoryRoutes");
const productRoutes = require("./routes/productRoutes");


dotenv.config();


const app = express();
const port = process.env.PORT || 5000;


app.use(cors());
app.use(express.json());
app.use(bodyParser.json());


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
  console.log(`Server is running on port: ${port}`);
});