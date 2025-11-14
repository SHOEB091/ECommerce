// controllers/paymentController.js
const Razorpay = require('razorpay');
const crypto = require('crypto');
const Cart = require('../models/cartModel');
const Product = require('../models/productModel');
const Order = require('../models/Order');

const { RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET } = process.env;

let razorpay = null;
if (RAZORPAY_KEY_ID && RAZORPAY_KEY_SECRET) {
  razorpay = new Razorpay({
    key_id: RAZORPAY_KEY_ID,
    key_secret: RAZORPAY_KEY_SECRET,
  });
} else {
  console.warn('⚠️ Razorpay keys not found in env. Payments will be disabled until configured.');
}

function toPaiseFromNumber(n) {
  return Math.round(Number(n || 0) * 100);
}

function shortReceipt(userId) {
  const u = String(userId).slice(-6);
  const rand = crypto.randomBytes(3).toString('hex'); // 6 hex chars
  return `r_${u}_${rand}`; // short and unique, well under 40 chars
}

/**
 * Create Razorpay order from the user's cart.
 * Expects req.user to be populated by auth middleware (protect).
 */
exports.createOrder = async (req, res) => {
  try {
    if (!razorpay) return res.status(500).json({ success: false, message: 'Payment provider not configured' });

    const userId = req.user && req.user._id;
    if (!userId) return res.status(401).json({ success: false, message: 'User not authenticated' });

    const address = req.body && req.body.address;
    if (!address || !address.fullName || !address.line1 || !address.city || !address.postalCode || !address.phone) {
      return res.status(400).json({ success: false, message: 'Shipping address is required' });
    }

    // fetch cart (attempt to populate product details)
    const cart = await Cart.findOne({ user: userId }).populate('items.productId', 'price name');
    if (!cart || !Array.isArray(cart.items) || cart.items.length === 0) {
      return res.status(400).json({ success: false, message: 'Cart is empty. Add items before creating order.' });
    }

    let totalPaise = 0;
    const debugItems = [];
    const itemsSnapshot = [];
    const cleanedCartItems = [];
    let removedCount = 0;

    for (const it of cart.items) {
      let unitPaise = 0;
      let productName = '';
      let productIdValue = it.productId;

      if (productIdValue && typeof productIdValue === 'object' && productIdValue._id) {
        productIdValue = productIdValue._id;
      }

      try {
        // prefer populated product price
        if (it.productId && typeof it.productId === 'object' && it.productId.price != null) {
          unitPaise = toPaiseFromNumber(it.productId.price);
          productName = it.productId.name || String(it.productId._id || '');
          productIdValue = it.productId._id || it.productId.id || it.productId.toString();
        } else if (it.price != null) {
          // cart item snapshot price (in rupees)
          unitPaise = toPaiseFromNumber(it.price);
          productName = it.title || '';
        } else if (it.priceInPaise != null) {
          unitPaise = parseInt(it.priceInPaise, 10);
          productName = it.title || '';
        } else if (it.productId && typeof it.productId === 'string') {
          // fallback: query product
          const p = await Product.findById(it.productId).select('price name');
          if (p && p.price != null) {
            unitPaise = toPaiseFromNumber(p.price);
            productName = p.name || String(p._id);
            productIdValue = p._id;
          }
        }
      } catch (err) {
        console.error('price-resolve error for item', err);
      }

      const qty = Number(it.qty || it.quantity || 1);
      const itemTotal = (unitPaise || 0) * Math.max(1, qty);
      debugItems.push({ productId: productIdValue || it.productId, name: productName, unitPaise, qty, itemTotal });

      if (!productIdValue) {
        removedCount += 1;
        continue;
      }

      totalPaise += itemTotal;

      itemsSnapshot.push({
        productId: productIdValue,
        name: productName || 'Item',
        price: (unitPaise || 0) / 100,
        qty: Math.max(1, qty),
      });

      cleanedCartItems.push(it);
    }

    console.log('createOrder debugItems:', JSON.stringify(debugItems));
    console.log('createOrder totalPaise computed =', totalPaise);

    if (removedCount > 0) {
      cart.items = cleanedCartItems;
      await cart.save();
      console.log(`createOrder: removed ${removedCount} stale cart item(s) with missing product references`);
    }

    if (itemsSnapshot.length === 0 || totalPaise <= 0) {
      return res.status(400).json({ success: false, message: 'Cart total invalid (0). Check product prices.' });
    }

    const receipt = shortReceipt(userId);
    const options = {
      amount: totalPaise,
      currency: 'INR',
      receipt,
      // payment_capture: 1 // optional: auto-capture payments
    };

    console.log('createOrder: creating razorpay order', { userId: String(userId), totalPaise, options });

    const razorpayOrder = await razorpay.orders.create(options);

    const orderDoc = await Order.create({
      userId,
      items: itemsSnapshot,
      amount: totalPaise / 100,
      currency: options.currency,
      receipt: razorpayOrder.receipt,
      razorpayOrderId: razorpayOrder.id,
      status: 'pending_payment',
      paymentMethod: 'Razorpay',
      shippingAddress: {
        fullName: address.fullName,
        line1: address.line1,
        line2: address.line2 || '',
        city: address.city,
        state: address.state || '',
        postalCode: address.postalCode,
        phone: address.phone,
      },
      meta: { cartSnapshot: debugItems },
    });

    return res.status(200).json({
      success: true,
      key: RAZORPAY_KEY_ID,
      razorpayOrder,
      order: orderDoc.toObject(),
    });
  } catch (err) {
    console.error('createOrder error:', err && err.error ? err.error : err);
    const detail = err && err.error && err.error.description ? err.error.description : (err.message || 'Unknown error');
    return res.status(500).json({ success: false, message: 'Payment order creation failed', detail });
  }
};

