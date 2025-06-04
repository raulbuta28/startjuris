class SleepData {
  final DateTime bedtime;
  final DateTime wakeTime;
  final int sleepQuality; // 1-5
  final List<String> tags;
  final Map<String, bool> habits;
  final String? notes;
  final Map<String, int> sleepStages; // minutes in each stage

  SleepData({
    required this.bedtime,
    required this.wakeTime,
    this.sleepQuality = 3,
    this.tags = const [],
    this.habits = const {},
    this.notes,
    this.sleepStages = const {
      'light': 0,
      'deep': 0,
      'rem': 0,
    },
  });

  Duration get duration => wakeTime.difference(bedtime);

  Map<String, dynamic> toJson() => {
    'bedtime': bedtime.toIso8601String(),
    'wakeTime': wakeTime.toIso8601String(),
    'sleepQuality': sleepQuality,
    'tags': tags,
    'habits': habits,
    'notes': notes,
    'sleepStages': sleepStages,
  };

  factory SleepData.fromJson(Map<String, dynamic> json) {
    return SleepData(
      bedtime: DateTime.parse(json['bedtime']),
      wakeTime: DateTime.parse(json['wakeTime']),
      sleepQuality: json['sleepQuality'] ?? 3,
      tags: List<String>.from(json['tags'] ?? []),
      habits: Map<String, bool>.from(json['habits'] ?? {}),
      notes: json['notes'],
      sleepStages: Map<String, int>.from(json['sleepStages'] ?? {
        'light': 0,
        'deep': 0,
        'rem': 0,
      }),
    );
  }

  String getFormattedDuration() {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  double getSleepScore() {
    double score = 0;
    
    // Durata somnului (40%)
    final idealDuration = const Duration(hours: 8);
    final durationDiff = (duration - idealDuration).abs();
    score += 40 * (1 - (durationDiff.inMinutes / 240).clamp(0, 1));
    
    // Calitatea somnului (30%)
    score += 30 * (sleepQuality / 5);
    
    // Consistența orei de culcare (20%)
    final idealBedtime = DateTime(
      bedtime.year,
      bedtime.month,
      bedtime.day,
      22, // 10 PM
      0,
    );
    final bedtimeDiff = (bedtime.difference(idealBedtime)).abs();
    score += 20 * (1 - (bedtimeDiff.inMinutes / 120).clamp(0, 1));
    
    // Obiceiuri sănătoase (10%)
    if (habits.isNotEmpty) {
      final goodHabits = habits.values.where((v) => v).length;
      score += 10 * (goodHabits / habits.length);
    }
    
    return score;
  }

  Map<String, String> getInsights() {
    final insights = <String, String>{};
    
    // Durata somnului
    if (duration.inHours < 7) {
      insights['duration'] = 'Ai dormit mai puțin decât recomandat. Încearcă să te culci mai devreme.';
    } else if (duration.inHours > 9) {
      insights['duration'] = 'Ai dormit mai mult decât de obicei. Verifică calitatea somnului.';
    }
    
    // Ora de culcare
    if (bedtime.hour >= 23) {
      insights['bedtime'] = 'Te-ai culcat târziu. Încearcă să te culci mai devreme pentru un somn mai odihnitor.';
    }
    
    // Calitatea somnului
    if (sleepQuality < 3) {
      insights['quality'] = 'Calitatea somnului a fost sub medie. Verifică factorii care ar fi putut influența.';
    }
    
    return insights;
  }
} 