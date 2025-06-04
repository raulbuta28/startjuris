import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/chat_models.dart';
import '../models/user_model.dart';
import '../services/api_service_chat.dart';
import '../services/api_service_login.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:math' as math;

class ChatProvider with ChangeNotifier {
  final ApiServiceChat _apiService;
  ApiServiceLogin _apiServiceLogin;
  List<Conversation> _conversations = [];
  Map<String, List<Message>> _messages = {};
  Map<String, User> _userCache = {};
  bool _isLoading = false;
  String? _error;
  WebSocketChannel? _channel;
  StreamController<Message> _messageController = StreamController<Message>.broadcast();
  Timer? _reconnectTimer;
  Timer? _refreshTimer;
  int _totalUnreadCount = 0;
  bool _disposed = false;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;
  final Map<String, bool> _onlineUsers = {};
  Timer? _onlineStatusTimer;

  ChatProvider(String? token)
      : _apiService = ApiServiceChat(token: token),
        _apiServiceLogin = ApiServiceLogin(token: token) {
    initializeDateFormatting('ro_RO');
    _initializeChat();
    _startOnlineStatusTimer();
  }

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Stream<Message> get messageStream => _messageController.stream;
  int get totalUnreadCount => _totalUnreadCount;

  Future<void> _initializeChat() async {
    if (_apiService.token == null) {
      print('No token available, waiting for token...');
      return;
    }

    await loadConversations();
    _initWebSocket();
  }

