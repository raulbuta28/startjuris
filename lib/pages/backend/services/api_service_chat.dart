import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_models.dart';
import 'api_service.dart';

class UserPreferences {
  final bool isDarkMode;
  final bool isReadingMode;
  final double fontSize;
  final String fontFamily;
  final Set<String> highlightedSections;
  final Set<String> savedSections;
  final Map<String, dynamic> studyPlans;

  UserPreferences({
    this.isDarkMode = false,
    this.isReadingMode = false,
    this.fontSize = 16.0,
    this.fontFamily = 'Poppins',
    Set<String>? highlightedSections,
    Set<String>? savedSections,
    Map<String, dynamic>? studyPlans,
  })  : highlightedSections = highlightedSections ?? {},
        savedSections = savedSections ?? {},
        studyPlans = studyPlans ?? {};

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      isDarkMode: json['isDarkMode'] ?? false,
      isReadingMode: json['isReadingMode'] ?? false,
      fontSize: (json['fontSize'] ?? 16.0).toDouble(),
      fontFamily: json['fontFamily'] ?? 'Poppins',
      highlightedSections: Set<String>.from(json['highlightedSections'] ?? []),
      savedSections: Set<String>.from(json['savedSections'] ?? []),
      studyPlans: Map<String, dynamic>.from(json['studyPlans'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'isReadingMode': isReadingMode,
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'highlightedSections': highlightedSections.toList(),
      'savedSections': savedSections.toList(),
      'studyPlans': studyPlans,
    };
  }
}

class ApiServiceChat extends ApiService {
  WebSocketChannel? _dashboardWsChannel;
  Stream<dynamic>? _dashboardWsStream;

  ApiServiceChat({super.token});

  Future<List<Conversation>> getConversations() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/conversations'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Conversation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load conversations');
      }
    } catch (e) {
      throw Exception('Error getting conversations: $e');
    }
  }

  Future<List<Message>> getMessages(String conversationId) async {
    try {
      print('Fetching messages for conversation: $conversationId');
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/conversations/$conversationId/messages'),
        headers: headers,
      );

      print('Messages response status: ${response.statusCode}');
      print('Messages response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final messages = data.map((json) {
          try {
            return Message.fromJson(json);
          } catch (e) {
            print('Error parsing message: $e');
            print('Problematic JSON: $json');
            rethrow;
          }
        }).toList();

        print('Successfully parsed ${messages.length} messages');
        return messages;
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Failed to load messages: ${error['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error getting messages: $e');
      throw Exception('Error getting messages: $e');
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required String recipientId,
    required String text,
    String? mediaUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('Sending message to recipient: $recipientId');
      print('Message text: $text');

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/messages/send/$recipientId'),
        headers: headers,
        body: jsonEncode({
          'text': text,
          if (mediaUrl != null) 'mediaUrl': mediaUrl,
          if (metadata != null) 'metadata': metadata,
        }),
      );

      print('Send message response status: ${response.statusCode}');
      print('Send message response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (!responseData.containsKey('message') || !responseData.containsKey('conversation')) {
          throw Exception('Invalid response format from server');
        }
        return responseData;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to send message');
      }
    } catch (e) {
      print('Error in sendMessage: $e');
      rethrow;
    }
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/messages/mark-read/$messageId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark message as read');
      }
    } catch (e) {
      throw Exception('Error marking message as read: $e');
    }
  }

  Future<void> markMessageAsDelivered(String messageId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/messages/mark-delivered/$messageId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark message as delivered');
      }
    } catch (e) {
      throw Exception('Error marking message as delivered: $e');
    }
  }

  Future<String> uploadChatMedia(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/messages/upload-media'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      request.files.add(
        await http.MultipartFile.fromPath('media', file.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['mediaUrl'];
      } else {
        throw Exception('Failed to upload media');
      }
    } catch (e) {
      print('Error uploading media: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> editMessage(String messageId, String newText) async {
    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/messages/$messageId'),
      headers: headers,
      body: jsonEncode({'text': newText}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to edit message');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/messages/$messageId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to delete message');
    }
  }

  Future<Map<String, dynamic>> createGroupChat({
    required String name,
    required List<String> participantIds,
    String? avatar,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/conversations/group'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'participants': participantIds,
        if (avatar != null) 'avatar': avatar,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to create group');
    }
  }

  Future<Map<String, dynamic>> updateGroupSettings({
    required String groupId,
    String? name,
    String? avatar,
    List<String>? addParticipants,
    List<String>? removeParticipants,
    List<String>? addAdmins,
    List<String>? removeAdmins,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/conversations/group/$groupId'),
      headers: headers,
      body: jsonEncode({
        if (name != null) 'name': name,
        if (avatar != null) 'avatar': avatar,
        if (addParticipants != null) 'addParticipants': addParticipants,
        if (removeParticipants != null) 'removeParticipants': removeParticipants,
        if (addAdmins != null) 'addAdmins': addAdmins,
        if (removeAdmins != null) 'removeAdmins': removeAdmins,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to update group settings');
    }
  }

  Future<void> togglePinConversation(String conversationId) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/conversations/$conversationId/pin'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to toggle pin status');
    }
  }

  Future<void> toggleMuteConversation(String conversationId) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/conversations/$conversationId/mute'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to toggle mute status');
    }
  }

  Future<Map<String, dynamic>> getConversationStats(String conversationId) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/conversations/$conversationId/stats'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to get conversation stats');
    }
  }

  Future<List<dynamic>> searchMessages({
    required String conversationId,
    required String query,
    String? type,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParams = {
      'query': query,
      if (type != null) 'type': type,
      if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
      if (toDate != null) 'toDate': toDate.toIso8601String(),
    };

    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/conversations/$conversationId/search').replace(
        queryParameters: queryParams,
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to search messages');
    }
  }

  void connectDashboardWebSocket() {
    try {
      print('Connecting to Dashboard WebSocket at: ${ApiService.wsBaseUrl}/dashboard/ws');
      _dashboardWsChannel = WebSocketChannel.connect(
        Uri.parse('${ApiService.wsBaseUrl}/dashboard/ws'),
      );

      _dashboardWsStream = _dashboardWsChannel!.stream.asBroadcastStream();

      _dashboardWsChannel!.sink.add(jsonEncode({
        'type': 'ping',
      }));

      print('Dashboard WebSocket connected successfully');
    } catch (e) {
      print('Dashboard WebSocket connection error: $e');
    }
  }

  Stream<dynamic>? get dashboardWebSocketStream => _dashboardWsStream;

  void disconnectDashboardWebSocket() {
    _dashboardWsChannel?.sink.close();
    _dashboardWsChannel = null;
    _dashboardWsStream = null;
    print('Dashboard WebSocket disconnected');
  }
}