const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/authMiddleware");
const {
  getUserRating,
  submitRating,
  getAppRatingStats,
} = require("../controllers/appRatingController");

router.get("/", protect, getUserRating);
router.post("/", protect, submitRating);
router.get("/stats", getAppRatingStats); // Public endpoint

module.exports = router;

