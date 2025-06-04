import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:convert';

class PomodoroSettings {
  int workDuration; // in minutes
  int shortBreakDuration;
  int longBreakDuration;
  int sessionsBeforeLongBreak;
  bool autoStartBreaks;
  bool autoStartPomodoros;
  
  PomodoroSettings({
    this.workDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.sessionsBeforeLongBreak = 4,
    this.autoStartBreaks = false,
    this.autoStartPomodoros = false,
  });
  
  Map<String, dynamic> toJson() => {
    'workDuration': workDuration,
    'shortBreakDuration': shortBreakDuration,
    'longBreakDuration': longBreakDuration,
    'sessionsBeforeLongBreak': sessionsBeforeLongBreak,
    'autoStartBreaks': autoStartBreaks,
    'autoStartPomodoros': autoStartPomodoros,
  };
  
  factory PomodoroSettings.fromJson(Map<String, dynamic> json) => PomodoroSettings(
    workDuration: json['workDuration'] ?? 25,
    shortBreakDuration: json['shortBreakDuration'] ?? 5,
    longBreakDuration: json['longBreakDuration'] ?? 15,
    sessionsBeforeLongBreak: json['sessionsBeforeLongBreak'] ?? 4,
    autoStartBreaks: json['autoStartBreaks'] ?? false,
    autoStartPomodoros: json['autoStartPomodoros'] ?? false,
  );
}

class WaterIntake {
  int dailyGoal; // in ml
  List<int> intakeHistory; // List of timestamps when water was consumed
  int todayIntake;
  
  WaterIntake({
    this.dailyGoal = 2000,
    List<int>? intakeHistory,
    this.todayIntake = 0,
  }) : intakeHistory = intakeHistory ?? [];
  
  Map<String, dynamic> toJson() => {
    'dailyGoal': dailyGoal,
    'intakeHistory': intakeHistory,
    'todayIntake': todayIntake,
  };
  
  factory WaterIntake.fromJson(Map<String, dynamic> json) => WaterIntake(
    dailyGoal: json['dailyGoal'] ?? 2000,
    intakeHistory: List<int>.from(json['intakeHistory'] ?? []),
    todayIntake: json['todayIntake'] ?? 0,
  );
}

class SleepData {
  DateTime? bedtime;
  DateTime? wakeTime;
  int sleepQuality; // 1-5 rating
  String? notes;
  
  SleepData({
    this.bedtime,
    this.wakeTime,
    this.sleepQuality = 3,
    this.notes,
  });
  
  Map<String, dynamic> toJson() => {
    'bedtime': bedtime?.toIso8601String(),
    'wakeTime': wakeTime?.toIso8601String(),
    'sleepQuality': sleepQuality,
    'notes': notes,
  };
  
  factory SleepData.fromJson(Map<String, dynamic> json) => SleepData(
    bedtime: json['bedtime'] != null ? DateTime.parse(json['bedtime']) : null,
    wakeTime: json['wakeTime'] != null ? DateTime.parse(json['wakeTime']) : null,
    sleepQuality: json['sleepQuality'] ?? 3,
    notes: json['notes'],
  );
}

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'mood': mood,
    'tags': tags,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Reflection.fromJson(Map<String, dynamic> json) => Reflection(
    id: json['id'] ?? DateTime.now().toIso8601String(),
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    mood: json['mood'] ?? 'Neutru',
    tags: List<String>.from(json['tags'] ?? []),
    timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
  );
}

class MeditationSession {
  String id;
  String type;
  Duration duration;
  DateTime timestamp;
  bool completed;
  
  MeditationSession({
    required this.id,
    required this.type,
    required this.duration,
    required this.timestamp,
    this.completed = false,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'duration': duration.inSeconds,
    'timestamp': timestamp.toIso8601String(),
    'completed': completed,
  };
  
  factory MeditationSession.fromJson(Map<String, dynamic> json) => MeditationSession(
    id: json['id'],
    type: json['type'],
    duration: Duration(seconds: json['duration']),
    timestamp: DateTime.parse(json['timestamp']),
    completed: json['completed'] ?? false,
  );
}

class WorkoutSession {
  String id;
  String type;
  Duration duration;
  DateTime timestamp;
  int intensity; // 1-5 rating
  String? notes;
  
