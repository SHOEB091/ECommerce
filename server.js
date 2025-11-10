const express = require("express");
const app = express();
const port = process.env.PORT || 4000;
const bodyParser = require("body-parser");
const cors = require("cors");
const connectDB = require("./config/db");

// Middleware
app.use(cors());
app.use(bodyParser.json());


// Connect to MongoDB
connectDB();


//server conection
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
