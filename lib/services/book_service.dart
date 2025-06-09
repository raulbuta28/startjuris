import 'dart:convert';
import 'package:http/http.dart' as http;
import '../pages/backend/services/api_service.dart';

class AdminBook {
  final String id;
  final String title;
  final String image;
  final String content;

  AdminBook({required this.id, required this.title, required this.image, required this.content});

  factory AdminBook.fromJson(Map<String, dynamic> json) {
    String image = (json['image'] as String?)?.replaceFirst('../', '') ?? '';
    if (!image.startsWith('http') && !image.startsWith('assets/')) {
      image = 'assets/' + image;
    }
    return AdminBook(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      image: image,
      content: json['content'] ?? '',
    );
  }
}

class BookService {
  static Future<List<AdminBook>> fetchBooks() async {
    final uri = Uri.parse('${ApiService.baseUrl}/books');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => AdminBook.fromJson(e)).toList();
    }
    throw Exception('failed to load books');
  }
}
