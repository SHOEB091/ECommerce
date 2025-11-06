import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  // Static notifications (replace with your own text/images)
  static final List<_NotificationItem> _staticNotifications = [
    _NotificationItem(
      title: 'Order shipped',
      body: 'Your order #A1245 has been shipped and is on the way.',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      icon: Icons.local_shipping,
    ),
    _NotificationItem(
      title: 'Flash sale: 30% off',
      body: 'Limited time — get 30% off selected jackets today only.',
      time: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      isRead: false,
      icon: Icons.local_offer,
    ),
    _NotificationItem(
      title: 'New arrival',
      body: 'Check out the new Autumn Collection available now.',
      time: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
      icon: Icons.new_releases,
    ),
    _NotificationItem(
      title: 'Wishlist price drop',
      body: 'An item in your wishlist is now ₹500 off.',
      time: DateTime.now().subtract(const Duration(days: 6, hours: 5)),
      isRead: true,
      icon: Icons.favorite_border,
    ),
    _NotificationItem(
      title: 'Welcome to GemStore',
      body: 'Thanks for installing the app — enjoy shopping! 🎉',
      time: DateTime.now().subtract(const Duration(days: 12)),
      isRead: true,
      icon: Icons.thumb_up_alt_outlined,
    ),
  ];

  String _format(DateTime dt) {
    // Use a short, readable time format
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return DateFormat.E().add_jm().format(dt); // Mon 5:30 PM
    return DateFormat.yMMMd().format(dt); // Nov 1, 2025
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _staticNotifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w700),
        actions: [
          // purely cosmetic "clear" button for static page
          IconButton(
            tooltip: 'Mark all read (static)',
            onPressed: () {
              // Static page: show a message only
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked all as read (static)')));
            },
            icon: const Icon(Icons.done_all, color: Colors.black54),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListView.separated(
          itemCount: notifications.length,
          separatorBuilder: (_, __) => const Divider(height: 0.5),
          itemBuilder: (context, index) {
            final n = notifications[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: n.isRead ? Colors.grey.shade100 : Colors.blue.shade50,
                child: Icon(n.icon, color: n.isRead ? Colors.black54 : Colors.blueAccent),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      n.title,
                      style: TextStyle(
                        fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(_format(n.time), style: TextStyle(fontSize: 12, color: Colors.black45)),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  n.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              trailing: n.isRead
                  ? null
                  : Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    ),
              onTap: () {
                // For a static page we can show a simple dialog or bottom sheet with details
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                  builder: (ctx) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(radius: 20, backgroundColor: Colors.blue.shade50, child: Icon(n.icon, color: Colors.blueAccent)),
                              const SizedBox(width: 12),
                              Expanded(child: Text(n.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                              Text(_format(n.time), style: const TextStyle(fontSize: 12, color: Colors.black45)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(n.body, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Close'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NotificationItem {
  final String title;
  final String body;
  final DateTime time;
  final bool isRead;
  final IconData icon;

  const _NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.icon,
  });
}
