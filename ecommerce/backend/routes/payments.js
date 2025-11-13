// routes/payments.js
const express = require('express');
const router = express.Router();
const Razorpay = require('razorpay');
const crypto = require('crypto');

const Order = require('../models/Order');


const razor = new Razorpay({
  key_id: process.env.RZP_KEY_ID,
  key_secret: process.env.RZP_KEY_SECRET,
});


const toPaise = (r) => Math.round(Number(r) * 100);


router.post('/create-order', async (req, res) => {
  try {
   
    const { items, amount, currency = 'INR', receipt, userId, meta } = req.body;

   
    if (!items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ success: false, message: 'items required' });
    }
    if (!amount) return res.status(400).json({ success: false, message: 'amount required' });

   

    const newOrder = await Order.create({
      userId: userId || null,
      items,
      amount,
      currency,
      receipt: receipt || `rcpt_${Date.now()}`,
      status: 'pending_payment',
      meta: meta || {},
    });

    
    const rOrder = await razor.orders.create({
      amount: toPaise(amount), 
      currency,
      receipt: newOrder.receipt,
      payment_capture: 1, 
    });

    newOrder.razorpayOrderId = rOrder.id;
    await newOrder.save();

    return res.json({ success: true, order: newOrder, razorpayOrder: rOrder });
  } catch (err) {
    console.error('create-order err', err);
    return res.status(500).json({ success: false, message: err.message || 'server error' });
  }
});


router.post('/verify', async (req, res) => {
  try {
    const { orderId, razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;
    if (!orderId || !razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
      return res.status(400).json({ success: false, message: 'missing fields' });
    }

    // fetch local order
    const order = await Order.findById(orderId);
    if (!order) return res.status(404).json({ success: false, message: 'Order not found' });

    // if already paid, return success (idempotent)
    if (order.status === 'paid') {
      return res.json({ success: true, message: 'Order already marked paid' });
    }

    // verify signature
    const generated = crypto.createHmac('sha256', process.env.RZP_KEY_SECRET)
      .update(razorpay_order_id + '|' + razorpay_payment_id)
      .digest('hex');

    if (generated !== razorpay_signature) {
      console.warn('Invalid signature', { generated, got: razorpay_signature });
      // mark as failed optionally
      order.status = 'failed';
      await order.save();
      return res.status(400).json({ success: false, message: 'Invalid signature' });
    }

    // update order as paid
    order.razorpayOrderId = razorpay_order_id;
    order.razorpayPaymentId = razorpay_payment_id;
    order.razorpaySignature = razorpay_signature;
    order.status = 'paid';
    await order.save();

 
    return res.json({ success: true, message: 'Payment verified and order marked as paid' });
  } catch (err) {
    console.error('verify err', err);
    return res.status(500).json({ success: false, message: err.message || 'server error' });
  }
});


router.post('/reconcile', async (req, res) => {
  try {
   

    const pendingOrders = await Order.find({ status: 'pending_payment', createdAt: { $lte: new Date(Date.now() - 1000 * 60 * 1) } }).limit(50); // older than 1 min
    const results = [];

    for (const ord of pendingOrders) {
      if (!ord.razorpayOrderId) continue;

      
      const payments = await razor.orders.fetchPayments(ord.razorpayOrderId); 
      const items = payments.items || [];

      const captured = items.find(p => p.status === 'captured' || p.status === 'authorized');
      if (captured) {
        ord.razorpayPaymentId = captured.id;
        ord.razorpaySignature = ''; 
        ord.status = 'paid';
        await ord.save();
        results.push({ orderId: ord._id, status: 'paid', paymentId: captured.id });
        // trigger fulfillment job...
      } else if (items.length === 0) {
        
        const ageMins = (Date.now() - ord.createdAt.getTime()) / 60000;
        if (ageMins > 60) { // e.g., 60 minutes
          ord.status = 'failed';
          await ord.save();
          results.push({ orderId: ord._id, status: 'failed' });
        }
      } else {
        results.push({ orderId: ord._id, status: 'no-capture', paymentsCount: items.length });
      }
    }

    res.json({ success: true, results });
  } catch (err) {
    console.error('reconcile err', err);
    res.status(500).json({ success: false, message: err.message || 'server error' });
  }
});

module.exports = router;
