// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'username'],
  );
  return User(
    id: json['id'] as String,
    username: json['username'] as String,
    email: json['email'] as String?,
    bio: json['bio'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    phone: json['phone'] as String?,
    location: json['location'] as String?,
    education: json['education'] as String?,
    work: json['work'] as String?,
    isPrivate: json['isPrivate'] as bool? ?? false,
    followers: (json['followers'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    following: (json['following'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt'] as String),
    conversations: (json['conversations'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'bio': instance.bio,
      'avatarUrl': instance.avatarUrl,
      'phone': instance.phone,
      'location': instance.location,
      'education': instance.education,
      'work': instance.work,
      'isPrivate': instance.isPrivate,
      'followers': instance.followers,
      'following': instance.following,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'conversations': instance.conversations,
    };
