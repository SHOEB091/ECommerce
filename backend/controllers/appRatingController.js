const AppRating = require("../models/appRating.model");

// Get user's rating
exports.getUserRating = async (req, res) => {
  try {
    const userId = req.user && req.user._id;
    if (!userId) {
      return res.status(401).json({ success: false, message: "Unauthorized" });
    }

    const rating = await AppRating.findOne({ userId });
    const stats = await AppRating.getAverageRating();

    res.json({
      success: true,
      userRating: rating,
      averageRating: stats.averageRating,
      totalRatings: stats.totalRatings,
    });
  } catch (error) {
    console.error("getUserRating error:", error);
    res.status(500).json({ success: false, message: "Failed to load rating" });
  }
};

// Submit or update rating
exports.submitRating = async (req, res) => {
  try {
    const userId = req.user && req.user._id;
    if (!userId) {
      return res.status(401).json({ success: false, message: "Unauthorized" });
    }

    const { rating, comment } = req.body;

    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({ success: false, message: "Rating must be between 1 and 5" });
    }

    const userRating = await AppRating.findOneAndUpdate(
      { userId },
      { rating, comment: comment || "" },
      { new: true, upsert: true }
    );

    const stats = await AppRating.getAverageRating();

    res.json({
      success: true,
      userRating,
      averageRating: stats.averageRating,
      totalRatings: stats.totalRatings,
    });
  } catch (error) {
    console.error("submitRating error:", error);
    res.status(500).json({ success: false, message: "Failed to submit rating" });
  }
};

// Get overall app rating stats (public)
exports.getAppRatingStats = async (req, res) => {
  try {
    const stats = await AppRating.getAverageRating();
    res.json({ success: true, ...stats });
  } catch (error) {
    console.error("getAppRatingStats error:", error);
    res.status(500).json({ success: false, message: "Failed to load rating stats" });
  }
};

