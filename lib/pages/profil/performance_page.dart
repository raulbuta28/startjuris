import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

class PerformancePage extends StatefulWidget {
  const PerformancePage({super.key});

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data - în producție, acestea vor fi înlocuite cu date reale
  final Map<String, int> _grileStats = {
    'total': 500,
    'corecte': 375,
    'gresite': 125,
  };

  final Map<String, double> _materieAccuracy = {
    'Drept civil': 85.5,
    'Drept procesual civil': 78.2,
    'Drept penal': 92.1,
    'Drept procesual penal': 88.7,
  };

  final Map<String, List<double>> _weeklyProgress = {
    'Luni': [85, 120],
    'Marți': [92, 150],
    'Miercuri': [78, 90],
    'Joi': [95, 180],
    'Vineri': [88, 140],
    'Sâmbătă': [91, 160],
    'Duminică': [87, 130],
  };

  final List<Map<String, dynamic>> _matchHistory = [
    {'result': 'Victorie', 'score': '15-12', 'opponent': 'Maria I.', 'date': '2024-03-20'},
    {'result': 'Înfrângere', 'score': '13-15', 'opponent': 'Alex P.', 'date': '2024-03-19'},
    {'result': 'Victorie', 'score': '15-10', 'opponent': 'Andrei M.', 'date': '2024-03-18'},
    {'result': 'Victorie', 'score': '15-14', 'opponent': 'Elena R.', 'date': '2024-03-17'},
    {'result': 'Înfrângere', 'score': '12-15', 'opponent': 'Cristian D.', 'date': '2024-03-16'},
  ];

