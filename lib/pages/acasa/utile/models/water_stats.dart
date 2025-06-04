class WaterEntry {
  final DateTime timestamp;
  final double volume; // în ml
  final String beverageType;
  final int caffeineContent; // în mg
  final int sodiumContent; // în mg
  final String container;
  final String? note;

  WaterEntry({
    required this.timestamp,
    required this.volume,
    required this.beverageType,
    this.caffeineContent = 0,
    this.sodiumContent = 0,
    required this.container,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'volume': volume,
      'beverageType': beverageType,
      'caffeineContent': caffeineContent,
      'sodiumContent': sodiumContent,
      'container': container,
      'note': note,
    };
  }

  factory WaterEntry.fromJson(Map<String, dynamic> json) {
    return WaterEntry(
      timestamp: DateTime.parse(json['timestamp']),
      volume: json['volume'].toDouble(),
      beverageType: json['beverageType'],
      caffeineContent: json['caffeineContent'] ?? 0,
      sodiumContent: json['sodiumContent'] ?? 0,
      container: json['container'],
      note: json['note'],
    );
  }
}

class WaterStats {
  final Map<String, List<WaterEntry>> dailyEntries; // data -> liste de intrări
  final Map<String, double> dailyGoals; // data -> obiectiv
  final Map<String, int> streaks; // data -> zile consecutive
  final Map<String, Map<String, int>> beveragePreferences; // data -> {tip -> count}
  final Map<String, int> dailyCaffeineIntake; // data -> mg
  final Map<String, int> dailySodiumIntake; // data -> mg
  final Map<String, Map<int, double>> averageIntakeByHour; // oră -> ml mediu
  final Map<String, int> reminderResponses; // data -> număr de răspunsuri la reminder
  final Map<String, Map<String, double>> weatherImpact; // data -> {temp, humidity} -> ml

  WaterStats({
    Map<String, List<WaterEntry>>? dailyEntries,
    Map<String, double>? dailyGoals,
    Map<String, int>? streaks,
    Map<String, Map<String, int>>? beveragePreferences,
    Map<String, int>? dailyCaffeineIntake,
    Map<String, int>? dailySodiumIntake,
    Map<String, Map<int, double>>? averageIntakeByHour,
    Map<String, int>? reminderResponses,
    Map<String, Map<String, double>>? weatherImpact,
  }) : dailyEntries = dailyEntries ?? {},
       dailyGoals = dailyGoals ?? {},
       streaks = streaks ?? {},
       beveragePreferences = beveragePreferences ?? {},
       dailyCaffeineIntake = dailyCaffeineIntake ?? {},
       dailySodiumIntake = dailySodiumIntake ?? {},
       averageIntakeByHour = averageIntakeByHour ?? {},
       reminderResponses = reminderResponses ?? {},
       weatherImpact = weatherImpact ?? {};

  Map<String, dynamic> toJson() {
    return {
      'dailyEntries': dailyEntries.map((key, value) => 
        MapEntry(key, value.map((e) => e.toJson()).toList())),
      'dailyGoals': dailyGoals,
      'streaks': streaks,
      'beveragePreferences': beveragePreferences.map((key, value) =>
        MapEntry(key, Map<String, dynamic>.from(value))),
      'dailyCaffeineIntake': dailyCaffeineIntake,
      'dailySodiumIntake': dailySodiumIntake,
      'averageIntakeByHour': averageIntakeByHour.map((key, value) =>
        MapEntry(key, value.map((k, v) => MapEntry(k.toString(), v)))),
      'reminderResponses': reminderResponses,
      'weatherImpact': weatherImpact.map((key, value) =>
        MapEntry(key, Map<String, dynamic>.from(value))),
    };
  }

