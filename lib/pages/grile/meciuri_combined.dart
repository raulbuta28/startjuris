import 'package:flutter/material.dart';
import 'meciuri.dart';
import 'meciuri2.dart';
import 'meciuri3.dart';

/// A simple page that combines the existing meciuri widgets
/// into a single screen. This is a best-effort implementation
/// using the placeholder values required by the widgets.
class MeciuriCombinedPage extends StatelessWidget {
  const MeciuriCombinedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Existing camera/preview page
                const Expanded(child: MeciuriPage()),
                // Bottom section from meciuri2.dart. The widget
                // requires many parameters, so dummy values are
                // provided for now.
                Expanded(
                  child: BottomSection(
                    matchActive: false,
                    selectedSubject: null,
                    onSelectSubject: (_) {},
                    onStartMatch: () {},
                    question: null,
                    secondsLeft: 0,
                    onAnswer: (_, __) {},
                    onToggleAnswer: (_, __) {},
                    player1Score: 0,
                    player2Score: 0,
                    questionIndex: 0,
                    subjectSelector: null,
                    onSelectSubjectSelector: (_) {},
                    isUser1: true,
                  ),
                ),
              ],
            ),
            // Overlay the battle line preview from meciuri3.dart
            const PreviewBattleLines(
              player1Score: 0,
              player2Score: 0,
              progress: 0,
            ),
          ],
        ),
      ),
    );
  }
}