/**
 * Verify payment signature sent from client after Razorpay Checkout
 * Client should post:
 * {
 *   razorpay_order_id,
 *   razorpay_payment_id,
 *   razorpay_signature
 * }
 */
exports.verifyPayment = async (req, res) => {
  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;
    if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
      return res.status(400).json({ success: false, message: 'Missing payment verification fields' });
    }

    if (!RAZORPAY_KEY_SECRET) {
      return res.status(500).json({ success: false, message: 'Razorpay secret not configured' });
    }

    const generatedSignature = crypto
      .createHmac('sha256', RAZORPAY_KEY_SECRET)
      .update(`${razorpay_order_id}|${razorpay_payment_id}`)
      .digest('hex');

    if (generatedSignature === razorpay_signature) {
      const userId = req.user && req.user._id;

      const orderDoc = await Order.findOneAndUpdate(
        { razorpayOrderId: razorpay_order_id, userId },
        {
          $set: {
            razorpayPaymentId: razorpay_payment_id,
            razorpaySignature: razorpay_signature,
            status: 'paid',
          },
        },
        { new: true }
      );

      if (!orderDoc) {
        console.warn('verifyPayment: order not found for razorpay id', razorpay_order_id);
        return res.status(404).json({ success: false, message: 'Order record not found' });
      }

      await Cart.findOneAndUpdate({ user: userId }, { items: [] });

      console.log('verifyPayment: signature valid for order', razorpay_order_id);
      return res.status(200).json({ success: true, message: 'Payment verified', order: orderDoc.toObject() });
    } else {
      console.warn('verifyPayment: signature mismatch', { generatedSignature, received: razorpay_signature });
      await Order.findOneAndUpdate(
        { razorpayOrderId: razorpay_order_id },
        { $set: { status: 'failed', razorpaySignature: razorpay_signature } }
      );
      return res.status(400).json({ success: false, message: 'Invalid signature' });
    }
  } catch (err) {
    console.error('verifyPayment error:', err);
    return res.status(500).json({ success: false, message: 'Payment verification failed', detail: err.message || err });
  }
};

/**
 * Get all payments/orders with user details (for admin view)
 * Includes all statuses: created, pending_payment, paid, failed, cancelled
 */
exports.getAllPayments = async (req, res) => {
  try {
    const orders = await Order.find()
      .populate('userId', 'name email')
      .sort({ createdAt: -1 })
      .lean();

    // Transform to include user details
    const payments = orders.map(order => ({
      ...order,
      user: order.userId ? {
        id: order.userId._id || order.userId.id,
        name: order.userId.name || 'Unknown',
        email: order.userId.email || 'No email',
      } : null,
    }));

    return res.status(200).json({
      success: true,
      payments,
      total: payments.length,
      byStatus: {
        created: payments.filter(p => p.status === 'created').length,
        pending_payment: payments.filter(p => p.status === 'pending_payment').length,
        paid: payments.filter(p => p.status === 'paid').length,
        failed: payments.filter(p => p.status === 'failed').length,
        cancelled: payments.filter(p => p.status === 'cancelled').length,
      },
    });
  } catch (err) {
    console.error('getAllPayments error:', err);
    return res.status(500).json({ success: false, message: 'Failed to load payments', detail: err.message || err });
  }
};

/**
 * Cancel a payment/order
 */
exports.cancelPayment = async (req, res) => {
  try {
    const { orderId } = req.body;
    const userId = req.user && req.user._id;

    if (!orderId) {
      return res.status(400).json({ success: false, message: 'Order ID is required' });
    }

    const order = await Order.findOne({
      _id: orderId,
      userId: userId, // Ensure user can only cancel their own orders
    });

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found or unauthorized' });
    }

    // Only allow cancellation if order is not already paid
    if (order.status === 'paid') {
      return res.status(400).json({ success: false, message: 'Cannot cancel a paid order' });
    }

    order.status = 'cancelled';
    await order.save();

    return res.status(200).json({
      success: true,
      message: 'Order cancelled successfully',
      order: order.toObject(),
    });
  } catch (err) {
    console.error('cancelPayment error:', err);
    return res.status(500).json({ success: false, message: 'Failed to cancel order', detail: err.message || err });
  }
};