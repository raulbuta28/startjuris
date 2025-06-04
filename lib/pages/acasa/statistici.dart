import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class StatisticiPage extends StatefulWidget {
  const StatisticiPage({super.key});

  @override
  _StatisticiPageState createState() => _StatisticiPageState();
}

class _StatisticiPageState extends State<StatisticiPage> with TickerProviderStateMixin {
  late AnimationController _pathController;
  late AnimationController _glowController;
  late Animation<double> _pathAnimation;
  late Animation<double> _glowAnimation;
  String _selectedPeriod = 'Ultima săptămână';
  Map<String, Map<String, List<int>>> _statsData = {
    'Azi': {
      'correct': [30],
      'incorrect': [3],
      'timeSpent': [90],
    },
    'Ieri': {
      'correct': [25],
      'incorrect': [5],
      'timeSpent': [80],
    },
    'Ultimele 3 zile': {
      'correct': [20, 25, 30],
      'incorrect': [4, 5, 3],
      'timeSpent': [60, 80, 90],
    },
    'Ultima săptămână': {
      'correct': [10, 15, 20, 18, 22, 25, 30],
      'incorrect': [5, 3, 4, 6, 2, 5, 3],
      'timeSpent': [30, 45, 60, 50, 70, 80, 90],
    },
    'Ultima lună': {
      'correct': [10, 15, 20, 18, 22, 25, 30, 12, 17, 19, 21, 24, 28, 31, 14, 16, 23, 27, 29, 32, 11, 13, 18, 20, 26, 30, 33, 15, 22, 25],
      'incorrect': [5, 3, 4, 6, 2, 5, 3, 4, 2, 5, 3, 4, 6, 2, 5, 3, 4, 2, 5, 3, 4, 6, 2, 5, 3, 4, 2, 5, 3, 4],
      'timeSpent': [30, 45, 60, 50, 70, 80, 90, 35, 55, 65, 45, 75, 85, 95, 40, 50, 60, 70, 80, 90, 30, 45, 60, 50, 70, 80, 90, 35, 55, 65],
    },
    'Ultimele 2 luni': {
      'correct': List.generate(60, (i) => 10 + (i % 30) + Random().nextInt(5)),
      'incorrect': List.generate(60, (i) => 2 + Random().nextInt(4)),
      'timeSpent': List.generate(60, (i) => 30 + (i % 30) + Random().nextInt(20)),
    },
    'Ultimele 3 luni': {
      'correct': List.generate(90, (i) => 12 + (i % 30) + Random().nextInt(6)),
      'incorrect': List.generate(90, (i) => 3 + Random().nextInt(4)),
      'timeSpent': List.generate(90, (i) => 35 + (i % 30) + Random().nextInt(25)),
    },
    'Ultimele 5 luni': {
      'correct': List.generate(150, (i) => 15 + (i % 30) + Random().nextInt(8)),
      'incorrect': List.generate(150, (i) => 3 + Random().nextInt(5)),
      'timeSpent': List.generate(150, (i) => 40 + (i % 30) + Random().nextInt(30)),
    },
    'Ultimele 7 luni': {
      'correct': List.generate(210, (i) => 18 + (i % 30) + Random().nextInt(10)),
      'incorrect': List.generate(210, (i) => 4 + Random().nextInt(5)),
      'timeSpent': List.generate(210, (i) => 45 + (i % 30) + Random().nextInt(35)),
    },
    'Ultimele 9 luni': {
      'correct': List.generate(270, (i) => 20 + (i % 30) + Random().nextInt(12)),
      'incorrect': List.generate(270, (i) => 4 + Random().nextInt(6)),
      'timeSpent': List.generate(270, (i) => 50 + (i % 30) + Random().nextInt(40)),
    },
    'Ultimul an': {
      'correct': List.generate(365, (i) => 22 + (i % 30) + Random().nextInt(15)),
      'incorrect': List.generate(365, (i) => 5 + Random().nextInt(6)),
      'timeSpent': List.generate(365, (i) => 55 + (i % 30) + Random().nextInt(45)),
    },
    'Tot timpul': {
      'correct': List.generate(730, (i) => 25 + (i % 30) + Random().nextInt(20)),
      'incorrect': List.generate(730, (i) => 5 + Random().nextInt(7)),
      'timeSpent': List.generate(730, (i) => 60 + (i % 30) + Random().nextInt(50)),
    },
  };

