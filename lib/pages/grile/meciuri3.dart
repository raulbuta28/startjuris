import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BattleAnimation extends StatefulWidget {
  final int player1Score;
  final int player2Score;
  final bool isActive;

  const BattleAnimation({
    super.key,
    required this.player1Score,
    required this.player2Score,
    required this.isActive,
  });

  @override
  _BattleAnimationState createState() => _BattleAnimationState();
}

class _BattleAnimationState extends State<BattleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BattleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _BattlePainter(
            animation: _animation.value,
            player1Score: widget.player1Score,
            player2Score: widget.player2Score,
            isActive: widget.isActive,
          ),
        );
      },
    );
  }
}

class _BattlePainter extends CustomPainter {
  final double animation;
  final int player1Score;
  final int player2Score;
  final bool isActive;

  const _BattlePainter({
    required this.animation,
    required this.player1Score,
    required this.player2Score,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw energy waves
    if (isActive) {
      _drawEnergyWaves(canvas, size, center);
    }
    
    // Draw score orbs
    _drawScoreOrbs(canvas, size, center);
  }

  void _drawEnergyWaves(Canvas canvas, Size size, Offset center) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Player 1 energy (red)
    final redPaint = paint
      ..color = Colors.red.withOpacity(0.3 + animation * 0.4)
      ..strokeWidth = 3;
    
    final redRadius = 50 + animation * 30;
    canvas.drawCircle(
      Offset(size.width * 0.25, center.dy),
      redRadius,
      redPaint,
    );

    // Player 2 energy (blue)
    final bluePaint = paint
      ..color = Colors.blue.withOpacity(0.3 + animation * 0.4)
      ..strokeWidth = 3;
    
    final blueRadius = 50 + animation * 30;
    canvas.drawCircle(
      Offset(size.width * 0.75, center.dy),
      blueRadius,
      bluePaint,
    );

    // Central clash effect
    final clashPaint = Paint()
      ..color = Colors.white.withOpacity(animation * 0.5)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 20 + animation * 10, clashPaint);
  }

  void _drawScoreOrbs(Canvas canvas, Size size, Offset center) {
    // Player 1 score orbs
    _drawPlayerOrbs(
      canvas,
      Offset(size.width * 0.25, center.dy),
      player1Score,
      Colors.red,
    );

    // Player 2 score orbs
    _drawPlayerOrbs(
      canvas,
      Offset(size.width * 0.75, center.dy),
      player2Score,
      Colors.blue,
    );
  }

  void _drawPlayerOrbs(Canvas canvas, Offset center, int score, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * pi / 5) - pi / 2;
      final orbCenter = center + Offset(
        cos(angle) * 40,
        sin(angle) * 40,
      );

      final orbRadius = i < score ? 8.0 : 4.0;
      final orbOpacity = i < score ? 1.0 : 0.3;

      // Draw shadow
      canvas.drawCircle(orbCenter, orbRadius + 2, shadowPaint);
      
      // Draw orb
      final orbPaint = paint..color = color.withOpacity(orbOpacity);
      canvas.drawCircle(orbCenter, orbRadius, orbPaint);

      if (i < score) {
        // Add sparkle effect
        final sparklePaint = Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(orbCenter, 3, sparklePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BattlePainter oldDelegate) => true;
}

class ScoreDisplay extends StatelessWidget {
  final int player1Score;
  final int player2Score;
  final String player1Name;
  final String player2Name;

  const ScoreDisplay({
    super.key,
    required this.player1Score,
    required this.player2Score,
    this.player1Name = 'Player 1',
    this.player2Name = 'Player 2',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPlayerScore(player1Name, player1Score, Colors.red),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: 2,
            height: 30,
            color: Colors.white24,
          ),
          _buildPlayerScore(player2Name, player2Score, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildPlayerScore(String name, int score, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: GoogleFonts.montserrat(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          score.toString(),
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class QuestionProgressBar extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;

  const QuestionProgressBar({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentQuestion / totalQuestions;
    
    return Container(
      width: double.infinity,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: MediaQuery.of(context).size.width * progress,
            height: 8,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.blue],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // Question markers
          ...List.generate(totalQuestions, (index) {
            final isCompleted = index < currentQuestion;
            final isCurrent = index == currentQuestion;
            final markerPosition = (index + 1) / totalQuestions;
            
            return Positioned(
              left: MediaQuery.of(context).size.width * markerPosition - 6,
              top: -2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? Colors.green 
                      : isCurrent 
                          ? Colors.orange 
                          : Colors.white24,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Center(
                  child: isCompleted 
                      ? const Icon(Icons.check, size: 8, color: Colors.white)
                      : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