  void _initWebSocket() {
    if (_disposed || _apiService.token == null) return;

    _reconnectTimer?.cancel();
    _channel?.sink.close();

    final wsUrl = Uri.parse('ws://192.168.8.123:8080/api/ws');
    
    try {
      print('Connecting to WebSocket: ${wsUrl.toString()}');
      
      WebSocket.connect(
        wsUrl.toString(),
        headers: {
          'Authorization': 'Bearer ${_apiService.token}',
        },
      ).then((ws) {
        if (_disposed) {
          ws.close();
          return;
        }

        print('WebSocket connected successfully');
        _channel = IOWebSocketChannel(ws);
        _reconnectAttempts = 0;
        
        _channel?.stream.listen(
          (dynamic message) {
            if (_disposed) return;
            
            print('Received WebSocket message: $message');
            try {
              final data = jsonDecode(message.toString());
              if (data['type'] == 'new_message') {
                final newMessage = Message.fromJson(data['message']);
                final conversation = Conversation.fromJson(data['conversation']);
                
                print('Processing new message: ${newMessage.text}');
                
                final index = _conversations.indexWhere((c) => c.id == conversation.id);
                if (index != -1) {
                  _conversations[index] = conversation;
                } else {
                  _conversations.insert(0, conversation);
                }
                
                if (_conversations[index != -1 ? index : 0].messages == null) {
                  _conversations[index != -1 ? index : 0].messages = [];
                }
                _conversations[index != -1 ? index : 0].messages?.insert(0, newMessage);
                
                if (!_messageController.isClosed) {
                  _messageController.add(newMessage);
                }
                if (!_disposed) {
                  notifyListeners();
                }
              }
            } catch (e) {
              print('Error processing WebSocket message: $e');
            }
          },
          onError: (error) {
            print('WebSocket error: $error');
            _scheduleReconnect();
          },
          onDone: () {
            print('WebSocket connection closed');
            _scheduleReconnect();
          },
          cancelOnError: false,
        );
      }).catchError((e) {
        print('Error connecting to WebSocket: $e');
        _scheduleReconnect();
      });
    } catch (e) {
      print('Error initializing WebSocket: $e');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed || _reconnectAttempts >= maxReconnectAttempts) return;

    _reconnectTimer?.cancel();
    final delay = Duration(seconds: math.min(5 * (_reconnectAttempts + 1), 30));
    print('Scheduling WebSocket reconnect in ${delay.inSeconds} seconds (attempt ${_reconnectAttempts + 1})');
    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      _initWebSocket();
    });
  }

  Future<void> reinitialize() async {
    _disposed = false;
    _reconnectAttempts = 0;
    await _initializeChat();
  }

  Future<void> loadMessages(String conversationId) async {
    try {
      final messages = await _apiService.getMessages(conversationId);
      
      if (_messages.containsKey(conversationId)) {
        final existingMessages = _messages[conversationId] ?? [];
        messages.addAll(existingMessages);
        _messages[conversationId] = messages
            .toSet()
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      } else {
        _messages[conversationId] = messages;
      }
      
      final index = _conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        _conversations[index].messages = _messages[conversationId];
      }
      
      for (var message in messages) {
        if (!message.isRead && message.recipientId == _apiService.currentUserId) {
          markMessageAsRead(message.id);
        }
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading messages: $e');
      rethrow;
    }
  }

  List<Message> getMessagesForConversation(String conversationId) {
    if (_messages.containsKey(conversationId)) {
      return List.from(_messages[conversationId] ?? []);
    }
    
    final conversation = _conversations.firstWhere(
      (c) => c.id == conversationId,
      orElse: () => Conversation(
        id: '',
        participants: [],
        messages: [],
        unreadCount: 0,
        isGroup: false,
        lastActivity: DateTime.now(),
      ),
    );
    
    if (conversation.id.isNotEmpty && conversation.messages != null) {
      _messages[conversationId] = conversation.messages!;
      return List.from(conversation.messages!);
    }
    
    return [];
  }

  Future<void> loadConversations() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final conversations = await _apiService.getConversations();
      
      for (var newConv in conversations) {
        final existingIndex = _conversations.indexWhere((c) => c.id == newConv.id);
        if (existingIndex != -1) {
          final existingMessages = _conversations[existingIndex].messages ?? [];
          if (newConv.messages != null) {
            newConv.messages!.addAll(existingMessages);
            newConv.messages = newConv.messages!
                .toSet()
                .toList()
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          } else {
            newConv.messages = existingMessages;
          }
          
          if (newConv.messages != null && newConv.messages!.isNotEmpty) {
            _messages[newConv.id] = newConv.messages!;
          }
        }
        
        for (String participantId in newConv.participants) {
          if (!_userCache.containsKey(participantId)) {
            try {
              final user = await _apiServiceLogin.getUserDetails(participantId);
              _userCache[participantId] = user;
            } catch (e) {
              print('Error loading user details for $participantId: $e');
              // Skip caching to avoid blocking
            }
          }
        }
      }
      
      _conversations = conversations;
      _calculateTotalUnreadCount();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error loading conversations: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> sendMessage(String recipientId, String text) async {
    try {
      final result = await _apiService.sendMessage(
        recipientId: recipientId,
        text: text,
      );

      final message = Message.fromJson(result['message']);
      final conversation = Conversation.fromJson(result['conversation']);

      final existingIndex = _conversations.indexWhere((c) => c.id == conversation.id);
      if (existingIndex != -1) {
        final existingMessages = _conversations[existingIndex].messages ?? [];
        conversation.messages = existingMessages;
        _conversations[existingIndex] = conversation;
      } else {
        conversation.messages = [];
        _conversations.insert(0, conversation);
      }

      if (!_messages.containsKey(conversation.id)) {
        _messages[conversation.id] = [];
      }
      
      _messages[conversation.id]?.insert(0, message);
      _conversations[existingIndex != -1 ? existingIndex : 0].messages?.insert(0, message);
      
      if (!_userCache.containsKey(recipientId)) {
        try {
          final user = await _apiServiceLogin.getUserDetails(recipientId);
          _userCache[recipientId] = user;
        } catch (e) {
          print('Error loading user details: $e');
        }
      }

      _messageController.add(message);
      notifyListeners();

      return result;
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _apiService.markMessageAsRead(messageId);
      for (var conv in _conversations) {
        if (conv.messages != null) {
          final msgIndex = conv.messages!.indexWhere((m) => m.id == messageId);
          if (msgIndex != -1) {
            conv.messages![msgIndex].isRead = true;
            if (conv.unreadCount != null && conv.unreadCount! > 0) {
              conv.unreadCount = conv.unreadCount! - 1;
            }
            _calculateTotalUnreadCount();
            notifyListeners();
            break;
          }
        }
      }
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  User? getUserDetails(String userId) {
    return _userCache[userId];
  }

  String getOtherParticipantName(Conversation conversation, String currentUserId) {
    if (conversation.isGroup && conversation.groupName != null) {
      return conversation.groupName!;
    }
    
    final otherParticipantId = conversation.participants
        .firstWhere((id) => id != currentUserId, orElse: () => '');
    
    if (otherParticipantId.isEmpty) return 'Unknown User';
    
    final cachedUser = _userCache[otherParticipantId];
    if (cachedUser != null) {
      return cachedUser.username;
    }
    
    _apiServiceLogin.getUserDetails(otherParticipantId).then((user) {
      _userCache[otherParticipantId] = user;
      notifyListeners();
    }).catchError((e) {
      print('Error loading user details: $e');
    });
    
    return 'Loading...';
  }

  String? getOtherParticipantAvatar(Conversation conversation, String currentUserId) {
    if (conversation.isGroup) {
      return conversation.groupAvatar;
    }
    
    final otherParticipantId = conversation.participants
        .firstWhere((id) => id != currentUserId, orElse: () => '');
    
    if (otherParticipantId.isEmpty) return null;
    
    final cachedUser = _userCache[otherParticipantId];
    if (cachedUser != null) {
      return cachedUser.avatarUrl;
    }
    
    return null;
  }

  void _calculateTotalUnreadCount() {
    _totalUnreadCount = _conversations.fold(0, (sum, conv) => sum + (conv.unreadCount ?? 0));
  }

  String formatMessageTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final localTimestamp = timestamp.toLocal();
    final difference = now.difference(localTimestamp);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(localTimestamp);
    } else if (difference.inDays == 1) {
      return 'Ieri ${DateFormat('HH:mm').format(localTimestamp)}';
    } else if (difference.inDays < 7) {
      return '${DateFormat('EEEE', 'ro').format(localTimestamp)} ${DateFormat('HH:mm').format(localTimestamp)}';
    } else {
      return DateFormat('dd MMM HH:mm', 'ro').format(localTimestamp);
    }
  }

  Future<void> cleanup() async {
    try {
      _channel?.sink.close();
      _channel = null;
      
      _reconnectTimer?.cancel();
      _refreshTimer?.cancel();
      
      _reconnectAttempts = 0;
      
      _isLoading = false;
      _error = null;
      
      if (!_disposed) {
        notifyListeners();
      }
    } catch (e) {
      print('Error during ChatProvider cleanup: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    _refreshTimer?.cancel();
    _messageController.close();
    _onlineStatusTimer?.cancel();
    super.dispose();
  }

  Future<void> reloadAfterLogin() async {
    _disposed = false;
    _reconnectAttempts = 0;
    await loadConversations();
    _initWebSocket();
  }

  void _updateConversationInCache(Conversation conversation) {
    final index = _conversations.indexWhere((c) => c.id == conversation.id);
    if (index != -1) {
      _conversations[index] = conversation;
    } else {
      _conversations.insert(0, conversation);
    }
  }

  void _addMessageToCache(Message message) {
    if (!_messages.containsKey(message.conversationId)) {
      _messages[message.conversationId] = [];
    }
    _messages[message.conversationId]!.insert(0, message);
  }

  void _startOnlineStatusTimer() {
    _onlineStatusTimer?.cancel();
    _onlineStatusTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateOnlineStatus();
    });
  }

  Future<void> _updateOnlineStatus() async {
    try {
      if (_apiService.token == null) {
        print('No auth token available for online status update');
        return;
      }
      
      final onlineUsers = await _apiServiceLogin.getOnlineUsers();
      _onlineUsers.clear();
      for (final userId in onlineUsers) {
        _onlineUsers[userId] = true;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating online status: $e');
    }
  }

  bool isUserOnline(String userId) {
    return _onlineUsers[userId] ?? false;
  }

  void updateToken(String? token) {
    _apiServiceLogin = ApiServiceLogin(token: token);
    if (token != null) {
      reinitialize();
    } else {
      cleanup();
    }
  }
}