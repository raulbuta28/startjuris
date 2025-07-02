import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../backend/providers/auth_provider.dart';
import 'meciuri2.dart';
import 'meciuri3.dart';
import '../../services/tests_service.dart';

// Sample questions data
final Map<String, List<Map<String, dynamic>>> questionsData = {
  'Drept civil': [
    {
      'question': 'Care este termenul de prescripție extinctivă pentru drepturile patrimoniale?',
      'options': ['3 ani', '5 ani', '10 ani', '15 ani'],
      'correct': '3 ani',
      'explanation': 'Conform art. 2517 Cod civil, termenul general de prescripție extinctivă este de 3 ani.'
    },
    {
      'question': 'Contractul de vânzare-cumpărare se încheie prin:',
      'options': ['Acordul de voințe', 'Plata prețului', 'Predarea bunului', 'Înregistrarea la notariat'],
      'correct': 'Acordul de voințe',
      'explanation': 'Contractul este consensual și se încheie prin simpla întâlnire a consimțămintelor.'
    },
    {
      'question': 'Capacitatea de exercițiu completă se dobândește la vârsta de:',
      'options': ['16 ani', '18 ani', '21 ani', '25 ani'],
      'correct': '18 ani',
      'explanation': 'Conform art. 37 Cod civil, capacitatea de exercițiu completă se dobândește la majorat.'
    },
    {
      'question': 'Actul juridic nul de drept este:',
      'options': ['Anulabil', 'Neexistent', 'Absolut nul', 'Relativ nul'],
      'correct': 'Absolut nul',
      'explanation': 'Actul juridic nul de drept este lovit de nulitate absolută și nu poate fi confirmat.'
    },
    {
      'question': 'Servitutea este un drept real:',
      'options': ['Principal', 'Accesoriu', 'De garanție', 'De folosință'],
      'correct': 'Accesoriu',
      'explanation': 'Servitutea este un drept real accesoriu care grevează un imobil în favoarea altuia.'
    }
  ],
  'Drept penal': [
    {
      'question': 'Tentativa la infracțiune se pedepsește cu:',
      'options': ['Jumătate din pedeapsa prevăzută', 'Pedeapsa întreagă', '1/3 din pedeapsa prevăzută', 'Nu se pedepsește'],
      'correct': 'Jumătate din pedeapsa prevăzută',
      'explanation': 'Conform art. 32 Cod penal, tentativa se pedepsește cu jumătate din limitele pedepsei.'
    },
    {
      'question': 'Complicitatea morală constă în:',
      'options': ['Ajutorarea la săvârșire', 'Determinarea la săvârșire', 'Organizarea infracțiunii', 'Ascunderea urmelor'],
      'correct': 'Determinarea la săvârșire',
      'explanation': 'Complicitatea morală presupune determinarea unei persoane să săvârșească o infracțiune.'
    },
    {
      'question': 'Circumstanța atenuantă prevăzută în Codul penal este:',
      'options': ['Reintegrarea daunei', 'Vârsta fragedă a victimei', 'Săvârșirea în grup', 'Recidiva'],
      'correct': 'Reintegrarea daunei',
      'explanation': 'Reintegrarea daunei sau repararea pagubei sunt circumstanțe atenuante legale.'
    },
    {
      'question': 'Infracțiunea continuată presupune:',
      'options': ['O singură rezoluție criminală', 'Mai multe rezoluții', 'Săvârșirea în grup', 'Recidiva'],
      'correct': 'O singură rezoluție criminală',
      'explanation': 'Infracțiunea continuată se caracterizează prin unitatea de rezoluție criminală.'
    },
    {
      'question': 'Termenul de prescripție pentru infracțiunile foarte grave este:',
      'options': ['5 ani', '10 ani', '15 ani', '20 ani'],
      'correct': '20 ani',
      'explanation': 'Pentru infracțiunile foarte grave, termenul de prescripție este de 20 de ani.'
    }
  ],
  'Drept procesual civil': [
    {
      'question': 'Cererea de chemare în judecată se depune la:',
      'options': ['Judecătoria', 'Tribunalul', 'Curtea de Apel', 'Instanța competentă'],
      'correct': 'Instanța competentă',
      'explanation': 'Cererea se depune la instanța competentă să judece cauza conform legii.'
    },
    {
      'question': 'Termenul pentru formularea apelului este de:',
      'options': ['10 zile', '15 zile', '30 zile', '60 zile'],
      'correct': '30 zile',
      'explanation': 'Apelul se formulează în termen de 30 de zile de la pronunțare sau comunicare.'
    },
    {
      'question': 'Proba cu martori se administrează prin:',
      'options': ['Întrebări libere', 'Interogatoriu', 'Declarații scrise', 'Toate variantele'],
      'correct': 'Interogatoriu',
      'explanation': 'Martorii sunt audiați prin interogatoriu, după depunerea jurământului.'
    },
    {
      'question': 'Recursul în casație se formulează împotriva:',
      'options': ['Sentințelor', 'Încheierii', 'Deciziilor definitive', 'Ordonanțelor'],
      'correct': 'Deciziilor definitive',
      'explanation': 'Recursul în casație se poate formula doar împotriva deciziilor definitive.'
    },
    {
      'question': 'Competența teritorială se stabilește după:',
      'options': ['Domiciliul reclamantului', 'Domiciliul pârâtului', 'Locul faptei', 'Alegerea părților'],
      'correct': 'Domiciliul pârâtului',
      'explanation': 'Regula generală: actor sequitur forum rei (actorul urmează instanța pârâtului).'
    }
  ],
  'Drept procesual penal': [
    {
      'question': 'Termenul pentru formularea recursului în casație este:',
      'options': ['10 zile', '15 zile', '30 zile', '45 zile'],
      'correct': '15 zile',
      'explanation': 'Recursul în casație se formulează în termen de 15 zile de la comunicare.'
    },
    {
      'question': 'Arestul preventiv poate fi dispus pentru maximum:',
      'options': ['30 zile', '60 zile', '90 zile', '180 zile'],
      'correct': '30 zile',
      'explanation': 'Arestul preventiv se poate dispune pentru maximum 30 de zile, cu posibilitatea prelungirii.'
    },
    {
      'question': 'Percheziția domiciliară se efectuează cu:',
      'options': ['Ordin verbal', 'Mandat scris', 'Autorizație telefonică', 'Aprobare ulterioară'],
      'correct': 'Mandat scris',
      'explanation': 'Percheziția domiciliară se efectuează numai cu mandat scris motivat.'
    },
    {
      'question': 'Controlul judiciar poate fi dispus pentru:',
      'options': ['15 zile', '30 zile', '60 zile', '90 zile'],
      'correct': '60 zile',
      'explanation': 'Controlul judiciar se poate dispune pentru maximum 60 de zile, cu posibilitatea prelungirii.'
    },
    {
      'question': 'Flagrantul delict presupune:',
      'options': ['Săvârșirea anterioară', 'Săvârșirea în timpul constatării', 'Urmele infracțiunii', 'Toate variantele'],
      'correct': 'Săvârșirea în timpul constatării',
      'explanation': 'Flagrantul presupune surprinderea făptuitorului în timp ce săvârșește infracțiunea.'
    }
  ]
};

class LightningPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  LightningPainter(this.animation, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(animation.value)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(0, size.height / 2);
    
    // Create lightning effect
    final segments = 5;
    final segmentWidth = size.width / segments;
    var lastY = size.height / 2;

    for (var i = 1; i <= segments; i++) {
      final x = segmentWidth * i;
      final y = size.height / 2 + (i % 2 == 0 ? -10 : 10);
      path.lineTo(x, y);
      lastY = y;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LightningPainter oldDelegate) => true;
}

class BattleProgressBar extends StatefulWidget {
  final double player1Progress;
  final double player2Progress;
  final int player1Score;
  final int player2Score;

  const BattleProgressBar({
    super.key,
    required this.player1Progress,
    required this.player2Progress,
    required this.player1Score,
    required this.player2Score,
  });

  @override
  State<BattleProgressBar> createState() => _BattleProgressBarState();
}

class _BattleProgressBarState extends State<BattleProgressBar> {
  Widget _buildScoreText(int score) {
    String suffix;
    if (score == 0) {
      suffix = 'corecte';
    } else if (score == 1) {
      suffix = 'corectă';
    } else {
      suffix = 'corecte';
    }
    return Text(
      '$score $suffix',
      style: GoogleFonts.montserrat(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          // Background line
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 25),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Player 1 score (Red)
          Positioned(
            left: 0,
            width: 120,
            top: 5,
            bottom: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade600, Colors.red.shade400],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: _buildScoreText(widget.player1Score),
              ),
            ),
          ),
          // Player 2 score (Blue)
          Positioned(
            right: 0,
            width: 120,
            top: 5,
            bottom: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: _buildScoreText(widget.player2Score),
              ),
            ),
          ),
          // VS in center
          Positioned.fill(
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    'VS',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MeciuriPage extends StatefulWidget {
  const MeciuriPage({super.key});

  static Widget buildFindAdversaryButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MeciuriPage()),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                'Găsește adversar',
                style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<MeciuriPage> createState() => _MeciuriPageState();
}