  WorkoutSession({
    required this.id,
    required this.type,
    required this.duration,
    required this.timestamp,
    this.intensity = 3,
    this.notes,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'duration': duration.inSeconds,
    'timestamp': timestamp.toIso8601String(),
    'intensity': intensity,
    'notes': notes,
  };
  
  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
    id: json['id'],
    type: json['type'],
    duration: Duration(seconds: json['duration']),
    timestamp: DateTime.parse(json['timestamp']),
    intensity: json['intensity'] ?? 3,
    notes: json['notes'],
  );
}

class UtilsProvider extends ChangeNotifier {
  // Audio player for meditation and ambient sounds
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Pomodoro state
  PomodoroSettings _pomodoroSettings = PomodoroSettings();
  bool _isTimerRunning = false;
  Duration _remainingTime = const Duration(minutes: 25);
  int _completedSessions = 0;
  bool _isBreak = false;
  
  // Water tracking state
  WaterIntake _waterIntake = WaterIntake();
  
  // Sleep tracking state
  Map<DateTime, SleepData> _sleepHistory = {};
  
  // Reflections state
  List<Reflection> _reflections = [];
  
  // Meditation state
  List<MeditationSession> _meditationHistory = [];
  String? _currentMeditationId;
  
  // Workout state
  List<WorkoutSession> _workoutHistory = [];
  
  // Getters
  PomodoroSettings get pomodoroSettings => _pomodoroSettings;
  bool get isTimerRunning => _isTimerRunning;
  Duration get remainingTime => _remainingTime;
  int get completedSessions => _completedSessions;
  bool get isBreak => _isBreak;
  WaterIntake get waterIntake => _waterIntake;
  Map<DateTime, SleepData> get sleepHistory => _sleepHistory;
  List<Reflection> get reflections => _reflections;
  List<MeditationSession> get meditationHistory => _meditationHistory;
  String? get currentMeditationId => _currentMeditationId;
  List<WorkoutSession> get workoutHistory => _workoutHistory;
  
  UtilsProvider() {
    _loadData();
  }
  
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Pomodoro settings
    final pomodoroJson = prefs.getString('pomodoroSettings');
    if (pomodoroJson != null) {
      _pomodoroSettings = PomodoroSettings.fromJson(jsonDecode(pomodoroJson));
    }
    
    // Load water intake data
    final waterJson = prefs.getString('waterIntake');
    if (waterJson != null) {
      _waterIntake = WaterIntake.fromJson(jsonDecode(waterJson));
    }
    
    // Load sleep history
    final sleepJson = prefs.getString('sleepHistory');
    if (sleepJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(sleepJson);
      _sleepHistory = decoded.map((key, value) => MapEntry(
        DateTime.parse(key),
        SleepData.fromJson(value),
      ));
    }
    
    // Load reflections
    final reflectionsJson = prefs.getString('reflections');
    if (reflectionsJson != null) {
      final List<dynamic> decoded = jsonDecode(reflectionsJson);
      _reflections = decoded.map((e) => Reflection.fromJson(e)).toList();
    }
    
    // Load meditation history
    final meditationJson = prefs.getString('meditationHistory');
    if (meditationJson != null) {
      final List<dynamic> decoded = jsonDecode(meditationJson);
      _meditationHistory = decoded.map((e) => MeditationSession.fromJson(e)).toList();
    }
    
    // Load workout history
    final workoutJson = prefs.getString('workoutHistory');
    if (workoutJson != null) {
      final List<dynamic> decoded = jsonDecode(workoutJson);
      _workoutHistory = decoded.map((e) => WorkoutSession.fromJson(e)).toList();
    }
    
    notifyListeners();
  }
  
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('pomodoroSettings', jsonEncode(_pomodoroSettings.toJson()));
    await prefs.setString('waterIntake', jsonEncode(_waterIntake.toJson()));
    
    final sleepMap = _sleepHistory.map((key, value) => MapEntry(
      key.toIso8601String(),
      value.toJson(),
    ));
    await prefs.setString('sleepHistory', jsonEncode(sleepMap));
    
