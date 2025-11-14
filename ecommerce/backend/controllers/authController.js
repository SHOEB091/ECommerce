// controllers/authController.js
const express = require("express");
const sendEmail = require("../utils/sendEmail");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const userModels = require("../models/userModels");
const EmailOtp = require("../models/emailOtpModel");

function geterateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Keep token payload minimal: only user id (no role added)
function signToken(userId) {
  return jwt.sign({ id: userId }, process.env.JWT_SECRET, { expiresIn: "7d" });
}

exports.sendEmailOtp = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email)
      return res
        .status(400)
        .json({ message: "email is required", success: false });

    const existingUser = await userModels.findOne({ email });
    if (existingUser)
      return res
        .status(400)
        .json({ message: "user already exists", success: false });

    const otp = geterateOtp();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);
    await EmailOtp.deleteMany({ email });
    await EmailOtp.create({ email, otp, expiresAt });

    await sendEmail(
      email,
      "Signup OTP",
      `Your OTP is ${otp}. It expires in 5 minutes.`
    );

    res.status(200).json({ message: "otp sent to email", success: true });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "unable to send otp", success: false });
  }
};

exports.verifyEmailOtp = async (req, res) => {
  try {
    const { email, otp, name, password } = req.body;
    if (!email || !otp || !name || !password)
      return res
        .status(400)
        .json({ message: "all fields are required", success: false });

    const record = await EmailOtp.findOne({ email });
    if (!record)
      return res.status(400).json({ message: "otp not found", success: false });
    if (record.otp !== otp)
      return res.status(400).json({ message: "invalid otp", success: false });
    if (record.expiresAt < new Date())
      return res.status(400).json({ message: "otp expired", success: false });

    const hashedPassword = await bcrypt.hash(password, 10);

    // create user (assumes your user model may set default role)
    const newUser = await userModels.create({
      name,
      email,
      password: hashedPassword,
      // do not add or force any extra fields here
    });

    await EmailOtp.deleteMany({ email });

    const token = signToken(newUser._id);

    // Return token AND user object (without sensitive fields)
    res.status(200).json({
      message: "user registered successfully",
      token,
      success: true,
      user: {
        id: newUser._id,
        name: newUser.name,
        email: newUser.email,
        role: newUser.role, // may be undefined if your schema doesn't define it — that's fine
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "unable to verify otp", success: false });
  }
};

exports.loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password)
      return res
        .status(400)
        .json({ message: "email and password are required", success: false });

    const user = await userModels.findOne({ email });
    if (!user)
      return res
        .status(400)
        .json({ message: "invalid credentials", success: false });

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid)
      return res
        .status(400)
        .json({ message: "invalid credentials", success: false });

    const token = signToken(user._id);

    // respond with token and user object (omit password)
    res.status(200).json({
      message: "login successful",
      token,
      success: true,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role, // this will be available if your user doc has role
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "unable to login", success: false });
  }
};

// Get current user profile
exports.getMe = async (req, res) => {
  try {
    // req.user is set by the protect middleware
    if (!req.user) {
      return res.status(401).json({ message: "Unauthorized", success: false });
    }

    // Return the user object (password already excluded by middleware)
    res.status(200).json({ success: true, user: req.user });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error", success: false });
  }
};
