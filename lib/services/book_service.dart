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

    // If the image URL is absolute but points to localhost, replace the host
    // with the configured API host so that the image can be loaded on a device.
    if (image.startsWith('http://') || image.startsWith('https://')) {
      try {
        final uri = Uri.parse(image);
        if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
          final base = Uri.parse(ApiService.baseUrl);
          image = uri.replace(host: base.host, port: base.port).toString();
        }
      } catch (_) {
        // fall through and keep the original image value
      }
    } else if (image.startsWith('/uploads') || image.startsWith('uploads/')) {
      // For relative upload paths, prefix with the API host
      final base = Uri.parse(ApiService.baseUrl);
      final path = image.startsWith('/') ? image.substring(1) : image;
      image = Uri(
        scheme: base.scheme,
        host: base.host,
        port: base.port,
        path: path,
      ).toString();
    } else if (!image.startsWith('assets/')) {
      // Local bundled asset
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
