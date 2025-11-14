const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/authMiddleware");
const { getUserVouchers, createVoucher } = require("../controllers/voucherController");

router.get("/", protect, getUserVouchers);
router.post("/", protect, createVoucher);

module.exports = router;

