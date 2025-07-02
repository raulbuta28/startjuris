import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'meciuri2.dart';
import 'meciuri3.dart';

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

class _BattleProgressBarState extends State<BattleProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _lightningController;
  late Animation<double> _lightningAnimation;

  @override
  void initState() {
    super.initState();
    _lightningController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _lightningAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.7), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.0), weight: 10),
    ]).animate(_lightningController);

    _lightningController.repeat();
  }

  @override
  void dispose() {
    _lightningController.dispose();
    super.dispose();
  }

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
      height: 50, // Reduced height
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          // Battle line with lightning
          Positioned.fill(
            child: CustomPaint(
              painter: LightningPainter(_lightningAnimation, Colors.white),
            ),
          ),
          // Player 1 score (Red)
          Positioned(
            left: 0,
            width: 120, // Wider to accommodate text
            top: 5, // Adjusted positioning
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
            width: 120, // Wider to accommodate text
            top: 5, // Adjusted positioning
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
        ],
      ),
    );
  }
}

// MeciuriPage: 24-26px gap, larger subject buttons, bigger text, custom border for selector
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
  bool _showingFeedback = false;
  final GlobalKey<QuestionTimerState> _timerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
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
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void _handleTimeUp() {
    setState(() {
      _showingFeedback = true;
    });
  }

  void _exitMatch() {
    setState(() {
      _matchActive = false;
      _showingFeedback = false;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: CameraPreview(_controller!)),
                  Expanded(child: CameraPreview(_controller!)),
                ],
              ),
            ),
            if (_matchActive && !_showingFeedback)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.topRight,
                  child: QuestionTimer(
                    key: _timerKey,
                    onTimeUp: _handleTimeUp,
                    isActive: _matchActive && !_showingFeedback,
                    onTick: () {},
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exitMatch,
        child: const Icon(Icons.close),
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

  const GameSummary({
    super.key,
    required this.questions,
    required this.player1Answers,
    required this.player2Answers,
    required this.player1Score,
    required this.player2Score,
    this.cameraController,
  });

  @override
  Widget build(BuildContext context) {
    final winner = player1Score > player2Score ? 1 : (player2Score > player1Score ? 2 : 0);
    
    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            // Trophy and winner section
            Container(
              width: double.infinity, // Ensure container takes full width
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
                      'Câștigător: Player ${winner}',
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
                      _buildPlayerScore('Player 1', player1Score, Colors.red),
                      Container(
                        width: 2,
                        height: 50,
                        color: Colors.white24,
                      ),
                      _buildPlayerScore('Player 2', player2Score, Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Updated camera previews with correct aspect ratio and circular shape
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
            // Questions summary with constrained width
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  ...questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    final player1Answer = player1Answers[index];
                    final player2Answer = player2Answers[index];
                    
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPlayerAnswer(
                            'Player 1',
                            player1Answer,
                            question['correct'],
                            Colors.red,
                          ),
                          const SizedBox(height: 8),
                          _buildPlayerAnswer(
                            'Player 2',
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
                                  'Explicație:',
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
                ],
              ),
            ),
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
        Text(
          answer,
          style: GoogleFonts.montserrat(
            color: isCorrect ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 14,
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