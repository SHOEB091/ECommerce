const User = require("../models/userModels");
const Order = require("../models/Order");

exports.getAdminStats = async (req, res) => {
  try {
    const [totalUsers, totalOrders, paidOrders, pendingOrders, cancelledOrders, failedOrders, revenueAgg, recentOrders, recentUsers] =
      await Promise.all([
        User.countDocuments(),
        Order.countDocuments(),
        Order.countDocuments({ status: "paid" }),
        Order.countDocuments({ status: { $in: ["created", "pending_payment"] } }),
        Order.countDocuments({ status: "cancelled" }),
        Order.countDocuments({ status: "failed" }),
        Order.aggregate([
          { $match: { status: "paid" } },
          { $group: { _id: null, total: { $sum: "$amount" } } },
        ]),
        Order.find().populate("userId", "name email").sort({ createdAt: -1 }).limit(5).lean(),
        User.find().sort({ createdAt: -1 }).limit(5).select("-password").lean(),
      ]);

    const revenue = revenueAgg && revenueAgg.length > 0 ? revenueAgg[0].total : 0;

    res.json({
      success: true,
      stats: {
        totalUsers,
        totalOrders,
        paidOrders,
        pendingOrders,
        cancelledOrders,
        failedOrders,
        revenue,
      },
      recentOrders,
      recentUsers,
    });
  } catch (error) {
    console.error("getAdminStats error", error);
    res
      .status(500)
      .json({ success: false, message: error.message || "Unable to load analytics" });
  }
};

exports.getAllUsers = async (_req, res) => {
  try {
    const users = await User.find().select("-password").sort({ createdAt: -1 }).lean();
    res.json({ success: true, users });
  } catch (error) {
    console.error("getAllUsers error", error);
    res
      .status(500)
      .json({ success: false, message: error.message || "Unable to load users" });
  }
};

exports.getAllOrders = async (_req, res) => {
  try {
    const orders = await Order.find()
      .populate("userId", "name email")
      .sort({ createdAt: -1 })
      .lean();
    
    // Include all statuses including cancelled
    const ordersWithUserDetails = orders.map(order => ({
      ...order,
      user: order.userId ? {
        id: order.userId._id || order.userId.id,
        name: order.userId.name || 'Unknown',
        email: order.userId.email || 'No email',
      } : null,
    }));

    res.json({ 
      success: true, 
      orders: ordersWithUserDetails,
      summary: {
        total: orders.length,
        paid: orders.filter(o => o.status === 'paid').length,
        pending: orders.filter(o => ['created', 'pending_payment'].includes(o.status)).length,
        cancelled: orders.filter(o => o.status === 'cancelled').length,
        failed: orders.filter(o => o.status === 'failed').length,
      },
    });
  } catch (error) {
    console.error("getAllOrders error", error);
    res
      .status(500)
      .json({ success: false, message: error.message || "Unable to load orders" });
  }
};

exports.updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const validStatuses = ["created", "pending_payment", "paid", "failed", "cancelled"];
    if (!status || !validStatuses.includes(status)) {
      return res
        .status(400)
        .json({ success: false, message: "Invalid order status provided" });
    }

    const updated = await Order.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    )
      .populate("userId", "name email")
      .lean();

    if (!updated) {
      return res.status(404).json({ success: false, message: "Order not found" });
    }

    res.json({ success: true, order: updated });
  } catch (error) {
    console.error("updateOrderStatus error", error);
    res
      .status(500)
      .json({ success: false, message: error.message || "Unable to update order" });
  }
};

