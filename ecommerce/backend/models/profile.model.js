const mongoose = require("mongoose");

const profileSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    address: { type: String },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Profile", profileSchema);

