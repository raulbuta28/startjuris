import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReadingSession {
  final DateTime startTime;
  final Duration duration;
  final String bookId;

  ReadingSession({
    required this.startTime,
    required this.duration,
    required this.bookId,
  });

  Map<String, dynamic> toJson() => {
    'startTime': startTime.toIso8601String(),
    'duration': duration.inSeconds,
    'bookId': bookId,
  };

  factory ReadingSession.fromJson(Map<String, dynamic> json) => ReadingSession(
    startTime: DateTime.parse(json['startTime']),
    duration: Duration(seconds: json['duration']),
    bookId: json['bookId'],
  );
}

class ObiectiveProvider extends ChangeNotifier {
  int _dailyGoalMinutes = 30;
  int _currentStreak = 0;
  DateTime? _lastReadDate;
  Map<String, List<ReadingSession>> _readingSessions = {};
  Map<DateTime, Duration> _dailyReadingTime = {};
  bool _isCurrentlyReading = false;
  String? _currentBookId;
  DateTime? _currentSessionStart;
  Duration _todayReadingTime = Duration.zero;
  List<bool> _weekProgress = List.filled(7, false);
  Map<DateTime, Duration> _readingHistory = {};
  bool _isInitialized = false;

  // Getters
  int get dailyGoalMinutes => _dailyGoalMinutes;
  int get currentStreak => _currentStreak;
  bool get isCurrentlyReading => _isCurrentlyReading;
  String? get currentBookId => _currentBookId;
  bool get isInitialized => _isInitialized;

  ObiectiveProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _dailyGoalMinutes = prefs.getInt('dailyGoalMinutes') ?? 30;
      _currentStreak = prefs.getInt('currentStreak') ?? 0;
      
      final lastReadStr = prefs.getString('lastReadDate');
      if (lastReadStr != null) {
        _lastReadDate = DateTime.parse(lastReadStr);
      }

      final sessionsStr = prefs.getString('readingSessions');
      if (sessionsStr != null) {
        final Map<String, dynamic> decoded = jsonDecode(sessionsStr);
        _readingSessions = decoded.map((key, value) => MapEntry(
          key,
          (value as List).map((s) => ReadingSession.fromJson(s)).toList(),
        ));
      }

      // Initialize reading history with empty data for the last 7 days
      final now = DateTime.now();
      for (int i = 0; i < 7; i++) {
        final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        if (!_readingHistory.containsKey(date)) {
          _readingHistory[date] = Duration.zero;
        }
      }
      
      _updateWeekProgress(); // Update week progress after initializing history
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing ObiectiveProvider: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyGoalMinutes', _dailyGoalMinutes);
    await prefs.setInt('currentStreak', _currentStreak);
    
    if (_lastReadDate != null) {
      await prefs.setString('lastReadDate', _lastReadDate!.toIso8601String());
    }

    final sessionsEncoded = jsonEncode(_readingSessions.map(
      (key, value) => MapEntry(key, value.map((s) => s.toJson()).toList()),
    ));
    await prefs.setString('readingSessions', sessionsEncoded);
  }

  void setDailyGoal(int minutes) {
    _dailyGoalMinutes = minutes;
    _saveData();
    notifyListeners();
  }

  void startReading(String bookId) {
    if (!_isCurrentlyReading) {
      _isCurrentlyReading = true;
      _currentBookId = bookId;
      _currentSessionStart = DateTime.now();
      notifyListeners();
    }
  }

  void stopReading() {
    if (_isCurrentlyReading && _currentBookId != null && _currentSessionStart != null) {
      final session = ReadingSession(
        startTime: _currentSessionStart!,
        duration: DateTime.now().difference(_currentSessionStart!),
        bookId: _currentBookId!,
      );

      _readingSessions.putIfAbsent(_currentBookId!, () => []).add(session);
      
      // Update daily reading time
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      _dailyReadingTime[today] = (_dailyReadingTime[today] ?? Duration.zero) + session.duration;

      _updateStreak();
      _isCurrentlyReading = false;
      _currentBookId = null;
      _currentSessionStart = null;
      _saveData();
      notifyListeners();
    }
  }

  void _updateStreak() {
    final today = DateTime.now();
    if (_lastReadDate == null) {
      _currentStreak = 1;
    } else {
      final difference = today.difference(_lastReadDate!).inDays;
      if (difference <= 1) {
        _currentStreak++;
      } else {
        _currentStreak = 1;
      }
    }
    _lastReadDate = today;
  }

  Duration getTodayReadingTime() {
    return _todayReadingTime;
  }

  void addReadingTime(Duration time) {
    _todayReadingTime += time;
    final today = DateTime.now();
    _readingHistory[today] = (_readingHistory[today] ?? Duration.zero) + time;
    _updateWeekProgress();
    notifyListeners();
  }

  List<bool> getWeekProgress() {
    return _weekProgress;
  }

  void _updateWeekProgress() {
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final time = _readingHistory[date] ?? Duration.zero;
      _weekProgress[i] = time.inMinutes >= _dailyGoalMinutes;
    }
    notifyListeners();
  }

  Map<DateTime, Duration> getReadingTimeHistory() {
    return _readingHistory;
  }

  bool hasReachedDailyGoal() {
    return _todayReadingTime.inMinutes >= _dailyGoalMinutes;
  }
} 