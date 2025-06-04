class PomodoroStats {
  final int totalFocusMinutes;
  final int completedSessions;
  final int completedCycles;
  final int dailyStreak;
  final Map<String, int> dailyFocusMinutes;
  final DateTime lastSessionDate;

  PomodoroStats({
    this.totalFocusMinutes = 0,
    this.completedSessions = 0,
    this.completedCycles = 0,
    this.dailyStreak = 0,
    Map<String, int>? dailyFocusMinutes,
    DateTime? lastSessionDate,
  }) : dailyFocusMinutes = dailyFocusMinutes ?? {},
       lastSessionDate = lastSessionDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'totalFocusMinutes': totalFocusMinutes,
      'completedSessions': completedSessions,
      'completedCycles': completedCycles,
      'dailyStreak': dailyStreak,
      'dailyFocusMinutes': dailyFocusMinutes,
      'lastSessionDate': lastSessionDate.toIso8601String(),
    };
  }

  factory PomodoroStats.fromJson(Map<String, dynamic> json) {
    return PomodoroStats(
      totalFocusMinutes: json['totalFocusMinutes'] ?? 0,
      completedSessions: json['completedSessions'] ?? 0,
      completedCycles: json['completedCycles'] ?? 0,
      dailyStreak: json['dailyStreak'] ?? 0,
      dailyFocusMinutes: Map<String, int>.from(json['dailyFocusMinutes'] ?? {}),
      lastSessionDate: json['lastSessionDate'] != null 
          ? DateTime.parse(json['lastSessionDate'])
          : DateTime.now(),
    );
  }

  PomodoroStats copyWith({
    int? totalFocusMinutes,
    int? completedSessions,
    int? completedCycles,
    int? dailyStreak,
    Map<String, int>? dailyFocusMinutes,
    DateTime? lastSessionDate,
  }) {
    return PomodoroStats(
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      completedSessions: completedSessions ?? this.completedSessions,
      completedCycles: completedCycles ?? this.completedCycles,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      dailyFocusMinutes: dailyFocusMinutes ?? this.dailyFocusMinutes,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
    );
  }

  void addFocusMinutes(int minutes) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    dailyFocusMinutes[today] = (dailyFocusMinutes[today] ?? 0) + minutes;
  }

  int getTodayFocusMinutes() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return dailyFocusMinutes[today] ?? 0;
  }

  bool hasCompletedSessionToday() {
    return getTodayFocusMinutes() > 0;
  }

  PomodoroStats updateDailyStreak() {
    final today = DateTime.now();
    final lastSession = lastSessionDate;
    final difference = today.difference(lastSession).inDays;

    if (difference > 1) {
      return copyWith(
        dailyStreak: hasCompletedSessionToday() ? 1 : 0,
        lastSessionDate: today,
      );
    } else if (difference == 1 && hasCompletedSessionToday()) {
      return copyWith(
        dailyStreak: dailyStreak + 1,
        lastSessionDate: today,
      );
    }
    return this;
  }
} 