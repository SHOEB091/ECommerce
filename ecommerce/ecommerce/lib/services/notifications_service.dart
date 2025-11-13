// lib/services/notifications_service.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  bool isRead;
  final IconData icon;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
    this.icon = Icons.notifications,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'time': time.toIso8601String(),
        'isRead': isRead,
        'icon': icon.codePoint,
      };

  static NotificationItem fromJson(Map<String, dynamic> j) => NotificationItem(
        id: j['id'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        time: DateTime.parse(j['time'] as String),
        isRead: j['isRead'] as bool? ?? false,
        icon: IconData(j['icon'] as int? ?? Icons.notifications.codePoint, fontFamily: 'MaterialIcons'),
      );
}

class NotificationsService {
  NotificationsService._private();
  static final NotificationsService instance = NotificationsService._private();

  final ValueNotifier<List<NotificationItem>> notifications = ValueNotifier<List<NotificationItem>>([]);

  static const _kStorageKey = 'app_notifications_v1';

  bool _initialized = false;

  /// Call this once at app startup (before screens rely on notifications)
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _loadFromStorage();
  }

  void add(NotificationItem item) {
    final list = List<NotificationItem>.from(notifications.value);
    list.insert(0, item); // newest first
    notifications.value = list;
    _saveToStorage(list);
    debugPrint('[NotificationsService] added: ${item.title}');
  }

  void markRead(String id) {
    final list = notifications.value.map((n) {
      if (n.id == id) n.isRead = true;
      return n;
    }).toList();
    notifications.value = list;
    _saveToStorage(list);
  }

  void markAllRead() {
    final list = notifications.value.map((n) {
      n.isRead = true;
      return n;
    }).toList();
    notifications.value = list;
    _saveToStorage(list);
  }

  void clear() {
    notifications.value = [];
    _saveToStorage([]);
  }

  // ---------------- Persistence ----------------
  Future<void> _saveToStorage(List<NotificationItem> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = list.map((n) => jsonEncode(n.toJson())).toList();
      await prefs.setStringList(_kStorageKey, jsonList);
    } catch (e) {
      debugPrint('[NotificationsService] save error: $e');
    }
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_kStorageKey);
      if (saved == null || saved.isEmpty) {
        notifications.value = [];
        return;
      }
      final list = saved.map((s) {
        final Map<String, dynamic> j = jsonDecode(s) as Map<String, dynamic>;
        return NotificationItem.fromJson(j);
      }).toList();
      notifications.value = list;
      debugPrint('[NotificationsService] loaded ${list.length} items');
    } catch (e) {
      debugPrint('[NotificationsService] load error: $e');
      notifications.value = [];
    }
  }
}
