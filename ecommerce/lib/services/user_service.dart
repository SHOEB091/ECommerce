import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/api.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ValueNotifier<Map<String, dynamic>?> user =
      ValueNotifier<Map<String, dynamic>?>(null);

  Future<Map<String, dynamic>?>? _pendingFetch;

  Future<Map<String, dynamic>?> ensureUserLoaded() async {
    if (user.value != null) return user.value;

    final cached = await _loadFromStorage();
    if (cached != null) {
      user.value = cached;
    }

    return await refresh();
  }

  Future<Map<String, dynamic>?> refresh() async {
    if (_pendingFetch != null) return await _pendingFetch!;
    _pendingFetch = _fetchRemote().whenComplete(() => _pendingFetch = null);
    return await _pendingFetch!;
  }

  Future<Map<String, dynamic>?> _fetchRemote() async {
    try {
      final resp = await get('/auth/me', auth: true);
      final status = resp['status'] as int?;
      final body = resp['body'] as Map<String, dynamic>?;
      if (status == 200 && body != null && body['success'] == true && body['user'] != null) {
        final data = Map<String, dynamic>.from(body['user'] as Map);
        await _saveToStorage(data);
        user.value = data;
        return data;
      }
    } catch (e) {
      debugPrint('UserService.fetchRemote error: $e');
    }
    return user.value;
  }

  Future<Map<String, dynamic>?> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (email != null) payload['email'] = email;
    if (phone != null) payload['phone'] = phone;
    if (avatar != null) payload['avatar'] = avatar;

    if (payload.isEmpty) return user.value;

    final resp = await put('/auth/me', payload, auth: true);
    final status = resp['status'] as int?;
    final body = resp['body'] as Map<String, dynamic>?;
    if (status == 200 && body != null && body['success'] == true && body['user'] != null) {
      final data = Map<String, dynamic>.from(body['user'] as Map);
      await _saveToStorage(data);
      user.value = data;
      return data;
    }
    throw Exception(body?['message'] ?? 'Failed to update profile');
  }

  Future<Map<String, dynamic>?> _loadFromStorage() async {
    try {
      final raw = await _storage.read(key: 'user');
      if (raw == null) return null;
      final data = jsonDecode(raw);
      if (data is Map<String, dynamic>) return Map<String, dynamic>.from(data);
      return null;
    } catch (e) {
      debugPrint('UserService.loadFromStorage error: $e');
      return null;
    }
  }

  Future<void> _saveToStorage(Map<String, dynamic> data) async {
    try {
      await _storage.write(key: 'user', value: jsonEncode(data));
    } catch (e) {
      debugPrint('UserService.saveToStorage error: $e');
    }
  }

  Future<void> clear() async {
    user.value = null;
    await _storage.delete(key: 'user');
    await _storage.delete(key: 'role');
  }
}

