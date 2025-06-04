import 'dart:convert';
import 'package:shared_preferences.dart';
import '../models/test_state.dart';
import '../models.dart';

class TestService {
  static const String _keyPrefix = 'test_progress_';
  
  // Save test progress
  Future<void> saveTestProgress(TestState state) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'testId': state.testId,
      'title': state.title,
      'startTime': state.startTime.toIso8601String(),
      'status': state.status.toString(),
      'currentQuestionIndex': state.currentQuestionIndex,
      'timeSpent': state.timeSpent.inSeconds,
      'selectedAnswers': state.selectedAnswers.map(
        (key, value) => MapEntry(key.toString(), value.toList()),
      ),
      'showExplanations': state.showExplanations,
    };
    
    await prefs.setString('${_keyPrefix}${state.testId}', jsonEncode(data));
  }
  
  // Load test progress
  Future<TestState?> loadTestProgress(String testId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('${_keyPrefix}$testId');
    if (json == null) return null;
    
    final data = jsonDecode(json) as Map<String, dynamic>;
    // Note: We need the questions to reconstruct the state
    // This would typically come from your question repository
    return null; // Implement full loading when question persistence is added
  }
  
  // Save test result
  Future<void> saveTestResult(TestState state) async {
    final prefs = await SharedPreferences.getInstance();
    final result = {
      'testId': state.testId,
      'title': state.title,
      'startTime': state.startTime.toIso8601String(),
      'endTime': DateTime.now().toIso8601String(),
      'timeSpent': state.timeSpent.inSeconds,
      'totalQuestions': state.totalQuestions,
      'answeredQuestions': state.answeredQuestions,
      'correctAnswers': state.correctAnswers,
      'score': state.score,
      'selectedAnswers': state.selectedAnswers.map(
        (key, value) => MapEntry(key.toString(), value.toList()),
      ),
    };
    
    // Save to test history
    final historyJson = prefs.getString('test_history') ?? '[]';
    final history = List<Map<String, dynamic>>.from(
      jsonDecode(historyJson) as List,
    );
    history.insert(0, result);
    await prefs.setString('test_history', jsonEncode(history));
    
    // Clean up progress
    await prefs.remove('${_keyPrefix}${state.testId}');
  }
  
  // Get test history
  Future<List<Map<String, dynamic>>> getTestHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('test_history') ?? '[]';
    return List<Map<String, dynamic>>.from(
      jsonDecode(json) as List,
    );
  }
  
  // Clear test history
  Future<void> clearTestHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('test_history');
  }
  
  // Clear all test progress
  Future<void> clearAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_keyPrefix)) {
        await prefs.remove(key);
      }
    }
  }
} 