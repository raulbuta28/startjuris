import 'dart:math';
import 'package:flutter/material.dart';

class PreviewBattleLines extends StatefulWidget {
  final int player1Score;
  final int player2Score;
  final double progress;

  const PreviewBattleLines({
    super.key,
    required this.player1Score,
    required this.player2Score,
    required this.progress,
  });

  @override
  _PreviewBattleLinesState createState() => _PreviewBattleLinesState();
}

class _PreviewBattleLinesState extends State<PreviewBattleLines>
    with SingleTickerProviderStateMixin {
  static const double _stroke = 12.0;
  static const double _riseAmount = 200.0;
  static const Duration _cycle = Duration(seconds: 6);

  late final AnimationController _ctrl;
  late final Animation<double> _vProgress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _cycle)..repeat();
    _vProgress = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: _stroke + _riseAmount + 100,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final v = _vProgress.value;
          final t = _ctrl.value;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: _BattleLinePainter(
                  v: v,
                  t: t,
                  progress: widget.progress,
                ),
              ),
              if (v > 0)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ScorePainter(
                      pink: widget.player1Score,
                      gold: widget.player2Score,
                      t: t,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BattleLinePainter extends CustomPainter {
  final double v, t, progress;

  static const double _stroke = _PreviewBattleLinesState._stroke;
  static const double _rise = _PreviewBattleLinesState._riseAmount;

  const _BattleLinePainter({
    required this.v,
    required this.t,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.width / 2;
    final baseY = size.height - _stroke / 2;

    final pinkPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF4081), Color(0xFFF50057)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, _stroke));

    final goldPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFC107)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, _stroke));

    final bubblePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final rnd = Random((t * 1000).toInt());

    canvas.drawLine(Offset(0, baseY), Offset(mid, baseY), pinkPaint);
    canvas.drawLine(Offset(size.width, baseY), Offset(mid, baseY), goldPaint);

    final dyLeft = v * _rise * (1.0 + progress * 0.5);
    final dyRight = v * _rise * (0.5 + progress * 0.5);
    final leftTip = Offset(mid - _stroke / 2, baseY - dyLeft);
    final rightTip = Offset(mid + _stroke / 2, baseY - dyRight);
    canvas.drawLine(Offset(mid - _stroke / 2, baseY), leftTip, pinkPaint);
    canvas.drawLine(Offset(mid + _stroke / 2, baseY), rightTip, goldPaint);

    for (int i = 0; i < 5; i++) {
      final t1 = rnd.nextDouble();
      final x1 = leftTip.dx + (rnd.nextDouble() - 0.5) * _stroke * 0.6;
      final y1 = baseY - dyLeft * t1 + (rnd.nextDouble() - 0.5) * _stroke * 0.4;
      final r1 = _stroke * (rnd.nextDouble() * 0.3 + 0.2);
      canvas.drawCircle(Offset(x1, y1), r1, bubblePaint);

      final t2 = rnd.nextDouble();
      final x2 = rightTip.dx + (rnd.nextDouble() - 0.5) * _stroke * 0.6;
      final y2 = baseY - dyRight * t2 + (rnd.nextDouble() - 0.5) * _stroke * 0.4;
      final r2 = _stroke * (rnd.nextDouble() * 0.3 + 0.2);
      canvas.drawCircle(Offset(x2, y2), r2, bubblePaint);
    }

    const sparkleSize = _stroke * 1.5;
    _drawSparkle(canvas, leftTip, sparkleSize, t, [
      const Color(0xFFF50057),
      const Color(0xFFFF4081),
    ]);
    _drawSparkle(canvas, rightTip, sparkleSize, t, [
      const Color(0xFFFFD700),
      const Color(0xFFFFC107),
    ]);
  }

  void _drawSparkle(
      Canvas canvas, Offset c, double s, double t, List<Color> colors) {
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..style = PaintingStyle.fill;

    final sparklePaint = Paint()
      ..shader = RadialGradient(colors: colors)
          .createShader(Rect.fromCircle(center: c, radius: s))
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final angle = 2 * pi * i / 6 + t * 2 * pi;
      final scale = 0.5 + 0.3 * sin(t * 4 + i);
      final offset = Offset(cos(angle), sin(angle)) * s * scale;
      final particle = c + offset;
      final r = s * 0.2 * (1 + 0.3 * sin(t * 6 + i));
      canvas.drawCircle(particle, r, glowPaint);
      canvas.drawCircle(particle, r * 0.6, sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BattleLinePainter old) => true;
}

class _ScorePainter extends CustomPainter {
  final int pink, gold;
  final double t;

  const _ScorePainter({
    required this.pink,
    required this.gold,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = _PreviewBattleLinesState._stroke;
    final baseY = size.height - stroke / 2;

    void _flames(Offset c) {
      for (int i = 0; i < 6; i++) {
        final ang = 2 * pi * i / 6 + t * 2 * pi;
        final off = Offset(cos(ang), sin(ang)) * (30 + sin(t * 8 + i) * 6);
        canvas.drawCircle(
          c + off,
          6 + sin(t * 12 + i) * 3,
          Paint()
            ..color = Color.lerp(
                Colors.yellow, Colors.red, (sin(t * 8 + i) + 1) / 2)!
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }

    void _box(Offset c, String label, List<Color> grad) {
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final w = tp.width + 12;
      final h = tp.height + 8;
      final rect = Rect.fromCenter(center: c, width: w, height: h);
      final paint = Paint()
        ..shader = LinearGradient(colors: grad).createShader(rect);
      _flames(c);
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)), paint);
      tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
    }

    _box(Offset(size.width * 0.25, baseY), '$pink puncte',
        [const Color(0xFFFF4081), const Color(0xFFF50057)]);
    _box(Offset(size.width * 0.75, baseY), '$gold puncte',
        [const Color(0xFFFFD700), Color(0xFFFFC107)]);
  }

  @override
  bool shouldRepaint(covariant _ScorePainter old) => true;
}