const express = require("express");
const {
  createProfile,
  getAllProfiles,
  getProfileById,
  updateProfile,
} = require("../controllers/profile.controller");

const router = express.Router();

router.post("/", createProfile);
router.get("/", getAllProfiles);
router.post("/getById", getProfileById);
router.put("/update", updateProfile);

module.exports = router;
