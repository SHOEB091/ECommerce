const express = require("express");
const router = express.Router();

const { createOrder, verifyPayment, getAllPayments, cancelPayment } = require("../controllers/paymentController");
const { protect, authorizeRoles } = require("../middleware/authMiddleware");

router.post("/order", protect, createOrder);
router.post("/create-order", protect, createOrder); // backwards compatibility
router.post("/verify", protect, verifyPayment);
router.post("/cancel", protect, cancelPayment);
router.get("/all", protect, authorizeRoles("admin", "superadmin"), getAllPayments);

module.exports = router;
