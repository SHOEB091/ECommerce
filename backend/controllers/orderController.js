const Order = require('../models/Order');

exports.getMyOrders = async (req, res) => {
  try {
    const userId = req.user && req.user._id;
    if (!userId) {
      return res.status(401).json({ success: false, message: 'User not authenticated' });
    }

    const orders = await Order.find({ userId }).sort({ createdAt: -1 }).lean();
    return res.json({ success: true, orders });
  } catch (err) {
    console.error('getMyOrders error:', err);
    return res.status(500).json({ success: false, message: 'Failed to load orders', detail: err.message || err });
  }
};