class _MeciuriPageState extends State<MeciuriPage> {
  CameraController? _controller;
  bool _matchActive = false;
  bool _gameFinished = false;
  String? _selectedSubject;
  late String _player1Name;
  String _player2Name = 'Adversar';
  
  int _currentQuestionIndex = 0;
  int _player1Score = 0;
  int _player2Score = 0;
  
  List<Map<String, dynamic>> _currentQuestions = [];
  Map<int, String> _player1Answers = {};
  Map<int, String> _player2Answers = {};
  String? _player1CurrentAnswer;
  String? _player2CurrentAnswer;

  List<FetchedTest> _tests = [];
  bool _loadingTests = false;
  String? _selectedChapter;
  int _numQuestions = 5;
  int _totalQuestions = 5;
  
  Timer? _questionTimer;
  int _secondsLeft = 15;
  bool _timeUp = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    final auth = context.read<AuthProvider>();
    _player1Name = auth.user?.username ?? 'Player 1';
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _loadTests() async {
    setState(() => _loadingTests = true);
    try {
      _tests = await TestsService.fetchTests();
    } catch (e) {
      debugPrint('Failed to load tests: $e');
    }
    setState(() => _loadingTests = false);
  }

  void _selectSubject(String subject) {
    setState(() {
      _selectedSubject = subject;
      _selectedChapter = null;
    });
    if (_tests.isEmpty) {
      _loadTests();
    }
  }

