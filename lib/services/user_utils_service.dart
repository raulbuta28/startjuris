import 'dart:convert';
import 'package:http/http.dart' as http;

import '../pages/backend/services/api_service.dart';

class UserUtilsService {
  final String token;

  UserUtilsService(this.token);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> fetchUtils() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/utils'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return {};
  }

  Future<void> saveUtils(Map<String, dynamic> data) async {
    await http.put(
      Uri.parse('${ApiService.baseUrl}/utils'),
      headers: _headers,
      body: jsonEncode(data),
    );
  }
}

