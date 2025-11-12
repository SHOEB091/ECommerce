const Profile = require("../models/profile.model");

// ✅ Create profile
exports.createProfile = async (req, res) => {
  try {
    const profile = await Profile.create(req.body);
    res.status(201).json(profile);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// ✅ Get all profiles
exports.getAllProfiles = async (req, res) => {
  try {
    const profiles = await Profile.find();
    res.json(profiles);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ✅ Get profile by ID
exports.getProfileById = async (req, res) => {
  try {
    const profile = await Profile.findById(req.body.id);
    if (!profile) return res.status(404).json({ message: "Profile not found" });
    res.json(profile);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// ✅ Update profile
exports.updateProfile = async (req, res) => {
  try {
    const { userId, name, email, phone } = req.body;
    const profile = await Profile.findOneAndUpdate(
      { userId },
      { name, email, phone },
      { new: true, upsert: true }
    );
    res.status(200).json({ success: true, data: profile });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
