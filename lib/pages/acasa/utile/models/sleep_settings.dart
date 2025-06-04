import 'package:flutter/material.dart';

class SleepSettings {
  final TimeOfDay bedtime;
  final TimeOfDay wakeTime;
  final bool enableReminders;
  final int reminderOffset;
  final Duration sleepGoal;
  final bool enableSoundscapes;
  final bool enableSmartWakeup;
  final List<String> sleepTags;
  final Map<String, bool> sleepHabits;

  SleepSettings({
    required this.bedtime,
    required this.wakeTime,
    this.enableReminders = true,
    this.reminderOffset = 30,
    this.sleepGoal = const Duration(hours: 8),
    this.enableSoundscapes = true,
    this.enableSmartWakeup = false,
    this.sleepTags = const ['Relaxare', 'Stres', 'Cafea', 'Sport', 'Ecrane'],
    this.sleepHabits = const {
      'Exerciții fizice': false,
      'Cafeină după-amiază': false,
      'Ecrane înainte de culcare': false,
      'Cameră întunecată': true,
      'Temperatură optimă': true,
    },
  });

  Map<String, dynamic> toJson() => {
    'bedtime': {'hour': bedtime.hour, 'minute': bedtime.minute},
    'wakeTime': {'hour': wakeTime.hour, 'minute': wakeTime.minute},
    'enableReminders': enableReminders,
    'reminderOffset': reminderOffset,
    'sleepGoal': sleepGoal.inMinutes,
    'enableSoundscapes': enableSoundscapes,
    'enableSmartWakeup': enableSmartWakeup,
    'sleepTags': sleepTags,
    'sleepHabits': sleepHabits,
  };

  factory SleepSettings.fromJson(Map<String, dynamic> json) {
    return SleepSettings(
      bedtime: json['bedtime'] != null
          ? TimeOfDay(
              hour: json['bedtime']['hour'],
              minute: json['bedtime']['minute'],
            )
          : const TimeOfDay(hour: 22, minute: 0),
      wakeTime: json['wakeTime'] != null
          ? TimeOfDay(
              hour: json['wakeTime']['hour'],
              minute: json['wakeTime']['minute'],
            )
          : const TimeOfDay(hour: 6, minute: 30),
      enableReminders: json['enableReminders'] ?? true,
      reminderOffset: json['reminderOffset'] ?? 30,
      sleepGoal: Duration(minutes: json['sleepGoal'] ?? 480),
      enableSoundscapes: json['enableSoundscapes'] ?? true,
      enableSmartWakeup: json['enableSmartWakeup'] ?? false,
      sleepTags: List<String>.from(json['sleepTags'] ?? []),
      sleepHabits: Map<String, bool>.from(json['sleepHabits'] ?? {}),
    );
  }

  SleepSettings copyWith({
    TimeOfDay? bedtime,
    TimeOfDay? wakeTime,
    bool? enableReminders,
    int? reminderOffset,
    Duration? sleepGoal,
    bool? enableSoundscapes,
    bool? enableSmartWakeup,
    List<String>? sleepTags,
    Map<String, bool>? sleepHabits,
  }) {
    return SleepSettings(
      bedtime: bedtime ?? this.bedtime,
      wakeTime: wakeTime ?? this.wakeTime,
      enableReminders: enableReminders ?? this.enableReminders,
      reminderOffset: reminderOffset ?? this.reminderOffset,
      sleepGoal: sleepGoal ?? this.sleepGoal,
      enableSoundscapes: enableSoundscapes ?? this.enableSoundscapes,
      enableSmartWakeup: enableSmartWakeup ?? this.enableSmartWakeup,
      sleepTags: sleepTags ?? this.sleepTags,
      sleepHabits: sleepHabits ?? this.sleepHabits,
    );
  }

  Duration getTimeUntilBedtime() {
    final now = DateTime.now();
    final todayBedtime = DateTime(
      now.year,
      now.month,
      now.day,
      bedtime.hour,
      bedtime.minute,
    );
    
    if (now.isAfter(todayBedtime)) {
      final tomorrowBedtime = todayBedtime.add(const Duration(days: 1));
      return tomorrowBedtime.difference(now);
    }
    
    return todayBedtime.difference(now);
  }

  String getFormattedSleepDuration() {
    final hours = sleepGoal.inHours;
    final minutes = sleepGoal.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  List<String> getSleepTips() {
    return [
      'Menține o temperatură optimă în dormitor (18-20°C)',
      'Evită ecranele cu o oră înainte de culcare',
      'Practică exerciții de relaxare înainte de somn',
      'Creează o rutină constantă de somn',
      'Evită cafeina după ora 14:00',
      'Asigură-te că dormitorul este suficient de întunecat',
      'Fă exerciții fizice regulate, dar nu înainte de culcare',
      'Evită mesele copioase cu 2-3 ore înainte de somn',
    ];
  }
} 