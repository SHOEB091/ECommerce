const mongoose = require("mongoose");

const emailOtpSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  otp: { type: String, required: true },
  expiresAt: { type: Date, required: true },
  password: { type: String }, // Store password temporarily for login flow when email doesn't exist
  isLoginFlow: { type: Boolean, default: false }, // Flag to distinguish login vs signup flow
});

module.exports = mongoose.model("EmailOtp", emailOtpSchema);
