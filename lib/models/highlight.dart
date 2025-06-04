import 'package:flutter/material.dart';

class Highlight {
  final String text;
  final Color color;
  final String? note;
  final List<Offset>? points;
  final DateTime createdAt;

  Highlight({
    required this.text,
    required this.color,
    this.note,
    this.points,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'color': color.value,
      'note': note,
      'points': points?.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      text: json['text'] as String,
      color: Color(json['color'] as int),
      note: json['note'] as String?,
      points: (json['points'] as List?)?.map((p) => 
        Offset(p['dx'] as double, p['dy'] as double)
      ).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
} 