  factory WaterStats.fromJson(Map<String, dynamic> json) {
    return WaterStats(
      dailyEntries: (json['dailyEntries'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          key,
          (value as List).map((e) => WaterEntry.fromJson(e)).toList(),
        ),
      ) ?? {},
      dailyGoals: (json['dailyGoals'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value.toDouble()),
      ) ?? {},
      streaks: (json['streaks'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as int),
      ) ?? {},
      beveragePreferences: (json['beveragePreferences'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          key,
          (value as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, v as int),
          ),
        ),
      ) ?? {},
      dailyCaffeineIntake: (json['dailyCaffeineIntake'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as int),
      ) ?? {},
      dailySodiumIntake: (json['dailySodiumIntake'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as int),
      ) ?? {},
      averageIntakeByHour: (json['averageIntakeByHour'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          key,
          (value as Map<String, dynamic>).map(
            (k, v) => MapEntry(int.parse(k), (v as num).toDouble()),
          ),
        ),
      ) ?? {},
      reminderResponses: (json['reminderResponses'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as int),
      ) ?? {},
      weatherImpact: (json['weatherImpact'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          key,
          (value as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ),
        ),
      ) ?? {},
    );
  }

  WaterStats copyWith({
    Map<String, List<WaterEntry>>? dailyEntries,
    Map<String, double>? dailyGoals,
    Map<String, int>? streaks,
    Map<String, Map<String, int>>? beveragePreferences,
    Map<String, int>? dailyCaffeineIntake,
    Map<String, int>? dailySodiumIntake,
    Map<String, Map<int, double>>? averageIntakeByHour,
    Map<String, int>? reminderResponses,
    Map<String, Map<String, double>>? weatherImpact,
  }) {
    return WaterStats(
      dailyEntries: dailyEntries ?? this.dailyEntries,
      dailyGoals: dailyGoals ?? this.dailyGoals,
      streaks: streaks ?? this.streaks,
      beveragePreferences: beveragePreferences ?? this.beveragePreferences,
      dailyCaffeineIntake: dailyCaffeineIntake ?? this.dailyCaffeineIntake,
      dailySodiumIntake: dailySodiumIntake ?? this.dailySodiumIntake,
      averageIntakeByHour: averageIntakeByHour ?? this.averageIntakeByHour,
      reminderResponses: reminderResponses ?? this.reminderResponses,
      weatherImpact: weatherImpact ?? this.weatherImpact,
    );
  }

  // Metode utilitare
  double getTodayProgress() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final entries = dailyEntries[today] ?? [];
    return entries.fold(0.0, (sum, entry) => sum + entry.volume);
  }

  double getTodayGoal() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return dailyGoals[today] ?? 2500;
  }

  int getCurrentStreak() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return streaks[today] ?? 0;
  }

  Map<String, int> getTodayBeverageBreakdown() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return beveragePreferences[today] ?? {};
  }

  int getTodayCaffeineIntake() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return dailyCaffeineIntake[today] ?? 0;
  }

  int getTodaySodiumIntake() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return dailySodiumIntake[today] ?? 0;
  }

  List<WaterEntry> getTodayEntries() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return dailyEntries[today] ?? [];
  }

  void addEntry(WaterEntry entry) {
    final date = entry.timestamp.toIso8601String().split('T')[0];
    
    // Inițializează toate map-urile necesare pentru data curentă
    dailyEntries[date] = dailyEntries[date] ?? [];
    beveragePreferences[date] = beveragePreferences[date] ?? {};
    averageIntakeByHour[date] = averageIntakeByHour[date] ?? {};
    
    // Adaugă intrarea
    dailyEntries[date]!.add(entry);

    // Actualizează preferințele pentru băuturi
    beveragePreferences[date]![entry.beverageType] = 
      (beveragePreferences[date]![entry.beverageType] ?? 0) + 1;

    // Actualizează aportul de cafeină
    dailyCaffeineIntake[date] = (dailyCaffeineIntake[date] ?? 0) + entry.caffeineContent;

    // Actualizează aportul de sodiu
    dailySodiumIntake[date] = (dailySodiumIntake[date] ?? 0) + entry.sodiumContent;

    // Actualizează media pe ore
    final hour = entry.timestamp.hour;
    final currentAvg = averageIntakeByHour[date]![hour] ?? 0;
    final count = dailyEntries[date]!.where((e) => e.timestamp.hour == hour).length;
    averageIntakeByHour[date]![hour] = (currentAvg * (count - 1) + entry.volume) / count;

    // Actualizează streak-ul
    _updateStreak(date);
  }

  void _updateStreak(String date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1))
      .toIso8601String().split('T')[0];
    
    if (!streaks.containsKey(date)) {
      if (streaks.containsKey(yesterday) && 
          (dailyEntries[yesterday]?.isNotEmpty ?? false)) {
        streaks[date] = (streaks[yesterday] ?? 0) + 1;
      } else {
        streaks[date] = 1;
      }
    }
  }

  void updateWeatherImpact(String date, double temperature, double humidity) {
    weatherImpact[date] = {
      'temperature': temperature,
      'humidity': humidity,
    };
  }

  void incrementReminderResponse(String date) {
    reminderResponses[date] = (reminderResponses[date] ?? 0) + 1;
  }

  void incrementWaterIntake(double volume) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final entry = WaterEntry(
      timestamp: DateTime.now(),
      volume: volume,
      beverageType: 'Apă plată',
      container: 'Adăugare rapidă',
    );
    addEntry(entry);
  }

  void resetWaterIntake() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    dailyEntries[today]?.clear();
    beveragePreferences[today]?.clear();
    dailyCaffeineIntake[today] = 0;
    dailySodiumIntake[today] = 0;
  }

  void updateDailyGoal(String date, double goal) {
    dailyGoals[date] = goal;
  }
} 