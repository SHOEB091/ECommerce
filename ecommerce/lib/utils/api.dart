// lib/utils/api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String API_BASE = 'https://backend001-88nd.onrender.com/api/v1';

final _storage = const FlutterSecureStorage();

Future<Map<String, String>> _headers(bool auth) async {
  final token = auth ? await _storage.read(key: 'auth_token') : null;
  return {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}

Future<Map<String, dynamic>> post(String path, Map body, {bool auth = false}) async {
  final headers = await _headers(auth);
  final resp = await http.post(Uri.parse('$API_BASE$path'), headers: headers, body: jsonEncode(body));
  return {
    'status': resp.statusCode,
    'body': resp.body.isNotEmpty ? jsonDecode(resp.body) : null,
  };
}

Future<void> saveToken(String token) async {
  await _storage.write(key: 'auth_token', value: token);
}

Future<void> clearToken() async {
  await _storage.delete(key: 'auth_token');
}

Future<Map<String, dynamic>> get(String path, {bool auth = false}) async {
  final headers = await _headers(auth);
  final resp = await http.get(Uri.parse('$API_BASE$path'), headers: headers);
  return {
    'status': resp.statusCode,
    'body': resp.body.isNotEmpty ? jsonDecode(resp.body) : null,
  };
}

Future<Map<String, dynamic>> put(String path, Map body, {bool auth = false}) async {
  final headers = await _headers(auth);
  final resp = await http.put(Uri.parse('$API_BASE$path'), headers: headers, body: jsonEncode(body));
  return {
    'status': resp.statusCode,
    'body': resp.body.isNotEmpty ? jsonDecode(resp.body) : null,
  };
}

Future<Map<String, dynamic>> patch(String path, Map body, {bool auth = false}) async {
  final headers = await _headers(auth);
  final resp = await http.patch(Uri.parse('$API_BASE$path'), headers: headers, body: jsonEncode(body));
  return {
    'status': resp.statusCode,
    'body': resp.body.isNotEmpty ? jsonDecode(resp.body) : null,
  };
}

Future<Map<String, dynamic>> del(String path, {bool auth = false}) async {
  final headers = await _headers(auth);
  final resp = await http.delete(Uri.parse('$API_BASE$path'), headers: headers);
  return {
    'status': resp.statusCode,
    'body': resp.body.isNotEmpty ? jsonDecode(resp.body) : null,
  };
}