  final List<Map<String, dynamic>> _weakestChapters = [
    {
      'chapter': 'Contracte speciale',
      'subject': 'Drept civil',
      'accuracy': 65.5,
      'totalQuestions': 50,
    },
    {
      'chapter': 'Procedura executării silite',
      'subject': 'Drept procesual civil',
      'accuracy': 68.2,
      'totalQuestions': 45,
    },
    {
      'chapter': 'Infracțiuni contra patrimoniului',
      'subject': 'Drept penal',
      'accuracy': 70.8,
      'totalQuestions': 60,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;
    
    return Material(
      color: Colors.white,
      child: SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: Column(
          children: [
            SizedBox(height: topPadding),
            Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildOverallProgress(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: false,
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Theme.of(context).primaryColor,
                      indicatorWeight: 3,
                      labelStyle: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.analytics_outlined),
                          text: 'General',
                          height: 60,
                        ),
                        Tab(
                          icon: Icon(Icons.school_outlined),
                          text: 'Materii',
                          height: 60,
                        ),
                        Tab(
                          icon: Icon(Icons.trending_up_outlined),
                          text: 'Progres',
                          height: 60,
                        ),
                        Tab(
                          icon: Icon(Icons.emoji_events_outlined),
                          text: 'Meciuri',
                          height: 60,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  _buildGeneralStats(),
                  _buildSubjectStats(),
                  _buildProgressStats(),
                  _buildMatchStats(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildScoreCard(
                  'Scor General',
                  '${(_grileStats['corecte']! / _grileStats['total']! * 100).toStringAsFixed(1)}%',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildScoreCard(
                  'Grile Rezolvate',
                  _grileStats['total'].toString(),
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildScoreCard(
                  'Medie Timp/Grilă',
                  '2:30',
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildScoreCard(
                  'Meciuri Câștigate',
                  '75%',
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              minWidth: constraints.maxWidth,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Distribuție Răspunsuri'),
                    const SizedBox(height: 16),
                    Container(
                      height: 250,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: _grileStats['corecte']!.toDouble(),
                              title: 'Corecte\n${_grileStats['corecte']}',
                              color: Colors.green,
                              radius: 100,
                              titleStyle: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: _grileStats['gresite']!.toDouble(),
                              title: 'Greșite\n${_grileStats['gresite']}',
                              color: Colors.red,
                              radius: 90,
                              titleStyle: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                          centerSpaceRadius: 0,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Capitole cu Performanță Scăzută'),
                    const SizedBox(height: 16),
                    ..._weakestChapters.map((chapter) => _buildWeakChapterCard(chapter)).toList(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Recomandări'),
                    const SizedBox(height: 16),
                    _buildRecommendationCard(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubjectStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              minWidth: constraints.maxWidth,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Performanță pe Materii'),
                    const SizedBox(height: 16),
                    Container(
                      height: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          barGroups: _materieAccuracy.entries.map((entry) {
                            final index = _materieAccuracy.keys.toList().indexOf(entry.key);
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value,
                                  color: _getAccuracyColor(entry.value),
                                  width: 20,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            );
                          }).toList(),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final subjects = _materieAccuracy.keys.toList();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      subjects[value.toInt()].split(' ')[1],
                                      style: GoogleFonts.montserrat(fontSize: 12),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt()}%',
                                    style: GoogleFonts.montserrat(fontSize: 12),
                                  );
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Detalii Materii'),
                    const SizedBox(height: 16),
                    ..._materieAccuracy.entries.map(
                      (entry) => _buildSubjectDetailCard(
                        entry.key,
                        entry.value,
                        _getSubjectDetails(entry.key),
                      ),
                    ).toList(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              minWidth: constraints.maxWidth,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Progres Săptămânal'),
                    const SizedBox(height: 16),
                    Container(
                      height: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: _weeklyProgress.entries.map((entry) {
                                final index = _weeklyProgress.keys.toList().indexOf(entry.key);
                                return FlSpot(index.toDouble(), entry.value[0]);
                              }).toList(),
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blue.withOpacity(0.1),
                              ),
                            ),
                            LineChartBarData(
                              spots: _weeklyProgress.entries.map((entry) {
                                final index = _weeklyProgress.keys.toList().indexOf(entry.key);
                                return FlSpot(index.toDouble(), entry.value[1]);
                              }).toList(),
                              isCurved: true,
                              color: Colors.green,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.green.withOpacity(0.1),
                              ),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final days = _weeklyProgress.keys.toList();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      days[value.toInt()].substring(0, 3),
                                      style: GoogleFonts.montserrat(fontSize: 12),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: GoogleFonts.montserrat(fontSize: 12),
                                  );
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Comparație cu Media'),
                    const SizedBox(height: 16),
                    _buildComparisonCard(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMatchStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              minWidth: constraints.maxWidth,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Istoric Meciuri Recente'),
                    const SizedBox(height: 16),
                    ..._matchHistory.map((match) => _buildMatchCard(match)).toList(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Statistici Meciuri'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMatchStat('Total Meciuri', '50'),
                              _buildMatchStat('Victorii', '38'),
                              _buildMatchStat('Înfrângeri', '12'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    value: 38,
                                    title: 'Victorii\n38',
                                    color: Colors.green,
                                    radius: 100,
                                    titleStyle: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: 12,
                                    title: 'Înfrângeri\n12',
                                    color: Colors.red,
                                    radius: 90,
                                    titleStyle: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                                centerSpaceRadius: 0,
                                sectionsSpace: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreCard(String title, String value, Color color) {
    return GestureDetector(
      onTap: () => _showScoreDetails(title, value, color),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScoreDetails(String title, String value, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildScoreDetailsContent(title),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDetailsContent(String cardType) {
    switch (cardType) {
      case 'Scor General':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailSection(
              'Evoluție Săptămânală',
              'Scorul tău a crescut cu 5.2% față de săptămâna trecută',
              Icons.trending_up,
            ),
            _buildDetailSection(
              'Distribuție pe Materii',
              'Civil: 87%, Penal: 92%, Procedură: 83%',
              Icons.pie_chart,
            ),
            _buildDetailSection(
              'Comparație cu Media',
              'Ești în top 15% dintre utilizatori',
              Icons.group,
            ),
          ],
        );
      
      case 'Grile Rezolvate':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailSection(
              'Distribuție pe Zile',
              'L: 50, M: 45, M: 60, J: 40, V: 55, S: 30, D: 20',
              Icons.calendar_today,
            ),
            _buildDetailSection(
              'Timp Total de Studiu',
              '32 ore în ultima săptămână',
              Icons.access_time,
            ),
            _buildDetailSection(
              'Eficiență',
              '85% răspunsuri corecte din prima încercare',
              Icons.speed,
            ),
          ],
        );
      
      case 'Medie Timp/Grilă':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailSection(
              'Distribuție Timp',
              'Sub 2 min: 40%, 2-3 min: 35%, Peste 3 min: 25%',
              Icons.timer,
            ),
            _buildDetailSection(
              'Materii cu Timp Optim',
              'Civil și Penal - media sub 2:30 minute',
              Icons.check_circle,
            ),
            _buildDetailSection(
              'Arii de Îmbunătățit',
              'Procedură Civilă - media peste 3 minute',
              Icons.warning,
            ),
          ],
        );
      
      case 'Meciuri Câștigate':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailSection(
              'Ultimele 10 Meciuri',
              'Victorii: 8, Înfrângeri: 2',
              Icons.emoji_events,
            ),
            _buildDetailSection(
              'Adversari Frecvenți',
              'Maria I. (5 meciuri), Alex P. (3 meciuri)',
              Icons.people,
            ),
            _buildDetailSection(
              'Materii Preferate',
              'Civil: 80% victorii, Penal: 70% victorii',
              Icons.star,
            ),
          ],
        );
      
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDetailSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: Colors.grey[700]),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildWeakChapterCard(Map<String, dynamic> chapter) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chapter['chapter'],
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              chapter['subject'],
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: chapter['accuracy'] / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                chapter['accuracy'] < 70 ? Colors.red : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Acuratețe: ${chapter['accuracy']}% din ${chapter['totalQuestions']} întrebări',
              style: GoogleFonts.montserrat(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recomandări pentru Îmbunătățire',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecommendationItem(
              'Focusează-te pe capitolele cu performanță scăzută',
              Icons.track_changes,
              Colors.blue,
            ),
            _buildRecommendationItem(
              'Mărește timpul de studiu pentru Drept procesual civil',
              Icons.timer,
              Colors.green,
            ),
            _buildRecommendationItem(
              'Participă la mai multe meciuri pentru practică',
              Icons.people,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectDetailCard(String subject, double accuracy, Map<String, dynamic> details) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem('Total Grile', details['total'].toString()),
                _buildDetailItem('Timp Mediu', details['avgTime']),
                _buildDetailItem('Tendință', details['trend']),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: accuracy / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getAccuracyColor(accuracy)),
            ),
            const SizedBox(height: 8),
            Text(
              'Acuratețe: ${accuracy.toStringAsFixed(1)}%',
              style: GoogleFonts.montserrat(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildComparisonItem('Scor General', 85.5, 78.2),
            const SizedBox(height: 16),
            _buildComparisonItem('Timp pe Grilă', 2.5, 3.2),
            const SizedBox(height: 16),
            _buildComparisonItem('Grile pe Zi', 25, 20),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonItem(String label, double userValue, double avgValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu',
                    style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey),
                  ),
                  LinearProgressIndicator(
                    value: userValue / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  Text(
                    userValue.toString(),
                    style: GoogleFonts.montserrat(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Media',
                    style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey),
                  ),
                  LinearProgressIndicator(
                    value: avgValue / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  Text(
                    avgValue.toString(),
                    style: GoogleFonts.montserrat(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    final bool isVictory = match['result'] == 'Victorie';
    final Color resultColor = isVictory ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: resultColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match['result'],
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: resultColor,
                    ),
                  ),
                  Text(
                    'vs ${match['opponent']}',
                    style: GoogleFonts.montserrat(fontSize: 14),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  match['score'],
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  match['date'],
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 90) return Colors.green;
    if (accuracy >= 80) return Colors.blue;
    if (accuracy >= 70) return Colors.orange;
    return Colors.red;
  }

  Map<String, dynamic> _getSubjectDetails(String subject) {
    // Mock data - în producție, acestea vor fi înlocuite cu date reale
    return {
      'total': 150,
      'avgTime': '2:45',
      'trend': '+5%',
    };
  }
}