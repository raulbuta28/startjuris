import 'package:flutter/material.dart';
import '../models.dart';

enum TestStatus {
  notStarted,
  inProgress,
  paused,
  completed
}

class TestState extends ChangeNotifier {
  final String testId;
  final String title;
  final List<Question> questions;
  final DateTime startTime;
  
  TestStatus _status = TestStatus.notStarted;
  TestStatus get status => _status;

  int _currentQuestionIndex = 0;
  int get currentQuestionIndex => _currentQuestionIndex;
  
  Duration _timeSpent = Duration.zero;
  Duration get timeSpent => _timeSpent;
  
  Map<int, Set<String>> _selectedAnswers = {};
  Map<int, Set<String>> get selectedAnswers => _selectedAnswers;
  
  bool _showExplanations = false;
  bool get showExplanations => _showExplanations;

  // Statistics
  int get totalQuestions => questions.length;
  int get answeredQuestions => _selectedAnswers.length;
  double get progress => answeredQuestions / totalQuestions;
  
  int get correctAnswers {
    int correct = 0;
    _selectedAnswers.forEach((questionId, selected) {
      final question = questions.firstWhere((q) => q.id == questionId);
      if (selected.length == question.correctAnswers.length &&
          selected.every((answer) => question.correctAnswers.contains(answer))) {
        correct++;
      }
    });
    return correct;
  }
  
  double get score => correctAnswers / totalQuestions * 100;

  TestState({
    required this.testId,
    required this.title,
    required this.questions,
  }) : startTime = DateTime.now();

  void startTest() {
    _status = TestStatus.inProgress;
    notifyListeners();
  }

  void pauseTest() {
    _status = TestStatus.paused;
    notifyListeners();
  }

  void resumeTest() {
    _status = TestStatus.inProgress;
    notifyListeners();
  }

  void completeTest() {
    _status = TestStatus.completed;
    notifyListeners();
  }

  void toggleAnswer(String answer) {
    final currentQuestion = questions[_currentQuestionIndex];
    _selectedAnswers[currentQuestion.id] ??= {};
    
    if (_selectedAnswers[currentQuestion.id]!.contains(answer)) {
      _selectedAnswers[currentQuestion.id]!.remove(answer);
      if (_selectedAnswers[currentQuestion.id]!.isEmpty) {
        _selectedAnswers.remove(currentQuestion.id);
      }
    } else {
      _selectedAnswers[currentQuestion.id]!.add(answer);
    }
    
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  void jumpToQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  void toggleExplanations() {
    _showExplanations = !_showExplanations;
    notifyListeners();
  }

  void updateTimeSpent(Duration newDuration) {
    _timeSpent = newDuration;
    notifyListeners();
  }

  // Helper methods for checking answer status
  bool isAnswerSelected(String answer) {
    final currentQuestion = questions[_currentQuestionIndex];
    return _selectedAnswers[currentQuestion.id]?.contains(answer) ?? false;
  }

  bool isQuestionAnswered(int questionIndex) {
    final question = questions[questionIndex];
    return _selectedAnswers.containsKey(question.id);
  }

  bool isAnswerCorrect(int questionIndex, String answer) {
    final question = questions[questionIndex];
    return question.correctAnswers.contains(answer);
  }

  Set<String> getSelectedAnswersForQuestion(int questionIndex) {
    final question = questions[questionIndex];
    return _selectedAnswers[question.id] ?? {};
  }
} 