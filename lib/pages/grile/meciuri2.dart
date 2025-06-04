import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomSection extends StatefulWidget {
  final bool matchActive;
  final String? selectedSubject;
  final Function(String) onSelectSubject;
  final VoidCallback onStartMatch;
  final Map<String, dynamic>? question;
  final int secondsLeft;
  final Function(int, List<String>) onAnswer;
  final Function(int, String) onToggleAnswer;
  final int player1Score;
  final int player2Score;
  final int questionIndex;
  final String? subjectSelector;
  final Function(String) onSelectSubjectSelector;
  final bool isUser1;

  const BottomSection({
    super.key,
    required this.matchActive,
    required this.selectedSubject,
    required this.onSelectSubject,
    required this.onStartMatch,
    required this.question,
    required this.secondsLeft,
    required this.onAnswer,
    required this.onToggleAnswer,
    required this.player1Score,
    required this.player2Score,
    required this.questionIndex,
    required this.subjectSelector,
    required this.onSelectSubjectSelector,
    required this.isUser1,
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
          if (!widget.matchActive && widget.subjectSelector == null)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Cine stabilește materia?',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => widget.onSelectSubjectSelector('User 1'),
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.pinkAccent.withOpacity(0.5)),
                      ),
                      child: Text(
                        'User 1',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => widget.onSelectSubjectSelector('User 2'),
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withOpacity(0.5)),
                      ),
                      child: Text(
                        'User 2',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (!widget.matchActive && widget.subjectSelector != null && widget.subjectSelector == (widget.isUser1 ? 'User 1' : 'User 2'))
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => widget.onSelectSubject('Drept civil'),
                            child: Container(
                              width: 180,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: widget.selectedSubject == 'Drept civil'
                                    ? Colors.pinkAccent
                                    : Colors.black87,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                'Drept civil',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => widget.onSelectSubject('Drept procesual civil'),
                            child: Container(
                              width: 180,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: widget.selectedSubject == 'Drept procesual civil'
                                    ? Colors.pinkAccent
                                    : Colors.black87,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                'Drept procesual civil',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => widget.onSelectSubject('Drept penal'),
                            child: Container(
                              width: 180,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: widget.selectedSubject == 'Drept penal'
                                    ? Colors.pinkAccent
                                    : Colors.black87,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                'Drept penal',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => widget.onSelectSubject('Drept procesual penal'),
                            child: Container(
                              width: 180,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: widget.selectedSubject == 'Drept procesual penal'
                                    ? Colors.pinkAccent
                                    : Colors.black87,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                'Drept procesual penal',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: widget.onStartMatch,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xffff4081), Color(0xfff50057)],
                        ),
                        borderRadius: BorderRadius.circular(16),
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
              ),
            ),
          if (!widget.matchActive && widget.subjectSelector != null && widget.subjectSelector != (widget.isUser1 ? 'User 1' : 'User 2'))
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: widget.onStartMatch,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xffff4081), Color(0xfff50057)],
                      ),
                      borderRadius: BorderRadius.circular(16),
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
              ),
            ),
          if (widget.matchActive && widget.question != null)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
                children: [
                  Text(
                    'Întrebarea ${widget.questionIndex + 1}/5',
                    style: GoogleFonts.montserrat(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.question!['question'],
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.castFrom(widget.question!['options']).asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSelected = _selectedAnswers.contains(option);
                    final prefix = String.fromCharCode(65 + index) + "."; // A., B., C.
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      child: GestureDetector(
                        onTap: () => widget.onToggleAnswer(widget.isUser1 ? 1 : 2, option),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? (widget.isUser1 ? Colors.pinkAccent : Colors.amber) : Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.isUser1 ? Colors.pinkAccent.withOpacity(0.5) : Colors.amber.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            '$prefix $option',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}