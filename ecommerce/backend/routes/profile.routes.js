const express = require("express");
const {
  createProfile,
  getAllProfiles,
  getProfileById,
  updateProfile,
  deleteProfile,
} = require("../controllers/profile.controller");

const router = express.Router();

// CRUD Routes
router.post("/", createProfile);        // Create
router.get("/", getAllProfiles);        // Read all
router.get("/:id", getProfileById);     // Read single
router.put("/:id", updateProfile);      // Update
router.delete("/:id", deleteProfile);   // Delete

module.exports = router;
