import 'package:json_annotation/json_annotation.dart';

part 'performance_model.g.dart';

@JsonSerializable()
class Performance {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'total_cases_solved')
  final int totalCasesSolved;
  @JsonKey(name: 'success_rate')
  final double successRate;
  @JsonKey(name: 'average_score')
  final double averageScore;
  @JsonKey(name: 'weekly_progress')
  final List<ProgressPoint> weeklyProgress;
  @JsonKey(name: 'monthly_progress')
  final List<ProgressPoint> monthlyProgress;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Performance({
    required this.id,
    required this.userId,
    required this.totalCasesSolved,
    required this.successRate,
    required this.averageScore,
    required this.weeklyProgress,
    required this.monthlyProgress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Performance.fromJson(Map<String, dynamic> json) =>
      _$PerformanceFromJson(json);
  Map<String, dynamic> toJson() => _$PerformanceToJson(this);
}

@JsonSerializable()
class ProgressPoint {
  final DateTime date;
  final double value;

  ProgressPoint({
    required this.date,
    required this.value,
  });

  factory ProgressPoint.fromJson(Map<String, dynamic> json) =>
      _$ProgressPointFromJson(json);
  Map<String, dynamic> toJson() => _$ProgressPointToJson(this);
} 