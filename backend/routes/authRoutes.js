const express = require("express");
const {
  sendEmailOtp,
  verifyEmailOtp,
  loginUser,
  getMe,
  updateMe,
} = require("../controllers/authController");
const { protect, authorizeRoles } = require("../middleware/authMiddleware");
const router = express.Router();

router.post("/email-send-otp", sendEmailOtp);
router.post("/email-verify-otp", verifyEmailOtp);

router.post("/login", loginUser);

router.get(
  "/user",
  protect,
  authorizeRoles("user", "admin", "superadmin"),
  (req, res) => {
    res.json({
      message: `Welcome ${req.user.name}, you are logged in as ${req.user.role}`,
    });
  }
);

router.get(
  "/admin",
  protect,
  authorizeRoles("admin", "superadmin"),
  (req, res) => {
    res.json({
      message: `Hello ${req.user.name}, this is the Admin route.`,
    });
  }
);

router.get("/me", protect, getMe);
router.put("/me", protect, updateMe);

module.exports = router;