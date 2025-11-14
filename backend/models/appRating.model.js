const mongoose = require("mongoose");

const appRatingSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      unique: true, // One rating per user
    },
    rating: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
    },
    comment: {
      type: String,
      default: "",
    },
  },
  { timestamps: true }
);

// Static method to get average rating
appRatingSchema.statics.getAverageRating = async function () {
  const result = await this.aggregate([
    {
      $group: {
        _id: null,
        averageRating: { $avg: "$rating" },
        totalRatings: { $sum: 1 },
      },
    },
  ]);
  return result.length > 0
    ? {
        averageRating: result[0].averageRating,
        totalRatings: result[0].totalRatings,
      }
    : { averageRating: 0, totalRatings: 0 };
};

module.exports = mongoose.model("AppRating", appRatingSchema);

