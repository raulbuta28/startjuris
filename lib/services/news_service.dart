import 'dart:convert';
import 'package:http/http.dart' as http;
import '../pages/backend/services/api_service.dart';

class NewsItem {
  final String id;
  final String title;
  final String description;
  final String details;
  final DateTime date;
  final String imageUrl;

  NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.details,
    required this.date,
    required this.imageUrl,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      details: json['details'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      imageUrl: (json['imageUrl'] as String?)?.replaceFirst('../', '') ?? '',
    );
  }
}

class NewsService {
  static Future<List<NewsItem>> fetchNews() async {
    final uri = Uri.parse('${ApiService.baseUrl}/news');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => NewsItem.fromJson(e)).toList();
    }
    throw Exception('failed to load news');
  }
}