    await prefs.setString('reflections', jsonEncode(_reflections.map((e) => e.toJson()).toList()));
    await prefs.setString('meditationHistory', jsonEncode(_meditationHistory.map((e) => e.toJson()).toList()));
    await prefs.setString('workoutHistory', jsonEncode(_workoutHistory.map((e) => e.toJson()).toList()));
  }
  
  // Pomodoro methods
  void startTimer() {
    _isTimerRunning = true;
    notifyListeners();
  }
  
  void pauseTimer() {
    _isTimerRunning = false;
    notifyListeners();
  }
  
  void resetTimer() {
    _isTimerRunning = false;
    _remainingTime = Duration(minutes: _pomodoroSettings.workDuration);
    notifyListeners();
  }
  
  void updatePomodoroSettings(PomodoroSettings settings) {
    _pomodoroSettings = settings;
    resetTimer();
    _saveData();
  }
  
  void tickTimer() {
    if (_remainingTime > Duration.zero) {
      _remainingTime -= const Duration(seconds: 1);
      notifyListeners();
    }
  }
  
  void onPomodoroComplete() {
    _completedSessions++;
    _isBreak = true;
    
    if (_completedSessions % _pomodoroSettings.sessionsBeforeLongBreak == 0) {
      _remainingTime = Duration(minutes: _pomodoroSettings.longBreakDuration);
    } else {
      _remainingTime = Duration(minutes: _pomodoroSettings.shortBreakDuration);
    }
    
    if (_pomodoroSettings.autoStartBreaks) {
      startTimer();
    } else {
      _isTimerRunning = false;
    }
    
    notifyListeners();
  }
  
  void onBreakComplete() {
    _isBreak = false;
    _remainingTime = Duration(minutes: _pomodoroSettings.workDuration);
    
    if (_pomodoroSettings.autoStartPomodoros) {
      startTimer();
    } else {
      _isTimerRunning = false;
    }
    
    notifyListeners();
  }
  
  // Water tracking methods
  void addWaterIntake(int amount) {
    _waterIntake.todayIntake += amount;
    _waterIntake.intakeHistory.add(DateTime.now().millisecondsSinceEpoch);
    _saveData();
    notifyListeners();
  }
  
  void setWaterGoal(int goal) {
    _waterIntake.dailyGoal = goal;
    _saveData();
    notifyListeners();
  }
  
  void resetDailyWaterIntake() {
    _waterIntake.todayIntake = 0;
    _saveData();
    notifyListeners();
  }
  
  // Sleep tracking methods
  void logSleep(DateTime date, SleepData data) {
    _sleepHistory[date] = data;
    _saveData();
    notifyListeners();
  }
  
  void updateSleepQuality(DateTime date, int quality) {
    if (_sleepHistory.containsKey(date)) {
      _sleepHistory[date]!.sleepQuality = quality;
      _saveData();
      notifyListeners();
    }
  }
  
  // Reflection methods
  void addReflection(Reflection reflection) {
    _reflections.add(reflection);
    _saveData();
    notifyListeners();
  }
  
  void updateReflection(Reflection oldReflection, Reflection newReflection) {
    final index = _reflections.indexWhere((r) => r.id == oldReflection.id);
    if (index != -1) {
      _reflections[index] = newReflection;
      _saveData();
      notifyListeners();
    }
  }
  
  void deleteReflection(String id) {
    _reflections.removeWhere((r) => r.id == id);
    _saveData();
    notifyListeners();
  }
  
  // Meditation methods
  Future<void> startMeditation(String type, Duration duration) async {
    final session = MeditationSession(
      id: DateTime.now().toIso8601String(),
      type: type,
      duration: duration,
      timestamp: DateTime.now(),
    );
    _meditationHistory.add(session);
    _currentMeditationId = session.id;
    notifyListeners();
  }
  
  Future<void> completeMeditation(String id) async {
    final session = _meditationHistory.firstWhere((s) => s.id == id);
    session.completed = true;
    _currentMeditationId = null;
    _saveData();
    notifyListeners();
  }
  
  Future<void> playAmbientSound(String assetPath) async {
    await _audioPlayer.setAsset(assetPath);
    await _audioPlayer.play();
  }
  
  Future<void> stopAmbientSound() async {
    await _audioPlayer.stop();
  }
  
  // Workout methods
  void logWorkout(String type, Duration duration, {int intensity = 3, String? notes}) {
    final workout = WorkoutSession(
      id: DateTime.now().toIso8601String(),
      type: type,
      duration: duration,
      timestamp: DateTime.now(),
      intensity: intensity,
      notes: notes,
    );
    _workoutHistory.add(workout);
    _saveData();
    notifyListeners();
  }
  
  void deleteWorkout(String id) {
    _workoutHistory.removeWhere((w) => w.id == id);
    _saveData();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
} 