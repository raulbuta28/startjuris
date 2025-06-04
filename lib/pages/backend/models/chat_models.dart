import 'package:startjuris/pages/backend/models/user_model.dart';

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String recipientId;
  final String text;
  final DateTime timestamp;
  bool isDelivered;
  bool isRead;
  final String? mediaUrl;
  final Map<String, dynamic>? metadata;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.recipientId,
    required this.text,
    required this.timestamp,
    this.isDelivered = false,
    this.isRead = false,
    this.mediaUrl,
    this.metadata,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing message JSON: $json'); // Debug log
      return Message(
        id: json['id'] ?? '',
        conversationId: json['conversationId'] ?? json['conversation_id'] ?? '',
        senderId: json['senderId'] ?? json['sender_id'] ?? '',
        recipientId: json['recipientId'] ?? json['recipient_id'] ?? '',
        text: json['text'] ?? '',
        timestamp: json['timestamp'] != null 
            ? DateTime.parse(json['timestamp']).toLocal()
            : DateTime.now(),
        isDelivered: json['isDelivered'] ?? json['is_delivered'] ?? false,
        isRead: json['isRead'] ?? json['is_read'] ?? false,
        mediaUrl: json['mediaUrl'] ?? json['media_url'],
        metadata: json['metadata'],
      );
    } catch (e) {
      print('Error parsing message: $e'); // Debug log
      print('Problematic JSON: $json'); // Debug log
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'recipientId': recipientId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isDelivered': isDelivered,
      'isRead': isRead,
      'mediaUrl': mediaUrl,
      'metadata': metadata,
    };
  }
}

class UserDetails {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? bio;

  UserDetails({
    this.id = '',
    this.username = '',
    this.avatarUrl,
    this.bio,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatarUrl': avatarUrl,
      'bio': bio,
    };
  }
}

class Conversation {
  final String id;
  final List<String> participants;
  List<Message>? messages;
  int? unreadCount;
  final bool isGroup;
  final String? groupName;
  final String? groupAvatar;
  final List<String>? adminIds;
  final List<UserDetails>? participantDetails;
  DateTime lastActivity;

  Conversation({
    required this.id,
    required this.participants,
    this.messages,
    this.unreadCount = 0,
    this.isGroup = false,
    this.groupName,
    this.groupAvatar,
    this.adminIds,
    this.participantDetails,
    required this.lastActivity,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      participants: List<String>.from(json['participants']),
      messages: json['messages'] != null
          ? List<Message>.from(
              json['messages'].map((x) => Message.fromJson(x)))
          : null,
      unreadCount: json['unreadCount'],
      isGroup: json['isGroup'] ?? false,
      groupName: json['groupName'],
      groupAvatar: json['groupAvatar'],
      adminIds: json['adminIds'] != null
          ? List<String>.from(json['adminIds'])
          : null,
      participantDetails: json['participantDetails'] != null
          ? List<UserDetails>.from(
              json['participantDetails'].map((x) => UserDetails.fromJson(x)))
          : null,
      lastActivity: json['lastActivity'] != null
          ? DateTime.parse(json['lastActivity'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'messages': messages?.map((x) => x.toJson()).toList(),
      'unreadCount': unreadCount,
      'isGroup': isGroup,
      'groupName': groupName,
      'groupAvatar': groupAvatar,
      'adminIds': adminIds,
      'participantDetails': participantDetails?.map((x) => x.toJson()).toList(),
      'lastActivity': lastActivity.toIso8601String(),
    };
  }
} 