const express = require("express");
const router = express.Router();

const { createOrder, verifyPayment } = require("../controllers/paymentController");
const { protect } = require("../middleware/authMiddleware");

router.post("/order", protect, createOrder);
router.post("/create-order", protect, createOrder); // backwards compatibility
router.post("/verify", protect, verifyPayment);

module.exports = router;
