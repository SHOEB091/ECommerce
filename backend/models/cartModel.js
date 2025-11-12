// models/cartModel.js
const mongoose = require('mongoose');

const CartItemSchema = new mongoose.Schema({
  productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
  qty: { type: Number, default: 1, min: 1 },
  // optional cached price (paise) so frontend can show totals quickly
  priceInPaise: { type: Number, default: 0 }
}, { _id: false });

const CartSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
  items: { type: [CartItemSchema], default: [] }
}, { timestamps: true });

module.exports = mongoose.model('Cart', CartSchema);
