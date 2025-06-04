import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models.dart';

// Random number generator
final Random _random = Random();

// Question bank organized by subject
const Map<String, List<Question>> _questionBank = {
  'Drept Civil': [
    Question(
      id: 1,
      text: 'Care este definiția proprietății private?',
      answers: [
        Answer(letter: 'A', text: 'Dreptul de a dispune și folosi un bun'),
        Answer(letter: 'B', text: 'Dreptul statului asupra bunurilor'),
        Answer(letter: 'C', text: 'Dreptul comunității de a gestiona un bun'),
      ],
      correctAnswers: ['A'],
      explanation:
          'Proprietatea privată reprezintă dreptul subiectiv al titularului de a deține, folosi și dispune de bun în mod exclusiv.',
    ),
    Question(
      id: 2,
      text: 'Ce este consimțământul în actul juridic civil?',
      answers: [
        Answer(letter: 'A', text: 'Acordul liber al părților'),
        Answer(letter: 'B', text: 'O formalitate administrativă'),
        Answer(letter: 'C', text: 'Un document scris'),
      ],
      correctAnswers: ['A'],
      explanation: 'Consimțământul este acordul liber și neviciat al părților.',
    ),
  ],
  'Drept Penal': [
    Question(
      id: 11,
      text: 'Ce este infracțiunea?',
      answers: [
        Answer(letter: 'A', text: 'Fapta prevăzută de legea penală, săvârșită cu vinovăție'),
        Answer(letter: 'B', text: 'Un contract ilegal'),
        Answer(letter: 'C', text: 'O sancțiune administrativă'),
      ],
      correctAnswers: ['A'],
      explanation: 'Infracțiunea este fapta care întrunește elementele prevăzute de legea penală.',
    ),
    Question(
      id: 12,
      text: 'Ce este legitima apărare?',
      answers: [
        Answer(letter: 'A', text: 'Reacția la un atac injust'),
        Answer(letter: 'B', text: 'O pedeapsă aplicată de instanță'),
        Answer(letter: 'C', text: 'Un acord între părți'),
      ],
      correctAnswers: ['A'],
      explanation: 'Legitima apărare exclude răspunderea penală pentru reacția la un atac.',
    ),
  ],
  'Drept Procesual Civil': [
    Question(
      id: 6,
      text: 'Ce este competența materială a instanței?',
      answers: [
        Answer(letter: 'A', text: 'Capacitatea instanței de a judeca anumite categorii de cauze'),
        Answer(letter: 'B', text: 'Dreptul părților de a apela'),
        Answer(letter: 'C', text: 'Obligația de a depune probe'),
      ],
      correctAnswers: ['A'],
      explanation: 'Competența materială se referă la tipurile de cauze pe care le poate judeca o instanță.',
    ),
  ],
  'Drept Procesual Penal': [
    Question(
      id: 16,
      text: 'Ce este urmărirea penală?',
      answers: [
        Answer(letter: 'A', text: 'Faza procesului penal de strângere a probelor'),
        Answer(letter: 'B', text: 'Sentința finală a instanței'),
        Answer(letter: 'C', text: 'Apelul unei decizii'),
      ],
      correctAnswers: ['A'],
      explanation: 'Urmărirea penală identifică și strânge probele împotriva suspectului.',
    ),
  ],
};

// Main GrileRandom page
class GrileRandomPage extends StatefulWidget {
  const GrileRandomPage({super.key});

  @override
  State<GrileRandomPage> createState() => _GrileRandomPageState();
}

class _GrileRandomPageState extends State<GrileRandomPage> with TickerProviderStateMixin {
  String? _selectedSubject;
  bool _isQuizMode = false;
  List<Map<String, dynamic>> _questionHistory = []; // Stores {question, selectedAnswers}
  int _currentQuestionIndex = 0;
  bool _hasSubmitted = false;
  Set<String> _selectedAnswers = {};
  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnimation;

  @override
  void initState() {
    super.initState();
    // Feedback animation
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _feedbackAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _startQuiz() {
    if (_selectedSubject != null && _questionBank[_selectedSubject]!.isNotEmpty) {
      setState(() {
        _isQuizMode = true;
        _questionHistory = [
          {
            'question': _questionBank[_selectedSubject]![_random.nextInt(_questionBank[_selectedSubject]!.length)],
            'selectedAnswers': <String>{},
          }
        ];
        _currentQuestionIndex = 0;
        _hasSubmitted = false;
        _selectedAnswers = {};
      });
      HapticFeedback.mediumImpact();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te rugăm să selectezi o materie validă!')),
      );
    }
  }

