import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models.dart';
import '../models/test_state.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final bool isDark;
  final bool showExplanation;
  final Set<String> selectedAnswers;
  final Function(String) onAnswerToggle;

  const QuestionCard({
    super.key,
    required this.question,
    required this.isDark,
    required this.showExplanation,
    required this.selectedAnswers,
    required this.onAnswerToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question text
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Colors.purple.shade900, Colors.blue.shade900]
                    : [Colors.purple.shade100, Colors.blue.shade100],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              question.text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          // Answers
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: question.answers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final answer = question.answers[index];
              final isSelected = selectedAnswers.contains(answer.letter);
              final isCorrect = showExplanation && question.correctAnswers.contains(answer.letter);
              final isWrong = showExplanation && isSelected && !isCorrect;

              return _AnswerTile(
                answer: answer,
                isSelected: isSelected,
                isCorrect: isCorrect,
                isWrong: isWrong,
                showResult: showExplanation,
                isDark: isDark,
                onTap: () => onAnswerToggle(answer.letter),
              );
            },
          ),
          // Explanation
          if (showExplanation && question.explanation.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explicație:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.explanation,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  final Answer answer;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool showResult;
  final bool isDark;
  final VoidCallback onTap;

  const _AnswerTile({
    required this.answer,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.showResult,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color getBackgroundColor() {
      if (!showResult) {
        return isSelected
            ? (isDark ? Colors.purple.shade900 : Colors.purple.shade100)
            : (isDark ? Colors.grey[850]! : Colors.grey[100]!);
      }
      if (isCorrect) {
        return isDark ? Colors.green.shade900 : Colors.green.shade100;
      }
      if (isWrong) {
        return isDark ? Colors.red.shade900 : Colors.red.shade100;
      }
      return isDark ? Colors.grey[850]! : Colors.grey[100]!;
    }

    Color getBorderColor() {
      if (!showResult) {
        return isSelected
            ? (isDark ? Colors.purple.shade400 : Colors.purple.shade400)
            : Colors.transparent;
      }
      if (isCorrect) {
        return isDark ? Colors.green.shade400 : Colors.green.shade400;
      }
      if (isWrong) {
        return isDark ? Colors.red.shade400 : Colors.red.shade400;
      }
      return Colors.transparent;
    }

    return GestureDetector(
      onTap: showResult ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: getBorderColor(),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.black26 : Colors.white,
                border: Border.all(
                  color: getBorderColor(),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  answer.letter,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                answer.text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
            if (showResult)
              Icon(
                isCorrect
                    ? Icons.check_circle_outline
                    : (isWrong ? Icons.cancel_outlined : null),
                color: isCorrect
                    ? Colors.green
                    : (isWrong ? Colors.red : Colors.transparent),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
} 