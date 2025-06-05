import 'dart:convert';
import 'package:http/http.dart' as http;
import '../pages/backend/services/api_service.dart';

class NewsService {
  static Future<List<Map<String, dynamic>>> fetchNews() async {
    final uri = Uri.parse('${ApiService.baseUrl}/posts');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('failed to load news');
  }
}
