const Voucher = require("../models/voucher.model");

// Get user's vouchers
exports.getUserVouchers = async (req, res) => {
  try {
    const userId = req.user && req.user._id;
    if (!userId) {
      return res.status(401).json({ success: false, message: "Unauthorized" });
    }

    const vouchers = await Voucher.find({
      userId,
      expiryDate: { $gte: new Date() }, // Only non-expired vouchers
      isUsed: false,
    }).sort({ createdAt: -1 });

    res.json({ success: true, vouchers, count: vouchers.length });
  } catch (error) {
    console.error("getUserVouchers error:", error);
    res.status(500).json({ success: false, message: "Failed to load vouchers" });
  }
};

// Create a voucher (admin only or system generated)
exports.createVoucher = async (req, res) => {
  try {
    const userId = req.user && req.user._id;
    if (!userId) {
      return res.status(401).json({ success: false, message: "Unauthorized" });
    }

    const { code, discount, discountType, minPurchase, maxDiscount, expiryDate } = req.body;

    const voucher = await Voucher.create({
      userId,
      code: code || `VOUCHER${Date.now()}`,
      discount,
      discountType: discountType || "percentage",
      minPurchase: minPurchase || 0,
      maxDiscount,
      expiryDate: expiryDate || new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days default
    });

    res.status(201).json({ success: true, voucher });
  } catch (error) {
    console.error("createVoucher error:", error);
    res.status(500).json({ success: false, message: "Failed to create voucher" });
  }
};

