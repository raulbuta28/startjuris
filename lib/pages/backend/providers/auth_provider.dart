import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/api_service_login.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  String? _token;
  late ApiServiceLogin _apiService;
  late SharedPreferences _prefs;
  static const String TOKEN_KEY = 'auth_token';
  bool _initialized = false;
  Map<String, User> _userDetails = {};

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _token = _prefs.getString(TOKEN_KEY);
      print('Loaded token from storage: $_token');

      _apiService = ApiServiceLogin(token: _token);
      
      if (_token != null) {
        try {
          _currentUser = await _apiService.getProfile();
          print('Successfully loaded user profile');
        } catch (e) {
          print('Error loading profile: $e');
          await logout();
        }
      }
    } catch (e) {
      print('Error in AuthProvider init: $e');
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  bool get isInitialized => _initialized;
  bool get isAuthenticated => _token != null && _currentUser != null;
  String? get token => _token;
  User? get user => _currentUser;
  User? get currentUser => _currentUser;
  ApiServiceLogin get apiService => _apiService;

  Future<void> login({
    required String identifier,
    required String password,
    String? baseUrl,
  }) async {
    try {
      print('Starting login process');

      final tempApiService = ApiServiceLogin(token: null);
      final response = await tempApiService.login(
        identifier: identifier,
        password: password,
        baseUrl: baseUrl,
      );

      _token = response['token'];
      print('Received token: $_token');
      
      _currentUser = User.fromJson(response['user']);
      print('User loaded: ${_currentUser?.username}');

      await _prefs.setString(TOKEN_KEY, _token!);
      print('Token saved to storage');

      _apiService = ApiServiceLogin(token: _token);

      notifyListeners();
      print('Login complete, notified listeners');
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    String? baseUrl,
  }) async {
    try {
      print('Starting registration process');
      
      final tempApiService = ApiServiceLogin(token: null);
      await tempApiService.register(
        username: username,
        email: email,
        password: password,
        baseUrl: baseUrl,
      );
      print('Registration successful');
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      print('Logging out, clearing token and user data');
      _token = null;
      _currentUser = null;
      await _prefs.remove(TOKEN_KEY);
      _apiService = ApiServiceLogin(token: null);
      notifyListeners();
      print('Logout complete, notified listeners');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future<void> refreshProfile() async {
    try {
      if (_token == null) {
        print('No token available for profile refresh');
        return;
      }

      _currentUser = await _apiService.getProfile();
      print('Profile refreshed successfully');
      notifyListeners();
    } catch (e) {
      print('Error refreshing profile: $e');
      if (e.toString().contains('401')) {
        await logout();
      }
    }
  }

  Future<void> updateProfile({
    String? username,
    String? bio,
    String? avatarUrl,
    String? email,
    String? phone,
    String? location,
    String? education,
    String? work,
    bool? isPrivate,
  }) async {
    try {
      if (_token == null) {
        print('No token available for update profile');
        throw Exception('Nu sunteți autentificat');
      }

      print('Current token for update: $_token');
      
      if (avatarUrl != null) {
        print('Attempting to update avatar with file: $avatarUrl');
        final updatedUser = await _apiService.updateAvatar(avatarUrl);
        _currentUser = updatedUser;
        print('Avatar updated successfully');
      } else {
        print('Updating profile data');
        final updatedUser = await _apiService.updateProfile(
          username: username,
          bio: bio,
          email: email,
          phone: phone,
          location: location,
          education: education,
          work: work,
        );
        _currentUser = updatedUser;
        print('Profile updated successfully');
      }
      notifyListeners();
    } catch (e) {
      print('Error in updateProfile: $e');
      rethrow;
    }
  }

  Future<void> followUser(int userId) async {
    try {
      _currentUser = await _apiService.followUser(userId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> searchUsers(String query) async {
    try {
      return await _apiService.searchUsers(query);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> getFollowers() async {
    try {
      return await _apiService.getFollowers();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> getFollowing() async {
    try {
      return await _apiService.getFollowing();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> toggleFollowUser(String userId) async {
    try {
      final result = await _apiService.toggleFollowUser(userId);
      final updatedUser = User.fromJson(result['user']);
      _currentUser = updatedUser;
      notifyListeners();
      return result['isFollowing'];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAvatar(XFile image) async {
    try {
      if (_token == null) {
        throw Exception('Nu sunteți autentificat');
      }

      print('Attempting to update avatar with file: ${image.path}');
      final updatedUser = await _apiService.updateAvatar(
        image.path,
        bytes: kIsWeb ? await image.readAsBytes() : null,
        filename: image.name,
      );
      _currentUser = updatedUser;
      print('Avatar updated successfully');
      notifyListeners();
    } catch (e) {
      print('Error in updateAvatar: $e');
      rethrow;
    }
  }

  Future<void> loadUserDetails(String userId) async {
    try {
      final user = await _apiService.getUserDetails(userId);
      _userDetails[userId] = user;
      notifyListeners();
    } catch (e) {
      print('Error loading user details: $e');
    }
  }

  User? getUserDetails(String userId) {
    return _userDetails[userId];
  }

  Future<bool> testConnection() async {
    try {
      print('Testing backend connection...');
      final tempApiService = ApiServiceLogin(token: null);
      
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/profile'),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('Test connection status: ${response.statusCode}');
      print('Test connection response: ${response.body}');
      
      return response.statusCode == 401;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}