// lib/screens/notofications_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/notifications_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _format(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return DateFormat.E().add_jm().format(dt); // Mon 5:30 PM
    return DateFormat.yMMMd().format(dt); // Nov 1, 2025
  }

  @override
  Widget build(BuildContext context) {
    final service = NotificationsService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w700),
        actions: [
          // Mark all read
          IconButton(
            tooltip: 'Mark all read',
            onPressed: () => service.markAllRead(),
            icon: const Icon(Icons.done_all, color: Colors.black54),
          ),
          // Clear all
          IconButton(
            tooltip: 'Clear all',
            onPressed: () => service.clear(),
            icon: const Icon(Icons.delete_outline, color: Colors.black54),
          ),
          // Notifications icon with unread badge
          ValueListenableBuilder<List<NotificationItem>>(
            valueListenable: service.notifications,
            builder: (context, list, _) {
              final unread = list.where((n) => !n.isRead).length;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: Colors.black54),
                      onPressed: () {},
                    ),
                    if (unread > 0)
                      Positioned(
                        right: 6,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                          child: Center(
                            child: Text(
                              unread > 99 ? '99+' : unread.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: ValueListenableBuilder<List<NotificationItem>>(
        valueListenable: service.notifications,
        builder: (context, notifications, _) {
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications'));
          }
          return ListView.separated(
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
                    Text(_format(n.time), style: const TextStyle(fontSize: 12, color: Colors.black45)),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    n.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54),
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
                  // Mark as read and show details
                  NotificationsService.instance.markRead(n.id);

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
          );
        },
      ),
    );
  }
}