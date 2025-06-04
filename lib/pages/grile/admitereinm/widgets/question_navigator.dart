import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/test_state.dart';

class QuestionNavigator extends StatelessWidget {
  final TestState testState;
  final Function(int) onQuestionSelected;

  const QuestionNavigator({
    super.key,
    required this.testState,
    required this.onQuestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: testState.totalQuestions,
        itemBuilder: (context, index) {
          final isSelected = index == testState.currentQuestionIndex;
          final isAnswered = testState.isQuestionAnswered(index);
          final selectedAnswers = testState.getSelectedAnswersForQuestion(index);
          final hasCorrectAnswer = selectedAnswers.any(
            (answer) => testState.isAnswerCorrect(index, answer),
          );

          return GestureDetector(
            onTap: () => onQuestionSelected(index),
            child: Container(
              width: 44,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [Colors.purple.shade400, Colors.blue.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: !isSelected
                    ? (isAnswered
                        ? (hasCorrectAnswer
                            ? (isDark ? Colors.green.shade900 : Colors.green.shade100)
                            : (isDark ? Colors.red.shade900 : Colors.red.shade100))
                        : (isDark ? Colors.grey[850] : Colors.grey[100]))
                    : null,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isAnswered
                          ? (hasCorrectAnswer
                              ? Colors.green.shade400
                              : Colors.red.shade400)
                          : Colors.transparent),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 