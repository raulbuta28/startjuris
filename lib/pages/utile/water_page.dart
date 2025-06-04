import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/utils_provider.dart';
import '../../translations/ro.dart';

class WaterPage extends StatefulWidget {
  const WaterPage({super.key});

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  final List<int> _quickAddAmounts = [100, 200, 300, 500];

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildWaterProgress(BuildContext context, WaterIntake waterIntake) {
    final progress = waterIntake.todayIntake / waterIntake.dailyGoal;
    final displayProgress = (progress * 100).toStringAsFixed(1);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade100,
                Colors.blue.shade50,
              ],
            ),
          ),
        ).animate()
          .scale(duration: 500.ms)
          .then()
          .shimmer(duration: 2000.ms),
        SizedBox(
          width: 180,
          height: 180,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            tween: Tween(begin: 0, end: progress),
            builder: (context, value, _) => CircularProgressIndicator(
              value: value,
              strokeWidth: 15,
              backgroundColor: Colors.blue.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$displayProgress%',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ).animate()
              .fadeIn(duration: 500.ms)
              .scale(delay: 500.ms),
            Text(
              '${waterIntake.todayIntake}/${waterIntake.dailyGoal} ml',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.blue.shade600,
              ),
            ).animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.5, end: 0),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAddButtons(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: _quickAddAmounts.map((amount) {
        return ElevatedButton.icon(
          onPressed: () {
            final provider = Provider.of<UtilsProvider>(context, listen: false);
            provider.addWaterIntake(amount);
            _showSuccessMessage(
              context,
              '${RomanianTranslations.strings['success']!}: +$amount ml',
            );
          },
          icon: const Icon(Icons.water_drop),
          label: Text(
            '+$amount ml',
            style: GoogleFonts.poppins(),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade400,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
        ).animate()
          .fadeIn(duration: 500.ms)
          .scale(delay: 200.ms);
      }).toList(),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, WaterIntake waterIntake) {
    final now = DateTime.now();
    final weekData = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final dayIntake = waterIntake.intakeHistory
          .where((timestamp) {
            final intakeDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
            return intakeDate.year == date.year &&
                intakeDate.month == date.month &&
                intakeDate.day == date.day;
          })
          .length * 200; // Assuming each log is 200ml
      return FlSpot(index.toDouble(), dayIntake.toDouble());
    });

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${(value / 1000).toStringAsFixed(1)}L',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date = now.subtract(Duration(days: 6 - value.toInt()));
                  return Text(
                    '${date.day}/${date.month}',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  );
                },
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
            LineChartBarData(
              spots: weekData,
              isCurved: true,
              color: Colors.blue.shade400,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.shade100.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 800.ms)
      .slideX(begin: 0.2, end: 0);
  }

  void _showSetGoalDialog(BuildContext context) {
    final provider = Provider.of<UtilsProvider>(context, listen: false);
    int newGoal = provider.waterIntake.dailyGoal;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          RomanianTranslations.strings['set_goal']!,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          decoration: InputDecoration(
            labelText: '${RomanianTranslations.strings['daily_goal']!} (ml)',
            labelStyle: GoogleFonts.poppins(),
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          controller: TextEditingController(text: newGoal.toString()),
          onChanged: (value) {
            final parsed = int.tryParse(value);
            if (parsed != null && parsed > 0) {
              newGoal = parsed;
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              RomanianTranslations.strings['cancel']!,
              style: GoogleFonts.poppins(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              provider.setWaterGoal(newGoal);
              Navigator.pop(context);
              _showSuccessMessage(
                context,
                '${RomanianTranslations.strings['success']!}: ${RomanianTranslations.strings['daily_goal']!} $newGoal ml',
              );
            },
            child: Text(
              RomanianTranslations.strings['save']!,
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          RomanianTranslations.strings['water_tracker']!,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSetGoalDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Consumer<UtilsProvider>(
          builder: (context, provider, _) {
            final waterIntake = provider.waterIntake;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildWaterProgress(context, waterIntake),
                  const SizedBox(height: 32),
                  _buildQuickAddButtons(context),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            RomanianTranslations.strings['hydration_tips']!,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Bea un pahar de apă imediat după trezire\n'
                            '• Setează alarme pentru a-ți aminti să bei apă\n'
                            '• Ține mereu o sticlă de apă la îndemână\n'
                            '• Bea un pahar de apă înainte de fiecare masă\n'
                            '• Înlocuiește băuturile carbogazoase cu apă',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statistici Săptămânale',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildWeeklyChart(context, waterIntake),
                        ],
                      ),
                    ),
                  ).animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final provider = Provider.of<UtilsProvider>(context, listen: false);
          provider.resetDailyWaterIntake();
          _showSuccessMessage(
            context,
            RomanianTranslations.strings['reset_day']!,
          );
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.refresh),
      ).animate()
        .scale(duration: 300.ms)
        .then()
        .shimmer(duration: 1000.ms),
    );
  }
} 