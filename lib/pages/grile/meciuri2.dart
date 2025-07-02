import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomSection extends StatefulWidget {
  final bool matchActive;
  final String? selectedSubject;
  final List<String> chapters;
  final String? selectedChapter;
  final Function(String?) onSelectChapter;
  final Function(String) onSelectSubject;
  final VoidCallback onStartMatch;
  final int questionCount;
  final Function(int) onSelectQuestionCount;
  final bool loading;
  final Map<String, dynamic>? question;
  final int secondsLeft;
  final Function(int, List<String>) onAnswer;
  final Function(int, String) onToggleAnswer;
  final int player1Score;
  final int player2Score;
  final int questionIndex;
  final int totalQuestions;
  final bool isUser1;
  final String player1Name;
  final String player2Name;
  final String? player1CurrentAnswer;
  final String? player2CurrentAnswer;

  const BottomSection({
    super.key,
    required this.matchActive,
    required this.selectedSubject,
    required this.chapters,
    required this.selectedChapter,
    required this.onSelectChapter,
    required this.onSelectSubject,
    required this.onStartMatch,
    required this.questionCount,
    required this.onSelectQuestionCount,
    required this.loading,
    required this.question,
    required this.secondsLeft,
    required this.onAnswer,
    required this.onToggleAnswer,
    required this.player1Score,
    required this.player2Score,
    required this.questionIndex,
    required this.totalQuestions,
    required this.isUser1,
    required this.player1Name,
    required this.player2Name,
    this.player1CurrentAnswer,
    this.player2CurrentAnswer,
  });

  @override
  _BottomSectionState createState() => _BottomSectionState();
}

class _BottomSectionState extends State<BottomSection> {
  List<String> _selectedAnswers = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black54, Colors.black],
        ),
      ),
      child: Column(
        children: [
          if (!widget.matchActive)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Selectează materia pentru meci:',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildSubjectButton('Drept civil'),
                      _buildSubjectButton('Drept penal'),
                      _buildSubjectButton('Drept procesual civil'),
                      _buildSubjectButton('Drept procesual penal'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (widget.selectedSubject != null) ...[
                    _buildChapterSelector(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCountButton(5),
                        const SizedBox(width: 8),
                        _buildCountButton(10),
                        const SizedBox(width: 8),
                        _buildCountButton(15),
                      ],
                    ),
                    const SizedBox(height: 30),
                    widget.loading
                        ? const CircularProgressIndicator()
                        : GestureDetector(
                            onTap: widget.onStartMatch,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xffff4081), Color(0xfff50057)],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pinkAccent.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.play_arrow, size: 28, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Începe meciul',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ],
                ],
              ),
            ),
          if (widget.matchActive && widget.question != null)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Întrebarea ${widget.questionIndex + 1}/${widget.totalQuestions}',
                        style: GoogleFonts.montserrat(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Timp rămas: ${widget.secondsLeft}s',
                        style: GoogleFonts.montserrat(
                          color: widget.secondsLeft <= 5 ? Colors.red : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Question text
                  Text(
                    widget.question!['question'],
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Answer options
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.question!['options'].length,
                      itemBuilder: (context, index) {
                        final option = widget.question!['options'][index];
                        final prefix = String.fromCharCode(65 + index) + ".";
                        final isSelected = widget.isUser1
                            ? widget.player1CurrentAnswer == option
                            : widget.player2CurrentAnswer == option;
                        final color = widget.isUser1 ? Colors.red : Colors.blue;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: GestureDetector(
                            onTap: () => widget.onToggleAnswer(
                                widget.isUser1 ? 1 : 2, option),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? color : Colors.black87,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: color.withOpacity(0.5),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                '$prefix $option',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Player status indicators
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPlayerStatus(widget.player1Name, widget.player1CurrentAnswer, Colors.red),
                        _buildPlayerStatus(widget.player2Name, widget.player2CurrentAnswer, Colors.blue),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubjectButton(String subject) {
    final isSelected = widget.selectedSubject == subject;
    return GestureDetector(
      onTap: () => widget.onSelectSubject(subject),
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pinkAccent : Colors.black87,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.pinkAccent : Colors.white24,
            width: 2,
          ),
        ),
        child: Text(
          subject,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildChapterSelector() {
    final label = widget.selectedChapter ?? 'Toată materia';
    final isSelected = widget.selectedChapter != null;
    return GestureDetector(
      onTap: _showChapterSelectionModal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pinkAccent : Colors.black87,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.pinkAccent : Colors.white24,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _showChapterSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollCtrl) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(16),
              child: ListView(
                controller: scrollCtrl,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  Text(
                    'Selectează tema',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildChapterButton('Toată materia', onTap: () => Navigator.pop(context)),
                  const SizedBox(height: 8),
                  ...widget.chapters.map(
                    (c) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _buildChapterButton(c, onTap: () => Navigator.pop(context)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChapterButton(String chapter, {VoidCallback? onTap}) {
    final isSelected = widget.selectedChapter == chapter;
    return GestureDetector(
      onTap: () {
        widget.onSelectChapter(chapter == 'Toată materia' ? null : chapter);
        if (onTap != null) onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pinkAccent : Colors.black87,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.pinkAccent : Colors.white24,
            width: 2,
          ),
        ),
        child: Text(
          chapter,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCountButton(int count) {
    final isSelected = widget.questionCount == count;
    return GestureDetector(
      onTap: () => widget.onSelectQuestionCount(count),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pinkAccent : Colors.black87,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.pinkAccent : Colors.white24,
            width: 2,
          ),
        ),
        child: Text(
          '$count',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerStatus(String player, String? answer, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        children: [
          Text(
            player,
            style: GoogleFonts.montserrat(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            answer != null ? Icons.check_circle : Icons.pending,
            color: answer != null ? Colors.green : Colors.orange,
            size: 16,
          ),
        ],
      ),
    );
  }
}
