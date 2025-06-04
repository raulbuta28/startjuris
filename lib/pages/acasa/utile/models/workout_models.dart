import 'package:flutter/material.dart';

enum ExerciseDifficulty { beginner, intermediate, advanced }

enum ExerciseCategory {
  office,
  morning,
  evening,
  fullBody,
  stretching,
  meditation,
  eyecare,
  posture
}

class Exercise {
  final String id;
  final String name;
  final String description;
  final Duration duration;
  final List<String> steps;
  final IconData icon;
  final Color color;
  final ExerciseDifficulty difficulty;
  final ExerciseCategory category;
  final int caloriesBurn;
  final String animationPath;
  final List<String> tips;
  final Duration restPeriod;
  final List<String> targetMuscles;
  final bool requiresEquipment;
  final String? equipmentNeeded;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.steps,
    required this.icon,
    required this.color,
    required this.difficulty,
    required this.category,
    required this.caloriesBurn,
    required this.animationPath,
    required this.tips,
    required this.restPeriod,
    required this.targetMuscles,
    this.requiresEquipment = false,
    this.equipmentNeeded,
  });
}

class WorkoutRoutine {
  final String id;
  final String name;
  final String description;
  final List<Exercise> exercises;
  final ExerciseDifficulty difficulty;
  final Duration totalDuration;
  final int totalCalories;
  final String imageUrl;
  final List<String> benefits;

  WorkoutRoutine({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.difficulty,
    required this.totalDuration,
    required this.totalCalories,
    required this.imageUrl,
    required this.benefits,
  });
}

class UserProgress {
  final String userId;
  final int totalWorkouts;
  final Duration totalTime;
  final int totalCaloriesBurned;
  final int currentStreak;
  final int longestStreak;
  final Map<String, int> exerciseCompletion;
  final List<Achievement> achievements;

  UserProgress({
    required this.userId,
    required this.totalWorkouts,
    required this.totalTime,
    required this.totalCaloriesBurned,
    required this.currentStreak,
    required this.longestStreak,
    required this.exerciseCompletion,
    required this.achievements,
  });
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.isUnlocked,
    this.unlockedAt,
  });
} 