  @override
  void initState() {
    super.initState();
    _pathController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _pathAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pathController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pathController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Widget _buildBarChart() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final chartWidth = screenWidth - 16;
    final chartHeight = screenHeight * 0.2;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: chartWidth,
          height: chartHeight + 40,
          child: CustomPaint(
            painter: ChartPainter(_pathAnimation, _statsData[_selectedPeriod]!, _selectedPeriod),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPeriodButton('Azi'),
                const SizedBox(width: 8),
                _buildPeriodButton('Ieri'),
                const SizedBox(width: 8),
                _buildPeriodButton('Ultimele 3 zile'),
                const SizedBox(width: 8),
                _buildPeriodButton('Ultima săptămână'),
                const SizedBox(width: 8),
                _buildPeriodButton('Ultima lună'),
                const SizedBox(width: 8),
                _buildPeriodButton('Ultimele 2 luni'),
                const SizedBox(width: 8),
                _buildPeriodButton('Ultimele 3 luni'),
                const SizedBox(width: 8),
                _buildPeriodButton('Ultimele 5 luni'),
                const SizedBox(width: 8),
                _buildPeriodButton('Ultimele 7 luni'),
                const SizedBox(width: 8),
                _buildPeriodButton('Ultimele 9 luni'),
                const SizedBox(width: 8),
                _buildPeriodButton('Ultimul an'),
                const SizedBox(width: 8),
                _buildPeriodButton('Tot timpul'),
                const SizedBox(width: 16),
              ],
            ),
          ),
          Positioned(
            right: 0,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.0), Colors.white],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
          _pathController.forward(from: 0);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          border: Border.all(color: Colors.grey[300]!, width: 1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Text(
          period,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSummary() {
    final data = _statsData[_selectedPeriod]!;
    final totalCorrect = data['correct']!.reduce((a, b) => a + b);
    final totalIncorrect = data['incorrect']!.reduce((a, b) => a + b);
    final totalTime = data['timeSpent']!.reduce((a, b) => a + b);
    final accuracy = (totalCorrect / (totalCorrect + totalIncorrect) * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(child: _buildStatCard('Corect', '$totalCorrect', Colors.greenAccent)),
          Flexible(child: _buildStatCard('Incorect', '$totalIncorrect', Colors.redAccent)),
          Flexible(child: _buildStatCard('Precizie', '$accuracy%', Colors.blueAccent)),
          Flexible(child: _buildStatCard('Timp', '${totalTime}m', Colors.purpleAccent)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _glowAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.montserrat(fontSize: 10, color: Colors.black87),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instrumente',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildToolButton('Raport detaliat', Icons.analytics, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Se generează raport detaliat...')),
                );
              }),
              _buildToolButton('Exportă PDF', Icons.picture_as_pdf, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Se exportă în PDF...')),
                );
              }),
              _buildToolButton('Compară', Icons.compare_arrows, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Se compară cu perioadele anterioare...')),
                );
              }),
              _buildToolButton('Tendințe', Icons.trending_up, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Se afișează tendințele de performanță...')),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!, width: 1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 4,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black87, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Statistici',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
          _buildFilterSection(),
          _buildBarChart(),
          _buildStatsSummary(),
          _buildToolSection(),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  final Animation<double> animation;
  final Map<String, List<int>> data;
  final String period;

  ChartPainter(this.animation, this.data, this.period) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Grid lines with 3px padding
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;
    for (int i = 0; i < 5; i++) {
      double y = size.height * (1 - (i + 1) / 6) - 20;
      canvas.drawLine(
        Offset(40, y),
        Offset(size.width - 3, y),
        gridPaint,
      );
    }

    // Normalize data
    final correct = data['correct']!;
    final incorrect = data['incorrect']!;
    final maxValue = [
      ...correct,
      ...incorrect,
    ].reduce((a, b) => a > b ? a : b);
    final normalizedCorrect = correct.map((v) => v / maxValue).toList();
    final normalizedIncorrect = incorrect.map((v) => v / maxValue).toList();

    // Determine number of labels based on period
    int numPoints = correct.length;
    List<String> xLabels;
    if (numPoints == 1) {
      xLabels = [period == 'Azi' ? 'Azi' : 'Ieri'];
    } else if (numPoints == 3) {
      xLabels = ['Zi 1', 'Zi 2', 'Zi 3'];
    } else {
      xLabels = ['Lun', 'Mar', 'Mie', 'Joi', 'Vin', 'Sâm', 'Dum'];
      if (numPoints > 7) {
        xLabels = List.generate(numPoints, (i) => 'Zi ${i + 1}');
      }
    }

    // Y-axis labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i <= 5; i++) {
      final value = (maxValue * (i / 5)).round();
      textPainter.text = TextSpan(
        text: value.toString(),
        style: GoogleFonts.montserrat(fontSize: 10, color: Colors.black87),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, size.height * (1 - i / 5) - 25));
    }

    // X-axis labels
    for (int i = 0; i < numPoints; i++) {
      textPainter.text = TextSpan(
        text: xLabels[i % xLabels.length],
        style: GoogleFonts.montserrat(fontSize: 10, color: Colors.black87),
      );
      textPainter.layout();
      final x = (i / (numPoints - 1)) * (size.width - 46) + 40;
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - 15));
    }

    // Path 1: Correct answers
    final path1 = Path();
    for (int i = 0; i < numPoints; i++) {
      final x = (i / (numPoints - 1)) * (size.width - 46) + 40;
      final y = (size.height - 40) * (1 - normalizedCorrect[i]) + 3;
      if (i == 0) {
        path1.moveTo(x, y);
      } else {
        final prevX = ((i - 1) / (numPoints - 1)) * (size.width - 46) + 40;
        final prevY = (size.height - 40) * (1 - normalizedCorrect[i - 1]) + 3;
        final controlX1 = prevX + (x - prevX) / 3;
        final controlY1 = prevY;
        final controlX2 = x - (x - prevX) / 3;
        final controlY2 = y;
        path1.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }
    }

    final path1Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        colors: [
          Colors.greenAccent,
          Colors.lightGreen,
          Colors.green,
          Colors.teal,
          Colors.lime,
        ],
        stops: [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path1Metrics = path1.computeMetrics().first;
    final path1Length = path1Metrics.length;
    final path1Dash = Path();
    double dashLength = path1Length * animation.value;
    path1Dash.addPath(path1Metrics.extractPath(0, dashLength), Offset.zero);

    canvas.drawPath(path1Dash, path1Paint);

    // Path 2: Incorrect answers
    final path2 = Path();
    for (int i = 0; i < numPoints; i++) {
      final x = (i / (numPoints - 1)) * (size.width - 46) + 40;
      final y = (size.height - 40) * (1 - normalizedIncorrect[i]) + 3;
      if (i == 0) {
        path2.moveTo(x, y);
      } else {
        final prevX = ((i - 1) / (numPoints - 1)) * (size.width - 46) + 40;
        final prevY = (size.height - 40) * (1 - normalizedIncorrect[i - 1]) + 3;
        final controlX1 = prevX + (x - prevX) / 3;
        final controlY1 = prevY;
        final controlX2 = x - (x - prevX) / 3;
        final controlY2 = y;
        path2.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      }
    }

    final path2Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        colors: [
          Colors.redAccent,
          Colors.pink,
          Colors.red,
          Colors.deepOrange,
          Colors.orange,
        ],
        stops: [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path2Metrics = path2.computeMetrics().first;
    final path2Length = path2Metrics.length;
    final path2Dash = Path();
    dashLength = path2Length * animation.value;
    path2Dash.addPath(path2Metrics.extractPath(0, dashLength), Offset.zero);

    canvas.drawPath(path2Dash, path2Paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}