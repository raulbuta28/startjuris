import 'package:json_annotation/json_annotation.dart';

part 'level_model.g.dart';

@JsonSerializable()
class Level {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'current_level')
  final int currentLevel;
  final int experience;
  @JsonKey(name: 'next_level')
  final int nextLevel;
  final List<Badge> badges;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Level({
    required this.id,
    required this.userId,
    required this.currentLevel,
    required this.experience,
    required this.nextLevel,
    required this.badges,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Level.fromJson(Map<String, dynamic> json) => _$LevelFromJson(json);
  Map<String, dynamic> toJson() => _$LevelToJson(this);
}

@JsonSerializable()
class Badge {
  final int id;
  final String name;
  final String description;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);
  Map<String, dynamic> toJson() => _$BadgeToJson(this);
} 