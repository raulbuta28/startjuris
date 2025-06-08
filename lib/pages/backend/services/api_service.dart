import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../config.dart' as config;

class ApiService {
  static const String baseUrl = config.apiBaseUrl;
  static String get wsBaseUrl => config.wsBaseUrl;
  final String? token;
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();
  String? _currentUserId;

  String? get currentUserId => _currentUserId;

  ApiService({this.token}) {
    print('ApiService initialized with token: $token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      try {
        final parts = token!.split('.');
        if (parts.length > 1) {
          final payload = json.decode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
          );
          _currentUserId = payload['user_id'];
        }
      } catch (e) {
        print('Error extracting user ID from token: $e');
      }
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) {
        if (response.data is Map<String, dynamic>) {
          _convertDates(response.data as Map<String, dynamic>);
        } else if (response.data is List) {
          for (var item in response.data) {
            if (item is Map<String, dynamic>) {
              _convertDates(item);
            }
          }
        }
        return handler.next(response);
      },
    ));
  }

  void _convertDates(Map<String, dynamic> json) {
    json.forEach((key, value) {
      if (value is String && key.toLowerCase().contains('time')) {
        try {
          final date = DateTime.parse(value).toLocal();
          json[key] = date.toIso8601String();
        } catch (e) {
          print('Error converting date: $e');
        }
      } else if (value is Map<String, dynamic>) {
        _convertDates(value);
      } else if (value is List) {
        for (var item in value) {
          if (item is Map<String, dynamic>) {
            _convertDates(item);
          }
        }
      }
    });
  }

  Map<String, String> get headers {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      print('Adding Authorization header: ${headers['Authorization']}');
    } else {
      print('No token available for headers');
    }
    return headers;
  }

  Future<Response> get(String endpoint) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      return await _dio.get('$baseUrl$endpoint');
    } catch (e) {
      print('GET request error: $e');
      rethrow;
    }
  }

  Future<http.Response> put(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$path'),
        headers: headers,
        body: jsonEncode(data),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to make PUT request: $e');
    }
  }

  Future<http.Response> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: headers,
        body: data != null ? jsonEncode(data) : null,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to make POST request: $e');
    }
  }

  bool get isAuthenticated => token != null;
}