const express = require("express");
const {
  getAdminStats,
  getAllUsers,
  getAllOrders,
  updateOrderStatus,
} = require("../controllers/adminController");
const { protect, authorizeRoles } = require("../middleware/authMiddleware");

const router = express.Router();

router.use(protect, authorizeRoles("admin", "superadmin"));

router.get("/stats", getAdminStats);
router.get("/users", getAllUsers);
router.get("/orders", getAllOrders);
router.patch("/orders/:id", updateOrderStatus);

module.exports = router;

