const Address = require("../models/address.model");
const { protect } = require("../middleware/authMiddleware");

// Get user's addresses
exports.getAddresses = async (req, res) => {
  try {
    const userId = req.user && req.user._id;
    if (!userId) {
      return res.status(401).json({ success: false, message: "Unauthorized" });
    }

    const addresses = await Address.find({ userId }).sort({ createdAt: -1 });
    res.json({ success: true, addresses, count: addresses.length });
  } catch (error) {
    console.error("getAddresses error:", error);
    res.status(500).json({ success: false, message: "Failed to load addresses" });
  }
};

// Add new address
exports.createAddress = async (req, res) => {
  try {
    const userId = req.user && req.user._id;
    if (!userId) {
      return res.status(401).json({ success: false, message: "Unauthorized" });
    }

    const address = await Address.create({ ...req.body, userId });
    res.status(201).json({ success: true, address });
  } catch (error) {
    console.error("createAddress error:", error);
    res.status(500).json({ success: false, message: "Failed to create address" });
  }
};

// Update address
exports.updateAddress = async (req, res) => {
  try {
    const userId = req.user && req.user._id;
    if (!userId) {
      return res.status(401).json({ success: false, message: "Unauthorized" });
    }

    const address = await Address.findOneAndUpdate(
      { _id: req.params.id, userId },
      req.body,
      { new: true }
    );

    if (!address) {
      return res.status(404).json({ success: false, message: "Address not found" });
    }

    res.json({ success: true, address });
  } catch (error) {
    console.error("updateAddress error:", error);
    res.status(500).json({ success: false, message: "Failed to update address" });
  }
};

// Delete address
exports.deleteAddress = async (req, res) => {
  try {
    const userId = req.user && req.user._id;
    if (!userId) {
      return res.status(401).json({ success: false, message: "Unauthorized" });
    }

    const address = await Address.findOneAndDelete({ _id: req.params.id, userId });

    if (!address) {
      return res.status(404).json({ success: false, message: "Address not found" });
    }

    res.json({ success: true, message: "Deleted successfully" });
  } catch (error) {
    console.error("deleteAddress error:", error);
    res.status(500).json({ success: false, message: "Failed to delete address" });
  }
};
