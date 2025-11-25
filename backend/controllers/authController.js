// controllers/authController.js
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

    // Normalize email (lowercase, trim)
    const normalizedEmail = email.toLowerCase().trim();

    const existingUser = await userModels.findOne({ email: normalizedEmail });
    if (existingUser)
      return res
        .status(400)
        .json({ message: "user already exists", success: false });

    const otp = geterateOtp();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);
    
    // Delete any existing OTP for this email
    await EmailOtp.deleteMany({ email: normalizedEmail });
    
    // Create new OTP record
    await EmailOtp.create({ 
      email: normalizedEmail, 
      otp, 
      expiresAt,
      isLoginFlow: false // This is signup flow
    });

    console.log(`📧 Attempting to send OTP to ${normalizedEmail}`);

    // Send email with better error handling
    try {
      await sendEmail(
        normalizedEmail,
        "Signup OTP",
        `Your OTP is ${otp}. It expires in 5 minutes.`
      );
      console.log(`✅ OTP sent successfully to ${normalizedEmail}`);
    } catch (emailError) {
      console.error(`❌ Failed to send email to ${normalizedEmail}:`, emailError);
      // Delete the OTP record if email sending failed
      await EmailOtp.deleteMany({ email: normalizedEmail });
      return res.status(500).json({ 
        message: "unable to send otp email. Please check email configuration.", 
        success: false,
        error: process.env.NODE_ENV === 'development' ? emailError.message : undefined
      });
    }

    res.status(200).json({ message: "otp sent to email", success: true });
  } catch (error) {
    console.error("sendEmailOtp error:", error);
    res.status(500).json({ 
      message: "unable to send otp", 
      success: false,
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

exports.verifyEmailOtp = async (req, res) => {
  try {
    const { email, otp, name, password } = req.body;
    if (!email || !otp)
      return res
        .status(400)
        .json({ message: "email and otp are required", success: false });

    // Normalize email (lowercase, trim)
    const normalizedEmail = email.toLowerCase().trim();

    const record = await EmailOtp.findOne({ email: normalizedEmail });
    if (!record)
      return res.status(400).json({ message: "otp not found", success: false });
    if (record.otp !== otp)
      return res.status(400).json({ message: "invalid otp", success: false });
    if (record.expiresAt < new Date())
      return res.status(400).json({ message: "otp expired", success: false });

    // Check if this is a login flow (new email sign-in) or signup flow
    const isLoginFlow = record.isLoginFlow === true;
    
    // For login flow, use stored password; for signup flow, use provided password
    let hashedPassword;
    let userName = name;
    
    if (isLoginFlow) {
      // Login flow: password is already stored and hashed in the OTP record
      if (!record.password) {
        return res.status(400).json({ 
          message: "password not found in otp record", 
          success: false 
        });
      }
      hashedPassword = record.password;
      // For login flow, we might not have name, so we'll use email or a default
      if (!userName) {
        userName = email.split('@')[0]; // Use email prefix as default name
      }
    } else {
      // Signup flow: require name and password
      if (!name || !password)
        return res
          .status(400)
          .json({ message: "name and password are required for signup", success: false });
      hashedPassword = await bcrypt.hash(password, 10);
      userName = name;
    }

    // Check if user already exists (shouldn't happen, but safety check)
    const existingUser = await userModels.findOne({ email: normalizedEmail });
    if (existingUser) {
      await EmailOtp.deleteMany({ email: normalizedEmail });
      return res.status(400).json({ 
        message: "user already exists", 
        success: false 
      });
    }

    // create user (assumes your user model may set default role)
    const newUser = await userModels.create({
      name: userName,
      email: normalizedEmail,
      password: hashedPassword,
      // do not add or force any extra fields here
    });

    await EmailOtp.deleteMany({ email: normalizedEmail });

    const token = signToken(newUser._id);

    // Return token AND user object (without sensitive fields)
    res.status(200).json({
      message: isLoginFlow 
        ? "user registered and logged in successfully" 
        : "user registered successfully",
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

    // Normalize email (lowercase, trim)
    const normalizedEmail = email.toLowerCase().trim();
    
    const user = await userModels.findOne({ email: normalizedEmail });
    
    // If user doesn't exist, send OTP for new email sign-in
    if (!user) {
      const otp = geterateOtp();
      const expiresAt = new Date(Date.now() + 5 * 60 * 1000);
      
      // Delete any existing OTP for this email
      await EmailOtp.deleteMany({ email: normalizedEmail });
      
      // Store OTP with password and login flow flag
      const hashedPassword = await bcrypt.hash(password, 10);
      await EmailOtp.create({ 
        email: normalizedEmail, 
        otp, 
        expiresAt, 
        password: hashedPassword,
        isLoginFlow: true 
      });

      console.log(`📧 Attempting to send login OTP to ${normalizedEmail}`);

      // Send OTP email with better error handling
      try {
        await sendEmail(
          normalizedEmail,
          "Login OTP - New Email Verification",
          `Your OTP for sign-in is ${otp}. It expires in 5 minutes.`
        );
        console.log(`✅ Login OTP sent successfully to ${normalizedEmail}`);
      } catch (emailError) {
        console.error(`❌ Failed to send login OTP email to ${normalizedEmail}:`, emailError);
        // Delete the OTP record if email sending failed
        await EmailOtp.deleteMany({ email: normalizedEmail });
        return res.status(500).json({ 
          message: "unable to send otp email. Please check email configuration.", 
          success: false,
          requiresOtp: false,
          error: process.env.NODE_ENV === 'development' ? emailError.message : undefined
        });
      }

      return res.status(200).json({ 
        message: "otp sent to email for verification", 
        success: true,
        requiresOtp: true 
      });
    }

    // If user exists, proceed with normal login
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

// Optional helper endpoint (if you want later) — unchanged
exports.getMe = async (req, res) => {
  try {
    const userId = req.userId || (req.user && req.user.id) || (req.user && req.user._id);
    if (!userId) return res.status(401).json({ message: "Unauthorized", success: false });

    const user = await userModels.findById(userId).select("-password");
    if (!user) return res.status(404).json({ message: "User not found", success: false });

    res.status(200).json({ success: true, user });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error", success: false });
  }
};

exports.updateMe = async (req, res) => {
  try {
    const userId = req.user && req.user._id;
    if (!userId) return res.status(401).json({ success: false, message: "Unauthorized" });

    const updates = {};
    ["name", "email", "phone", "avatar"].forEach((field) => {
      if (req.body[field] !== undefined && req.body[field] !== null) {
        updates[field] = req.body[field];
      }
    });

    if (!Object.keys(updates).length) {
      return res.status(400).json({ success: false, message: "No fields provided" });
    }

    // Check for email uniqueness if email is being updated (exclude current user)
    if (updates.email) {
      const existingUser = await userModels.findOne({
        email: updates.email,
        _id: { $ne: userId }, // Exclude current user
      });
      if (existingUser) {
        return res.status(400).json({
          success: false,
          message: "Email already exists. Please use a different email.",
        });
      }
    }

    // Note: We don't check name uniqueness since multiple users can have the same name
    // If there's a unique index on name in the database, it needs to be dropped

    const updated = await userModels
      .findByIdAndUpdate(userId, updates, { new: true, runValidators: true })
      .select("-password");

    if (!updated) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    res.status(200).json({ success: true, user: updated });
  } catch (error) {
    console.error("updateMe error", error);
    
    // Handle duplicate key error specifically
    if (error.code === 11000) {
      const field = Object.keys(error.keyPattern || {})[0] || "field";
      return res.status(400).json({
        success: false,
        message: `This ${field} is already taken. Please choose a different ${field}.`,
      });
    }
    
    res.status(500).json({ success: false, message: error.message || "Unable to update profile" });
  }
};
