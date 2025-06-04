// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Performance _$PerformanceFromJson(Map<String, dynamic> json) => Performance(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      totalCasesSolved: (json['total_cases_solved'] as num).toInt(),
      successRate: (json['success_rate'] as num).toDouble(),
      averageScore: (json['average_score'] as num).toDouble(),
      weeklyProgress: (json['weekly_progress'] as List<dynamic>)
          .map((e) => ProgressPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      monthlyProgress: (json['monthly_progress'] as List<dynamic>)
          .map((e) => ProgressPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PerformanceToJson(Performance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'total_cases_solved': instance.totalCasesSolved,
      'success_rate': instance.successRate,
      'average_score': instance.averageScore,
      'weekly_progress': instance.weeklyProgress,
      'monthly_progress': instance.monthlyProgress,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

ProgressPoint _$ProgressPointFromJson(Map<String, dynamic> json) =>
    ProgressPoint(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
    );

Map<String, dynamic> _$ProgressPointToJson(ProgressPoint instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'value': instance.value,
    };
