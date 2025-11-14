const express = require("express");
const {
  getAddresses,
  createAddress,
  updateAddress,
  deleteAddress,
} = require("../controllers/address.controller");
const { protect } = require("../middleware/authMiddleware");

const router = express.Router();

router.use(protect); // Protect all address routes

router.get("/", getAddresses);
router.post("/", createAddress);
router.put("/:id", updateAddress);
router.delete("/:id", deleteAddress);

module.exports = router;
