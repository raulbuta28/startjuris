class Reflection {
  final String id;
  final String title;
  final String content;
  final String mood;
  final List<String> tags;
  final DateTime timestamp;

  Reflection({
    required this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.tags,
    required this.timestamp,
  });

  Reflection copyWith({
    String? id,
    String? title,
    String? content,
    String? mood,
    List<String>? tags,
    DateTime? timestamp,
  }) {
    return Reflection(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'mood': mood,
      'tags': tags,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Reflection.fromJson(Map<String, dynamic> json) {
    return Reflection(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      mood: json['mood'] as String,
      tags: List<String>.from(json['tags'] as List),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
} 