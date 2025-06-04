import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  @JsonKey(required: true)
  final String id;
  
  @JsonKey(required: true)
  final String username;
  
  @JsonKey(required: false)
  final String? email;
  
  @JsonKey(required: false)
  final String? bio;
  
  @JsonKey(required: false)
  final String? avatarUrl;
  
  @JsonKey(required: false)
  final String? phone;
  
  @JsonKey(required: false)
  final String? location;
  
  @JsonKey(required: false)
  final String? education;
  
  @JsonKey(required: false)
  final String? work;
  
  @JsonKey(defaultValue: false)
  final bool isPrivate;
  
  @JsonKey(defaultValue: <String>[])
  final List<String> followers;
  
  @JsonKey(defaultValue: <String>[])
  final List<String> following;

  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;

  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  @JsonKey(defaultValue: <String>[])
  final List<String> conversations;

  User({
    required this.id,
    required this.username,
    this.email,
    this.bio,
    this.avatarUrl,
    this.phone,
    this.location,
    this.education,
    this.work,
    this.isPrivate = false,
    this.followers = const [],
    this.following = const [],
    this.createdAt,
    this.updatedAt,
    this.conversations = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      bio: json['bio'],
      avatarUrl: json['avatarUrl'],
      phone: json['phone'],
      location: json['location'],
      education: json['education'],
      work: json['work'],
      following: List<String>.from(json['following'] ?? []),
      followers: List<String>.from(json['followers'] ?? []),
      conversations: List<String>.from(json['conversations'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'phone': phone,
      'location': location,
      'education': education,
      'work': work,
      'following': following,
      'followers': followers,
      'conversations': conversations,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? bio,
    String? avatarUrl,
    String? phone,
    String? location,
    String? education,
    String? work,
    bool? isPrivate,
    List<String>? followers,
    List<String>? following,
    List<String>? conversations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      education: education ?? this.education,
      work: work ?? this.work,
      isPrivate: isPrivate ?? this.isPrivate,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      conversations: conversations ?? this.conversations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 