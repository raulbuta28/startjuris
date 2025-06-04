class PomodoroSettings {
  final int workDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final int cyclesBeforeLongBreak;
  final bool autoStartBreaks;
  final bool autoStartNextSession;
  final bool showNotifications;
  final String soundTheme;
  final bool vibrationEnabled;
  final String theme;

  PomodoroSettings({
    this.workDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.cyclesBeforeLongBreak = 4,
    this.autoStartBreaks = false,
    this.autoStartNextSession = false,
    this.showNotifications = true,
    this.soundTheme = 'default',
    this.vibrationEnabled = true,
    this.theme = 'default',
  });

  Map<String, dynamic> toJson() {
    return {
      'workDuration': workDuration,
      'shortBreakDuration': shortBreakDuration,
      'longBreakDuration': longBreakDuration,
      'cyclesBeforeLongBreak': cyclesBeforeLongBreak,
      'autoStartBreaks': autoStartBreaks,
      'autoStartNextSession': autoStartNextSession,
      'showNotifications': showNotifications,
      'soundTheme': soundTheme,
      'vibrationEnabled': vibrationEnabled,
      'theme': theme,
    };
  }

  factory PomodoroSettings.fromJson(Map<String, dynamic> json) {
    return PomodoroSettings(
      workDuration: json['workDuration'] ?? 25,
      shortBreakDuration: json['shortBreakDuration'] ?? 5,
      longBreakDuration: json['longBreakDuration'] ?? 15,
      cyclesBeforeLongBreak: json['cyclesBeforeLongBreak'] ?? 4,
      autoStartBreaks: json['autoStartBreaks'] ?? false,
      autoStartNextSession: json['autoStartNextSession'] ?? false,
      showNotifications: json['showNotifications'] ?? true,
      soundTheme: json['soundTheme'] ?? 'default',
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      theme: json['theme'] ?? 'default',
    );
  }

  PomodoroSettings copyWith({
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? cyclesBeforeLongBreak,
    bool? autoStartBreaks,
    bool? autoStartNextSession,
    bool? showNotifications,
    String? soundTheme,
    bool? vibrationEnabled,
    String? theme,
  }) {
    return PomodoroSettings(
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      cyclesBeforeLongBreak: cyclesBeforeLongBreak ?? this.cyclesBeforeLongBreak,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartNextSession: autoStartNextSession ?? this.autoStartNextSession,
      showNotifications: showNotifications ?? this.showNotifications,
      soundTheme: soundTheme ?? this.soundTheme,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      theme: theme ?? this.theme,
    );
  }
} 