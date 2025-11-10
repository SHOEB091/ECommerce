// lib/utils/api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String API_BASE = 'http://localhost:5000/api/v1'; 

final _storage = const FlutterSecureStorage();

Future<Map<String, dynamic>> post(String path, Map body, {bool auth = false}) async {
  final token = auth ? await _storage.read(key: 'auth_token') : null;
  final headers = <String, String>{
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
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
