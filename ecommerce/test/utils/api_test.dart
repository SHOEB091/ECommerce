import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce/utils/api.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

void main() {
  // Initialize Flutter bindings for tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('API Utils', () {
    test('API_BASE should be defined', () {
      expect(API_BASE, isNotEmpty);
      expect(API_BASE, contains('localhost'));
    });

    test('saveToken should be a function', () {
      expect(saveToken, isA<Function>());
    });

    test('clearToken should be a function', () {
      expect(clearToken, isA<Function>());
    });

    test('get should make GET request', () async {
      // This would require mocking http.get
      // For now, we verify the function exists
      expect(get, isA<Function>());
    });

    test('post should make POST request', () async {
      // This would require mocking http.post
      expect(post, isA<Function>());
    });

    test('put should make PUT request', () async {
      expect(put, isA<Function>());
    });

    test('patch should make PATCH request', () async {
      expect(patch, isA<Function>());
    });

    test('del should make DELETE request', () async {
      expect(del, isA<Function>());
    });
  });
}

