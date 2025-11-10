// lib/services/chat_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// ChatService: frontend usage OK for development only.
/// This file is defensive: it never throws due to unexpected JSON shapes when parsing.
class ChatService {
  final String apiKey;
  final String model;
  final Duration timeout;

  ChatService({
    required this.apiKey,
    required this.model,
    this.timeout = const Duration(seconds: 20),
  });

  Future<String> sendPrompt(String prompt) async {
    if (apiKey.isEmpty) throw Exception('Missing API key.');

    // 1) try generateMessage
    try {
      final resp = await _postGenerateMessage(prompt);
      if (_isSuccess(resp.statusCode)) {
        final parsed = _extractText(resp.body);
        return parsed ?? resp.body; // return parsed text or raw JSON body
      } else {
        debugPrint('generateMessage failed ${resp.statusCode}: ${resp.body}');
      }
    } catch (e, st) {
      debugPrint('generateMessage error: $e\n$st');
    }

    // 2) fallback to generateContent
    try {
      final resp = await _postGenerateContent(prompt);
      if (_isSuccess(resp.statusCode)) {
        final parsed = _extractText(resp.body);
        return parsed ?? resp.body;
      } else {
        debugPrint('generateContent failed ${resp.statusCode}: ${resp.body}');
        throw ApiException(resp.statusCode, resp.body);
      }
    } catch (e) {
      debugPrint('generateContent error: $e');
      rethrow;
    }
  }

  Future<http.Response> _postGenerateMessage(String prompt) {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateMessage?key=$apiKey',
    );
    final body = {
      "messages": [
        {
          "author": "user",
          "content": [
            {"type": "text", "text": prompt}
          ]
        }
      ]
    };
    return _httpPost(uri, jsonEncode(body));
  }

  Future<http.Response> _postGenerateContent(String prompt) {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );
    final body = {
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    };
    return _httpPost(uri, jsonEncode(body));
  }

  Future<http.Response> _httpPost(Uri uri, String body) {
    return http.post(uri, headers: {'Content-Type': 'application/json'}, body: body).timeout(timeout);
  }

  bool _isSuccess(int status) => status >= 200 && status < 300;

  
  String? _extractText(String body) {
    try {
      final dynamic jsonObj = jsonDecode(body);
      // helper to try many paths
      String? tryCandidates(dynamic obj) {
        if (obj is Map && obj['candidates'] is List) {
          final List candidates = obj['candidates'] as List;
          for (final cand in candidates) {
            // cand may be Map or String
            if (cand is Map) {
              final content = cand['content'];
              final text = _extractFromContent(content);
              if (text != null && text.isNotEmpty) return text;
              // also check role/content.parts deeper
              if (cand['role'] != null && cand['role'] is String) {
                // nothing extra here, continue
              }
            } else if (cand is String) {
              if (cand.trim().isNotEmpty) return cand;
            }
          }
        }
        return null;
      }

      String? tryOutputs(dynamic obj) {
        if (obj is Map && obj['outputs'] is List) {
          final outs = obj['outputs'] as List;
          for (final out in outs) {
            if (out is Map && out['content'] != null) {
              final text = _extractFromContent(out['content']);
              if (text != null && text.isNotEmpty) return text;
            }
          }
        }
        return null;
      }

      // try candidates first
      final c = tryCandidates(jsonObj);
      if (c != null) return c;

      // try outputs
      final o = tryOutputs(jsonObj);
      if (o != null) return o;

      // try direct content fields or known names
      if (jsonObj is Map) {
        final directFields = ['text', 'response', 'output', 'content', 'message'];
        for (final k in directFields) {
          final val = jsonObj[k];
          if (val is String && val.trim().isNotEmpty) return val;
          if (val != null) {
            final text = _extractFromContent(val);
            if (text != null && text.isNotEmpty) return text;
          }
        }
      }

      // Last resort: search the whole decoded JSON for any "text" key
      final found = _findFirstTextRecursively(jsonObj);
      if (found != null && found.isNotEmpty) return found;

      return null;
    } catch (e) {
      debugPrint('extractText parse error: $e');
      return null;
    }
  }

  /// Extract possible text from a content node which may be many types.
  String? _extractFromContent(dynamic content) {
    try {
      if (content == null) return null;
      // If content is string
      if (content is String) {
        if (content.trim().isNotEmpty) return content;
        return null;
      }
      // If content is Map, check for 'parts', 'text', etc.
      if (content is Map) {
        // 1) content['parts'] -> list of parts that may have 'text'
        if (content['parts'] is List) {
          final List parts = content['parts'] as List;
          for (final p in parts) {
            if (p is Map && p['text'] != null && p['text'] is String) {
              final t = (p['text'] as String).trim();
              if (t.isNotEmpty) return t;
            } else if (p is String) {
              final t = p.trim();
              if (t.isNotEmpty) return t;
            } else {
              // recursive
              final rec = _extractFromContent(p);
              if (rec != null && rec.isNotEmpty) return rec;
            }
          }
        }
        // 2) content['text'] is direct
        if (content['text'] is String && (content['text'] as String).trim().isNotEmpty) {
          return (content['text'] as String).trim();
        }
        // 3) content may contain other nested fields, try recursively
        for (final entry in content.entries) {
          final rec = _extractFromContent(entry.value);
          if (rec != null && rec.isNotEmpty) return rec;
        }
      }
      // If content is List, try each element
      if (content is List) {
        for (final el in content) {
          final rec = _extractFromContent(el);
          if (rec != null && rec.isNotEmpty) return rec;
        }
      }
      return null;
    } catch (e) {
      debugPrint('_extractFromContent error: $e');
      return null;
    }
  }

  /// Recursively search any JSON tree for the first string value keyed 'text'
  String? _findFirstTextRecursively(dynamic node) {
    try {
      if (node == null) return null;
      if (node is Map) {
        if (node.containsKey('text') && node['text'] is String) {
          final t = (node['text'] as String).trim();
          if (t.isNotEmpty) return t;
        }
        for (final v in node.values) {
          final rec = _findFirstTextRecursively(v);
          if (rec != null && rec.isNotEmpty) return rec;
        }
      } else if (node is List) {
        for (final el in node) {
          final rec = _findFirstTextRecursively(el);
          if (rec != null && rec.isNotEmpty) return rec;
        }
      }
      return null;
    } catch (e) {
      debugPrint('_findFirstTextRecursively error: $e');
      return null;
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);
  @override
  String toString() => 'ApiException($statusCode): $body';
}
 