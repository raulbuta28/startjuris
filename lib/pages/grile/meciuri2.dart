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
  final String? player1CurrentAnswer;
  final String? player2CurrentAnswer;

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
                        'Player 1',
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
                        'Player 2',
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
                  const SizedBox(height: 30),
                  if (widget.selectedSubject != null)
                    GestureDetector(
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
              ),
            ),
          if (!widget.matchActive && widget.subjectSelector != null && widget.subjectSelector != (widget.isUser1 ? 'User 1' : 'User 2'))
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.subjectSelector} alege materia...',
                    style: GoogleFonts.montserrat(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  if (widget.selectedSubject != null) ...[
                    Text(
                      'Materia selectată: ${widget.selectedSubject}',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
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
                        'Întrebarea ${widget.questionIndex + 1}/5',
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
                        final isPlayer1Selected = widget.player1CurrentAnswer == option;
                        final isPlayer2Selected = widget.player2CurrentAnswer == option;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              // Player 1 answer button
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => widget.onToggleAnswer(1, option),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isPlayer1Selected ? Colors.red : Colors.black87,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.red.withOpacity(0.5),
                                        width: isPlayer1Selected ? 2 : 1,
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
                              ),
                              const SizedBox(width: 8),
                              // Player 2 answer button
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => widget.onToggleAnswer(2, option),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isPlayer2Selected ? Colors.blue : Colors.black87,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.blue.withOpacity(0.5),
                                        width: isPlayer2Selected ? 2 : 1,
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
                              ),
                            ],
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
                        _buildPlayerStatus('Player 1', widget.player1CurrentAnswer, Colors.red),
                        _buildPlayerStatus('Player 2', widget.player2CurrentAnswer, Colors.blue),
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