  void _startMatch() {
    if (_selectedSubject == null) return;

    List<Map<String, dynamic>> all = [];
    for (final t in _tests) {
      if (t.subject != _selectedSubject) continue;
      if (_selectedChapter != null && _selectedChapter!.isNotEmpty && _selectedChapter != 'Toată materia' && t.name != _selectedChapter) {
        continue;
      }
      for (final q in t.questions) {
        all.add({
          'question': q.text,
          'options': q.answers.map((a) => a.text).toList(),
          'correct': q.correctAnswers.isNotEmpty ? q.correctAnswers.first : '',
          'explanation': q.explanation,
        });
      }
    }
    if (all.isEmpty) return;
    all.shuffle();
    final selected = all.take(_numQuestions).toList();

    setState(() {
      _matchActive = true;
      _currentQuestions = selected;
      _totalQuestions = selected.length;
      _currentQuestionIndex = 0;
      _player1Score = 0;
      _player2Score = 0;
      _player1Answers.clear();
      _player2Answers.clear();
      _player1CurrentAnswer = null;
      _player2CurrentAnswer = null;
    });

    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    _secondsLeft = 15;
    _timeUp = false;
    _questionTimer?.cancel();
    
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _timeUp = true;
          _handleTimeUp();
          timer.cancel();
        }
      });
    });
  }

  void _handleTimeUp() {
    // Auto-save current answers
    if (_player1CurrentAnswer != null) {
      _player1Answers[_currentQuestionIndex] = _player1CurrentAnswer!;
    }
    if (_player2CurrentAnswer != null) {
      _player2Answers[_currentQuestionIndex] = _player2CurrentAnswer!;
    }
    
    _nextQuestion();
  }

  void _selectAnswer(int player, String answer) {
    setState(() {
      if (player == 1) {
        _player1CurrentAnswer = answer;
      } else {
        _player2CurrentAnswer = answer;
      }
    });
    
    // If both players answered, proceed to next question
    if (_player1CurrentAnswer != null && _player2CurrentAnswer != null) {
      _player1Answers[_currentQuestionIndex] = _player1CurrentAnswer!;
      _player2Answers[_currentQuestionIndex] = _player2CurrentAnswer!;
      
      Future.delayed(const Duration(milliseconds: 500), () {
        _nextQuestion();
      });
    }
  }

  void _nextQuestion() {
    _questionTimer?.cancel();
    
    // Calculate scores for current question
    final correctAnswer = _currentQuestions[_currentQuestionIndex]['correct'];
    if (_player1Answers[_currentQuestionIndex] == correctAnswer) {
      _player1Score++;
    }
    if (_player2Answers[_currentQuestionIndex] == correctAnswer) {
      _player2Score++;
    }
    
    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _player1CurrentAnswer = null;
        _player2CurrentAnswer = null;
      });
      _startQuestionTimer();
    } else {
      _finishGame();
    }
  }

  void _finishGame() {
    setState(() {
      _gameFinished = true;
      _matchActive = false;
    });
    _questionTimer?.cancel();
  }

  void _exitMatch() {
    _questionTimer?.cancel();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_gameFinished) {
      return GameSummary(
        questions: _currentQuestions,
        player1Answers: _player1Answers.values.toList(),
        player2Answers: _player2Answers.values.toList(),
        player1Score: _player1Score,
        player2Score: _player2Score,
        cameraController: _controller,
        player1Name: _player1Name,
        player2Name: _player2Name,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Camera previews
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 2),
                          ),
                          child: CameraPreview(_controller!),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 2),
                          ),
                          child: CameraPreview(_controller!),
                        ),
                      ),
                    ],
                  ),
                  // Player labels
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _player1Name,
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _player2Name,
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  // Timer
                  if (_matchActive)
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _secondsLeft <= 5 ? Colors.red : Colors.black87,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _secondsLeft <= 5 ? Colors.red : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            _secondsLeft.toString(),
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Battle progress bar
            if (_matchActive)
              BattleProgressBar(
                player1Progress: _player1Score / _totalQuestions,
                player2Progress: _player2Score / _totalQuestions,
                player1Score: _player1Score,
                player2Score: _player2Score,
              ),
            // Bottom section
            Expanded(
              flex: 2,
              child: BottomSection(
                matchActive: _matchActive,
                selectedSubject: _selectedSubject,
                chapters: _tests
                    .where((t) => t.subject == _selectedSubject)
                    .map((t) => t.name)
                    .toSet()
                    .toList(),
                selectedChapter: _selectedChapter,
                onSelectChapter: (c) => setState(() => _selectedChapter = c),
                onSelectSubject: _selectSubject,
                onStartMatch: _startMatch,
                questionCount: _numQuestions,
                onSelectQuestionCount: (c) => setState(() => _numQuestions = c),
                loading: _loadingTests,
                question: _matchActive ? _currentQuestions[_currentQuestionIndex] : null,
                secondsLeft: _secondsLeft,
                onAnswer: (player, answers) => _selectAnswer(player, answers.isNotEmpty ? answers.first : ''),
                onToggleAnswer: _selectAnswer,
                player1Score: _player1Score,
                player2Score: _player2Score,
                questionIndex: _currentQuestionIndex,
                totalQuestions: _totalQuestions,
                isUser1: true,
                player1Name: _player1Name,
                player2Name: _player2Name,
                player1CurrentAnswer: _player1CurrentAnswer,
                player2CurrentAnswer: _player2CurrentAnswer,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exitMatch,
        backgroundColor: Colors.red,
        child: const Icon(Icons.close, color: Colors.white),
      ),
    );
  }
}

class QuestionTimer extends StatefulWidget {
  final VoidCallback onTimeUp;
  final bool isActive;
  final VoidCallback onTick;

  const QuestionTimer({
    super.key,
    required this.onTimeUp,
    required this.isActive,
    required this.onTick,
  });

  @override
  State<QuestionTimer> createState() => QuestionTimerState();
}

