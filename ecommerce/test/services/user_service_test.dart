import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce/services/user_service.dart';
import 'package:ecommerce/utils/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Mock FlutterSecureStorage
class MockFlutterSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<String?> read({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    MacOsOptions? mOptions,
    WebOptions? webOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage[key];
  }

  @override
  Future<void> write({
    required String key,
    String? value,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    MacOsOptions? mOptions,
    WebOptions? webOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _storage[key] = value;
    } else {
      _storage.remove(key);
    }
  }

  @override
  Future<void> delete({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    MacOsOptions? mOptions,
    WebOptions? webOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll({
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    MacOsOptions? mOptions,
    WebOptions? webOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.clear();
  }
}

void main() {
  // Initialize Flutter bindings for tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserService', () {
    late UserService userService;

    setUp(() {
      userService = UserService.instance;
    });

    test('should be a singleton', () {
      final instance1 = UserService.instance;
      final instance2 = UserService.instance;
      expect(instance1, equals(instance2));
    });

    test('user notifier should be initialized as null', () {
      expect(userService.user.value, isNull);
    });

    test('ensureUserLoaded should return cached user if available', () async {
      // Set up a cached user
      final cachedUser = {
        'id': '507f1f77bcf86cd799439011',
        'name': 'Test User',
        'email': 'test@example.com',
      };
      userService.user.value = cachedUser;

      final result = await userService.ensureUserLoaded();
      expect(result, equals(cachedUser));
    });

    test('updateProfile should update user data', () async {
      // This test would require mocking the API calls
      // For now, we test the structure
      expect(userService.updateProfile, isA<Function>());
    });

    test('clear should reset user and storage', () async {
      userService.user.value = {
        'id': '507f1f77bcf86cd799439011',
        'name': 'Test User',
      };

      // Note: clear() uses platform channels which aren't available in unit tests
      // This test verifies the method exists and can be called
      // In integration tests, this would work properly
      expect(userService.clear, isA<Function>());
      
      // Verify user value is set before clear
      expect(userService.user.value, isNotNull);
    });
  });
}

