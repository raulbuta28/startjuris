import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class Sparkle extends StatelessWidget {
  final double size;
  final Color color;
  final double angle;

  const Sparkle({
    Key? key,
    required this.size,
    required this.color,
    required this.angle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: CustomPaint(
        size: Size(size, size),
        painter: SparklePainter(color: color),
      ),
    );
  }
}

class SparklePainter extends CustomPainter {
  final Color color;

  SparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final center = size.width / 2;
    final pointLength = size.width / 2;

    // Draw a star shape
    for (var i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2);
      final point = Offset(
        center + math.cos(angle) * pointLength,
        center + math.sin(angle) * pointLength,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SparklePainter oldDelegate) => color != oldDelegate.color;
}

class DateExamene extends StatefulWidget {
  const DateExamene({super.key});

  @override
  State<DateExamene> createState() => _DateExameneState();
}

class _DateExameneState extends State<DateExamene> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedExam = 'INM';
  int _selectedYear = DateTime.now().year;

  final Map<String, Map<String, dynamic>> examData = {
    'INM': {
      'title': 'Admitere INM & Magistratură',
      'color': const Color(0xFF6200EA),
      'years': {
        2020: {'candidates': 2400, 'spots': 280, 'success_rate': 0.15, 'average': 8.11},
        2021: {'candidates': 2300, 'spots': 290, 'success_rate': 0.16, 'average': 8.22},
        2022: {'candidates': 2200, 'spots': 300, 'success_rate': 0.17, 'average': 8.33},
        2023: {'candidates': 2100, 'spots': 310, 'success_rate': 0.18, 'average': 8.44},
        2024: {'candidates': 2000, 'spots': 320, 'success_rate': 0.19, 'average': 8.55},
        2025: {'candidates': 1900, 'spots': 330, 'success_rate': 0.20, 'average': 8.66},
      },
      'nextExam': {
        'date': DateTime(2025, 9, 30),
        'stages': [
          {'name': 'Înscrieri', 'date': 'August 2025'},
          {'name': 'Proba Scrisă', 'date': '30 Septembrie 2025'},
          {'name': 'Interviu', 'date': 'Octombrie 2025'},
          {'name': 'Rezultate', 'date': 'Noiembrie 2025'},
        ],
      },
    },
    'Barou': {
      'title': 'Admitere Barou',
      'color': const Color(0xFF00BFA5),
      'years': {
        2020: {'candidates': 2400, 'spots': 380, 'success_rate': 0.25, 'average': 7.30},
        2021: {'candidates': 2350, 'spots': 390, 'success_rate': 0.26, 'average': 7.40},
        2022: {'candidates': 2300, 'spots': 400, 'success_rate': 0.27, 'average': 7.50},
        2023: {'candidates': 2250, 'spots': 410, 'success_rate': 0.28, 'average': 7.60},
        2024: {'candidates': 2200, 'spots': 420, 'success_rate': 0.29, 'average': 7.70},
        2025: {'candidates': 2150, 'spots': 430, 'success_rate': 0.30, 'average': 7.80},
      },
      'nextExam': {
        'date': DateTime(2025, 9, 15),
        'stages': [
          {'name': 'Înscrieri', 'date': 'August 2025'},
          {'name': 'Examen Scris', 'date': '15 Septembrie 2025'},
          {'name': 'Rezultate', 'date': 'Octombrie 2025'},
        ],
      },
    },
    'INR': {
      'title': 'Admitere INR',
      'color': const Color(0xFFD500F9),
      'years': {
        2020: {'candidates': 1600, 'spots': 230, 'success_rate': 0.20, 'average': 8.30},
        2021: {'candidates': 1550, 'spots': 240, 'success_rate': 0.21, 'average': 8.40},
        2022: {'candidates': 1500, 'spots': 250, 'success_rate': 0.22, 'average': 8.50},
        2023: {'candidates': 1450, 'spots': 260, 'success_rate': 0.23, 'average': 8.60},
        2024: {'candidates': 1400, 'spots': 270, 'success_rate': 0.24, 'average': 8.70},
        2025: {'candidates': 1350, 'spots': 280, 'success_rate': 0.25, 'average': 8.80},
      },
      'nextExam': {
        'date': DateTime(2025, 10, 15),
        'stages': [
          {'name': 'Înscrieri', 'date': 'Septembrie 2025'},
          {'name': 'Proba Scrisă', 'date': '15 Octombrie 2025'},
          {'name': 'Interviu', 'date': 'Noiembrie 2025'},
          {'name': 'Rezultate', 'date': 'Decembrie 2025'},
        ],
      },
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: examData.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedExam = examData.keys.elementAt(_tabController.index);
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: Text(
          'Date Examene',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Statistici și date importante',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black54,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: examData[_selectedExam]!['color'] as Color,
              ),
              tabs: examData.keys.map((exam) => 
                Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(exam),
                  ),
                )
              ).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: examData.keys.map((exam) => _buildExamContent(exam)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamContent(String exam) {
    final data = examData[exam]!;
    final years = (data['years'] as Map<int, Map<String, dynamic>>).keys.toList()..sort();
    final currentYearData = data['years'][_selectedYear] as Map<String, dynamic>;
    final nextExam = data['nextExam'] as Map<String, dynamic>;
    final color = data['color'] as Color;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        // Next exam card
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Următorul Examen',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.event, color: color),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMMM yyyy', 'ro').format(nextExam['date'] as DateTime),
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Etape:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  (nextExam['stages'] as List).length,
                  (index) {
                    final stage = (nextExam['stages'] as List)[index] as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  stage['name'] as String,
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                                Text(
                                  stage['date'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Year selector
        Container(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: years.length,
            itemBuilder: (context, index) {
              final year = years[index];
              final isSelected = year == _selectedYear;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedYear = year),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? color : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        year.toString(),
                        style: GoogleFonts.poppins(
                          color: isSelected ? Colors.white : color,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // Statistics for selected year
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistici $_selectedYear',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildStatRow(
                  'Candidați',
                  currentYearData['candidates'].toString(),
                  Icons.people,
                  color,
                ),
                const SizedBox(height: 16),
                _buildStatRow(
                  'Locuri disponibile',
                  currentYearData['spots'].toString(),
                  Icons.chair,
                  color,
                ),
                const SizedBox(height: 16),
                _buildStatRow(
                  'Rată de succes',
                  '${(currentYearData['success_rate'] * 100).toStringAsFixed(1)}%',
                  Icons.trending_up,
                  color,
                ),
                const SizedBox(height: 16),
                _buildStatRow(
                  'Media',
                  currentYearData['average'].toStringAsFixed(2),
                  Icons.grade,
                  color,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Trends chart
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evoluție Candidați și Locuri',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.black12,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  years[value.toInt()].toString(),
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                              );
                            },
                            interval: 1,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: GoogleFonts.poppins(fontSize: 12),
                              );
                            },
                            interval: 500,
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        // Candidates line
                        LineChartBarData(
                          spots: List.generate(years.length, (index) {
                            final year = years[index];
                            final yearData = data['years'][year] as Map<String, dynamic>;
                            return FlSpot(
                              index.toDouble(),
                              yearData['candidates'].toDouble(),
                            );
                          }),
                          isCurved: true,
                          color: color,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                        ),
                        // Spots line
                        LineChartBarData(
                          spots: List.generate(years.length, (index) {
                            final year = years[index];
                            final yearData = data['years'][year] as Map<String, dynamic>;
                            return FlSpot(
                              index.toDouble(),
                              yearData['spots'].toDouble(),
                            );
                          }),
                          isCurved: true,
                          color: color.withOpacity(0.5),
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('Candidați', color),
                    const SizedBox(width: 24),
                    _buildLegendItem('Locuri disponibile', color.withOpacity(0.5)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double animation;

  _BackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1A237E),
          const Color(0xFF0D47A1),
          const Color(0xFF1565C0),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, paint);

    final particlePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (var i = 0.0; i < 50.0; i += 1.0) {
      final x = (size.width * 0.1) +
          (size.width * 0.8 * ((i * pi + animation * 2.0 * pi) % 1.0));
      final y = (size.height * 0.1) +
          (size.height * 0.8 * sin((i * pi + animation * 2.0 * pi) * 2.0));
      final radius = 2.0 + 2.0 * sin((i * pi + animation * 2.0 * pi) * 3.0);
      canvas.drawCircle(
        Offset(x, y),
        radius,
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) =>
      animation != oldDelegate.animation;
}