  void _nextQuestion() {
    if (_selectedSubject != null) {
      setState(() {
        _questionHistory.add({
          'question': _questionBank[_selectedSubject]![_random.nextInt(_questionBank[_selectedSubject]!.length)],
          'selectedAnswers': <String>{},
        });
        _currentQuestionIndex = _questionHistory.length - 1;
        _hasSubmitted = false;
        _selectedAnswers = {};
        _feedbackController.reset();
      });
      HapticFeedback.lightImpact();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _hasSubmitted = true;
        _selectedAnswers = _questionHistory[_currentQuestionIndex]['selectedAnswers'] as Set<String>;
        _feedbackController.forward();
      });
      HapticFeedback.lightImpact();
    }
  }

  void _submitAnswer() {
    if (_selectedAnswers.isNotEmpty) {
      setState(() {
        _hasSubmitted = true;
        _questionHistory[_currentQuestionIndex]['selectedAnswers'] = _selectedAnswers.toSet();
        _feedbackController.forward();
      });
      HapticFeedback.mediumImpact();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selectează cel puțin un răspuns!')),
      );
    }
  }

  void _closeQuiz() {
    Navigator.pop(context); // Return to AdmitereINMPage
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: _isQuizMode
              ? _buildQuizScreen(context, screenWidth, screenHeight)
              : _buildSelectionScreen(context, screenWidth),
        ),
      ),
    );
  }

  Widget _buildSelectionScreen(BuildContext context, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Grile Random',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 32),
          DropdownButtonFormField<String>(
            value: _selectedSubject,
            hint: Text(
              'Selectează materia',
              style: GoogleFonts.poppins(color: Colors.black54),
            ),
            items: _questionBank.keys
                .map((subject) => DropdownMenuItem(value: subject, child: Text(subject)))
                .toList(),
            onChanged: (value) => setState(() => _selectedSubject = value),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black26),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black26),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black,
            ),
            dropdownColor: Colors.white,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _startQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.2),
            ),
            child: Text(
              'Începe',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizScreen(BuildContext context, double screenWidth, double screenHeight) {
    final currentEntry = _questionHistory[_currentQuestionIndex];
    final Question question = currentEntry['question'] as Question;

    return Stack(
      children: [
        // Question card
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 60), // Lowered to avoid Close button overlap
            child: Container(
              width: screenWidth * 0.95,
              height: screenHeight * 0.80, // Reduced height to fit
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.black12),
              ),
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_currentQuestionIndex + 1}. ${question.text}',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 12),
                    ...question.answers.map((answer) {
                      final isSelected = _selectedAnswers.contains(answer.letter);
                      final isCorrect = question.correctAnswers.contains(answer.letter);
                      final isWrong = _hasSubmitted && isSelected && !isCorrect;
                      final isCorrectAnswer = _hasSubmitted && isCorrect;

                      return GestureDetector(
                        onTap: _hasSubmitted
                            ? null
                            : () {
                                setState(() {
                                  if (_selectedAnswers.contains(answer.letter)) {
                                    _selectedAnswers.remove(answer.letter);
                                  } else {
                                    _selectedAnswers.add(answer.letter);
                                  }
                                });
                                HapticFeedback.lightImpact();
                              },
                        child: AnimatedScale(
                          scale: isSelected && !_hasSubmitted ? 1.02 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _hasSubmitted
                                  ? (isWrong
                                      ? Colors.red.withOpacity(0.2)
                                      : isCorrectAnswer
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.white)
                                  : isSelected
                                      ? Colors.grey[200]
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _hasSubmitted
                                    ? (isWrong
                                        ? Colors.red
                                        : isCorrectAnswer
                                            ? Colors.green
                                            : Colors.black12)
                                    : Colors.black12,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  answer.letter,
                                  style: GoogleFonts.poppins(
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    answer.text,
                                    style: GoogleFonts.poppins(
                                      fontSize: screenWidth * 0.04,
                                      color: Colors.black,
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                                if (_hasSubmitted)
                                  Icon(
                                    isWrong ? Icons.close : (isCorrect ? Icons.check : null),
                                    color: isWrong ? Colors.red : Colors.green,
                                    size: screenWidth * 0.05,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    if (_hasSubmitted)
                      FadeTransition(
                        opacity: _feedbackAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              'Corect este: ${question.correctAnswers.join(', ')}',
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              question.explanation,
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.035,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (!_hasSubmitted)
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: _submitAnswer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 2,
                          ),
                          child: Text(
                            'Verifică răspunsul',
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Navigation buttons
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavButton(
                icon: Icons.arrow_back,
                onPressed: _previousQuestion,
                enabled: _currentQuestionIndex > 0,
              ),
              _buildNavButton(
                icon: Icons.arrow_forward,
                onPressed: _nextQuestion,
                enabled: _hasSubmitted,
              ),
            ],
          ),
        ),
        // Close button
        Positioned(
          top: 16,
          right: 16,
          child: _buildNavButton(
            icon: Icons.close,
            onPressed: _closeQuiz,
            enabled: true,
            size: 36,
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool enabled,
    double size = 48,
  }) {
    return AnimatedScale(
      scale: enabled ? 1.0 : 0.8,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.black12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: enabled ? Colors.black : Colors.black26,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}