const Address = require("../models/address.model");

// Get all addresses
exports.getAddresses = async (req, res) => {
  const addresses = await Address.find();
  res.json(addresses);
};

// Add new address
exports.createAddress = async (req, res) => {
  const address = new Address(req.body);
  await address.save();
  res.status(201).json(address);
};

// Update address
exports.updateAddress = async (req, res) => {
  const updated = await Address.findByIdAndUpdate(req.params.id, req.body, { new: true });
  res.json(updated);
};

// Delete address
exports.deleteAddress = async (req, res) => {
  await Address.findByIdAndDelete(req.params.id);
  res.json({ message: "Deleted successfully" });
};
