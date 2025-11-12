// controllers/cartController.js
const Cart = require('../models/cartModel');
const Product = require('../models/productModel');

/**
 * Helper: convert product.price (assumed rupees/units) to paise (integer)
 */
const toPaise = price => {
  const n = Number(price || 0);
  return Math.round(n * 100);
};

exports.getCart = async (req, res) => {
  try {
    const userId = req.user._id;
    let cart = await Cart.findOne({ user: userId }).populate('items.productId', 'name price image');
    if (!cart) {
      cart = await Cart.create({ user: userId, items: [] });
      cart = await cart.populate('items.productId', 'name price image');
    }
    return res.json({ success: true, cart });
  } catch (err) {
    console.error('getCart error', err);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
};

exports.addItem = async (req, res) => {
  try {
    const userId = req.user._id;
    const { productId, qty = 1 } = req.body;
    if (!productId) return res.status(400).json({ success: false, message: 'productId is required' });

    // Validate product exists
    const product = await Product.findById(productId);
    if (!product) return res.status(404).json({ success: false, message: 'Product not found' });

    // Get or create cart
    let cart = await Cart.findOne({ user: userId });
    if (!cart) cart = new Cart({ user: userId, items: [] });

    const existing = cart.items.find(i => i.productId.equals(productId));
    if (existing) {
      existing.qty = existing.qty + Number(qty);
    } else {
      cart.items.push({
        productId,
        qty: Number(qty),
        priceInPaise: toPaise(product.price)
      });
    }

    await cart.save();
    const populated = await cart.populate('items.productId', 'name price image');
    return res.json({ success: true, message: 'Item added to cart', cart: populated });
  } catch (err) {
    console.error('addItem error', err);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
};

exports.updateItem = async (req, res) => {
  try {
    const userId = req.user._id;
    const { productId } = req.params;
    const { qty } = req.body;

    if (qty == null) return res.status(400).json({ success: false, message: 'qty is required' });

    const cart = await Cart.findOne({ user: userId });
    if (!cart) return res.status(404).json({ success: false, message: 'Cart not found' });

    const idx = cart.items.findIndex(i => i.productId.equals(productId));
    if (idx === -1) return res.status(404).json({ success: false, message: 'Item not in cart' });

    if (Number(qty) <= 0) {
      cart.items.splice(idx, 1);
    } else {
      cart.items[idx].qty = Number(qty);
    }

    await cart.save();
    const populated = await cart.populate('items.productId', 'name price image');
    return res.json({ success: true, message: 'Cart updated', cart: populated });
  } catch (err) {
    console.error('updateItem error', err);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
};

exports.removeItem = async (req, res) => {
  try {
    const userId = req.user._id;
    const { productId } = req.params;

    const cart = await Cart.findOne({ user: userId });
    if (!cart) return res.status(404).json({ success: false, message: 'Cart not found' });

    cart.items = cart.items.filter(i => !i.productId.equals(productId));
    await cart.save();
    const populated = await cart.populate('items.productId', 'name price image');
    return res.json({ success: true, message: 'Item removed', cart: populated });
  } catch (err) {
    console.error('removeItem error', err);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
};

exports.clearCart = async (req, res) => {
  try {
    const userId = req.user._id;
    const cart = await Cart.findOneAndUpdate({ user: userId }, { items: [] }, { new: true, upsert: true });
    return res.json({ success: true, message: 'Cart cleared', cart });
  } catch (err) {
    console.error('clearCart error', err);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
};
