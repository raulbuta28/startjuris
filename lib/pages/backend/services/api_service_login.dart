import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import '../models/user_model.dart';
import '../models/level_model.dart';
import '../models/performance_model.dart';

class ApiServiceLogin extends ApiService {
  @override
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  final Dio _dio = Dio();

  ApiServiceLogin({super.token});

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    print('Attempting login for email: $email');
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/login'),
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Eroare la autentificare');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    print('Attempting registration for email: $email');
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/register'),
        headers: headers,
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Eroare la înregistrare');
      }
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    if (kDebugMode) {
      print('User logged out');
    }
  }

  Future<User> getProfile() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/profile'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Eroare la obținerea profilului');
    }
  }

  Future<User> updateProfile({
    String? bio,
    String? username,
    String? email,
    String? phone,
    String? location,
    String? education,
    String? work,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/profile'),
        headers: headers,
        body: jsonEncode({
          if (bio != null) 'bio': bio,
          if (username != null) 'username': username,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
          if (location != null) 'location': location,
          if (education != null) 'education': education,
          if (work != null) 'work': work,
        }),
      );

      print('Update profile response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Failed to update profile: ${error['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error in updateProfile: $e');
      rethrow;
    }
  }

  Future<User> updateAvatar(String filePath, {Uint8List? bytes, String? filename}) async {
    try {
      print('Token being used: $token');
      final url = Uri.parse('${ApiService.baseUrl}/profile/avatar');
      print('Uploading avatar to: $url');

      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      print('Request headers: ${request.headers}');

      if (kIsWeb) {
        if (bytes == null) {
          throw Exception('No image data provided');
        }
        request.files.add(http.MultipartFile.fromBytes(
          'avatar',
          bytes,
          filename: filename ?? 'avatar.png',
        ));
      } else {
        final file = File(filePath);
        if (!await file.exists()) {
          throw Exception('Fișierul nu există: $filePath');
        }

        final fileSize = await file.length();
        print('File size: ${fileSize} bytes');

        request.files.add(await http.MultipartFile.fromPath('avatar', filePath));
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout la încărcarea imaginii');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      print('Upload response status: ${response.statusCode}');
      print('Upload response body: ${response.body}');

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Eroare la actualizarea avatarului');
      }
    } catch (e) {
      print('Error in updateAvatar: $e');
      throw Exception('Eroare la încărcarea imaginii: $e');
    }
  }

  Future<List<User>> searchUsers(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/users/search?query=$query'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> users = jsonDecode(response.body);
      return users.map((json) => User.fromJson(json)).toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Eroare la căutarea utilizatorilor');
    }
  }

  Future<User> followUser(int userId) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/users/$userId/follow'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Eroare la urmărirea utilizatorului');
    }
  }

  Future<List<User>> getFollowers() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/users/followers'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> followers = data['followers'];
      return followers.map((json) => User.fromJson(json)).toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Eroare la obținerea urmăritorilor');
    }
  }

  Future<List<User>> getFollowing() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/users/following'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> following = data['following'];
      return following.map((json) => User.fromJson(json)).toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Eroare la obținerea urmăririlor');
    }
  }

  Future<Map<String, dynamic>> toggleFollowUser(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/users/$userId/follow'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Eroare la urmărirea utilizatorului');
      }
    } catch (e) {
      throw Exception('Eroare la urmărirea utilizatorului: $e');
    }
  }

  Future<User> getUserDetails(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/users/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      throw Exception('Error getting user details: $e');
    }
  }

  Future<Level> getLevel() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/level'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Level.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  Future<Performance> getPerformance() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/performance'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Performance.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  Future<List<String>> getOnlineUsers() async {
    try {
      if (token == null) {
        print('No auth token available for getting online users');
        return [];
      }

      final response = await _dio.get('${ApiService.baseUrl}/users/online');
      final data = response.data;

      if (data['onlineUsers'] is List) {
        return List<String>.from(data['onlineUsers']);
      } else {
        print('Unexpected onlineUsers format: ${data['onlineUsers']}');
        return [];
      }
    } catch (e) {
      print('Error getting online users: $e');
      return [];
    }
  }
}