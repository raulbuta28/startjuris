import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models.dart';
import '../models/test_state.dart';
import '../widgets/test_progress.dart';
import '../widgets/question_card.dart';
import '../widgets/question_navigator.dart';

class TestPage extends StatefulWidget {
  final String testTitle;
  final List<Question> questions;

  const TestPage({
    super.key,
    required this.testTitle,
    required this.questions,
  });

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late final TestState _testState;
  Timer? _timer;
  final _pageController = PageController();
  
  @override
  void initState() {
    super.initState();
    _testState = TestState(
      testId: DateTime.now().toString(),
      title: widget.testTitle,
      questions: widget.questions,
    );
    _startTimer();
    _testState.startTest();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_testState.status == TestStatus.inProgress && mounted) {
        setState(() {
          _testState.updateTimeSpent(
            Duration(seconds: timer.tick),
          );
        });
      }
    });
  }

  void _onPause() {
    HapticFeedback.mediumImpact();
    setState(() {
      _testState.pauseTest();
    });
    _showPauseDialog();
  }

  void _onResume() {
    HapticFeedback.mediumImpact();
    setState(() {
      _testState.resumeTest();
    });
  }

  void _onComplete() {
    HapticFeedback.mediumImpact();
    _showCompleteDialog();
  }

  void _showPauseDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Test în pauză',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistici curente:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatRow('Întrebări răspunse:', '${_testState.answeredQuestions}/${_testState.totalQuestions}', isDark),
              _buildStatRow('Răspunsuri corecte:', '${_testState.correctAnswers}', isDark),
              _buildStatRow('Scor curent:', '${_testState.score.toStringAsFixed(1)}%', isDark),
              _buildStatRow('Timp petrecut:', _formatDuration(_testState.timeSpent), isDark),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _onResume();
              },
              child: Text(
                'Continuă testul',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCompleteDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Finalizare test',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ești sigur că vrei să finalizezi testul?',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Mai ai ${_testState.totalQuestions - _testState.answeredQuestions} întrebări la care nu ai răspuns.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.black45,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Continuă testul',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _testState.completeTest();
                  _testState.toggleExplanations();
                });
              },
              child: Text(
                'Finalizează',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? Colors.white60 : Colors.black45,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        if (_testState.status == TestStatus.inProgress) {
          _onPause();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [
            // Progress and stats
            TestProgress(
              testState: _testState,
              onPause: _onPause,
              onResume: _onResume,
              onComplete: _onComplete,
            ),
            // Questions
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _testState.jumpToQuestion(index);
                  });
                },
                itemCount: _testState.totalQuestions,
                itemBuilder: (context, index) {
                  final question = _testState.questions[index];
                  return QuestionCard(
                    question: question,
                    isDark: isDark,
                    showExplanation: _testState.showExplanations,
                    selectedAnswers: _testState.getSelectedAnswersForQuestion(index),
                    onAnswerToggle: (answer) {
                      setState(() {
                        _testState.toggleAnswer(answer);
                      });
                    },
                  );
                },
              ),
            ),
            // Question navigator
            QuestionNavigator(
              testState: _testState,
              onQuestionSelected: (index) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 