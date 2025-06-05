import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminBook {
  final String id;
  final String title;
  final String image;
  final String content;

  AdminBook({required this.id, required this.title, required this.image, required this.content});

  factory AdminBook.fromJson(Map<String, dynamic> json) {
    return AdminBook(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      image: _normalizeImage(json['image'] as String?),
      content: json['content'] ?? '',
    );
  }

  static String _normalizeImage(String? img) {
    if (img == null) return '';
    var path = img.replaceFirst('../', '');
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (!path.startsWith('assets/')) {
      path = 'assets/$path';
    }
    return path;
  }
}

class BookService {
  static Future<List<AdminBook>> fetchBooks() async {
    final uri = Uri.parse('http://localhost:8080/api/books');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => AdminBook.fromJson(e)).toList();
    }
    throw Exception('failed to load books');
  }
}