class QuestionTimerState extends State<QuestionTimer> with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _secondsLeft = 60;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed && _secondsLeft <= 10) {
        _pulseController.forward();
      }
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!widget.isActive) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
          widget.onTick();
          if (_secondsLeft <= 10 && !_pulseController.isAnimating) {
            _pulseController.forward();
          }
        } else {
          _timer.cancel();
          widget.onTimeUp();
        }
      });
    });
  }

  void resetTimer() {
    setState(() {
      _secondsLeft = 60;
      _pulseController.stop();
      _pulseController.reset();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _secondsLeft <= 10 ? Colors.red : Colors.white;
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.black87,
          border: Border.all(
            color: color,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            _secondsLeft.toString(),
            style: GoogleFonts.montserrat(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class AnswerFeedback extends StatelessWidget {
  final bool isCorrect;
  final String selectedAnswer;
  final String correctAnswer;
  final String explanation;

  const AnswerFeedback({
    super.key,
    required this.isCorrect,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Răspuns corect!' : 'Răspuns greșit',
                style: GoogleFonts.montserrat(
                  color: isCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 8),
            Text(
              'Ai selectat: $selectedAnswer',
              style: GoogleFonts.montserrat(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            Text(
              'Răspuns corect: $correctAnswer',
              style: GoogleFonts.montserrat(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            explanation,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class GameSummary extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final List<String> player1Answers;
  final List<String> player2Answers;
  final int player1Score;
  final int player2Score;
  final CameraController? cameraController;
  final String player1Name;
  final String player2Name;

  const GameSummary({
    super.key,
    required this.questions,
    required this.player1Answers,
    required this.player2Answers,
    required this.player1Score,
    required this.player2Score,
    this.cameraController,
    required this.player1Name,
    required this.player2Name,
  });

  @override
  Widget build(BuildContext context) {
    final winner = player1Score > player2Score ? 1 : (player2Score > player1Score ? 2 : 0);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              // Trophy and winner section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade900, Colors.blue.shade900],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (winner != 0) ...[
                      Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: winner == 1 ? Colors.red : Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Câștigător: Player $winner',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.handshake,
                        size: 80,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Remiză!',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPlayerScore(player1Name, player1Score, Colors.red),
                        Container(
                          width: 2,
                          height: 50,
                          color: Colors.white24,
                        ),
                        _buildPlayerScore(player2Name, player2Score, Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Camera previews
              if (cameraController != null) SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCircularCameraPreview(Colors.red),
                    const SizedBox(width: 16),
                    _buildCircularCameraPreview(Colors.blue),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Questions summary
              ...questions.asMap().entries.map((entry) {
                final index = entry.key;
                final question = entry.value;
                final player1Answer = index < player1Answers.length ? player1Answers[index] : '';
                final player2Answer = index < player2Answers.length ? player2Answers[index] : '';
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Întrebarea ${index + 1}',
                        style: GoogleFonts.montserrat(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question['question'],
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPlayerAnswer(
                        player1Name,
                        player1Answer,
                        question['correct'],
                        Colors.red,
                      ),
                      const SizedBox(height: 8),
                      _buildPlayerAnswer(
                        player2Name,
                        player2Answer,
                        question['correct'],
                        Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Răspuns corect: ${question['correct']}',
                              style: GoogleFonts.montserrat(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              question['explanation'] ?? 'Nu există explicație disponibilă.',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
              // New match button
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MeciuriPage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade700, Colors.blue.shade700],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      'Începe un meci nou',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerScore(String player, int score, Color color) {
    return Column(
      children: [
        Text(
          player,
          style: GoogleFonts.montserrat(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              score.toString(),
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerAnswer(String player, String answer, String correctAnswer, Color color) {
    final isCorrect = answer == correctAnswer;
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          child: Center(
            child: Icon(
              isCorrect ? Icons.check : Icons.close,
              color: isCorrect ? Colors.green : Colors.red,
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          player,
          style: GoogleFonts.montserrat(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'a răspuns: ',
          style: GoogleFonts.montserrat(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            answer.isEmpty ? 'Nu a răspuns' : answer,
            style: GoogleFonts.montserrat(
              color: answer.isEmpty ? Colors.orange : (isCorrect ? Colors.green : Colors.red),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularCameraPreview(Color borderColor) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: 100,
            height: 100,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Transform.scale(
                scale: cameraController!.value.aspectRatio > 1 ? 
                       cameraController!.value.aspectRatio : 
                       1 / cameraController!.value.aspectRatio,
                child: Center(
                  child: CameraPreview(cameraController!),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
