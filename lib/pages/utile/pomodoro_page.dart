import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/utils_provider.dart';
import '../../translations/ro.dart';
import 'dart:async';
import 'dart:math' as math;

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _animationController;
  int _currentQuoteIndex = 0;
  Timer? _quoteTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _startQuoteRotation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _quoteTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startQuoteRotation() {
    _quoteTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() {
        _currentQuoteIndex = (_currentQuoteIndex + 1) % RomanianTranslations.motivationalQuotes.length;
      });
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final provider = Provider.of<UtilsProvider>(context, listen: false);
      if (provider.isTimerRunning) {
        if (provider.remainingTime > Duration.zero) {
          provider.tickTimer();
        } else {
          if (provider.isBreak) {
            provider.onBreakComplete();
          } else {
            provider.onPomodoroComplete();
          }
        }
      }
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _showConfirmationDialog(BuildContext context, String action, VoidCallback onConfirm) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          RomanianTranslations.strings['confirm']!,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          action,
          style: GoogleFonts.poppins(),
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
              onConfirm();
              Navigator.pop(context);
            },
            child: Text(
              RomanianTranslations.strings['confirm']!,
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
          RomanianTranslations.strings['pomodoro_title']!,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: Consumer<UtilsProvider>(
        builder: (context, provider, _) {
          final isRunning = provider.isTimerRunning;
          final remainingTime = provider.remainingTime;
          final isBreak = provider.isBreak;
          final completedSessions = provider.completedSessions;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isBreak ? Colors.green.shade100 : Colors.blue.shade100,
                  isBreak ? Colors.green.shade50 : Colors.blue.shade50,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isBreak ? 
                    RomanianTranslations.strings['break_time']! : 
                    RomanianTranslations.strings['focus_time']!,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: isBreak ? Colors.green : Colors.blue,
                  ),
                ).animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.2, end: 0),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        tween: Tween(
                          begin: 0,
                          end: remainingTime.inSeconds / 
                            (isBreak ? 
                              (completedSessions % provider.pomodoroSettings.sessionsBeforeLongBreak == 0 ?
                                provider.pomodoroSettings.longBreakDuration :
                                provider.pomodoroSettings.shortBreakDuration) * 60 :
                              provider.pomodoroSettings.workDuration * 60),
                        ),
                        builder: (context, value, _) => CircularProgressIndicator(
                          value: value,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[300],
                          color: isBreak ? Colors.green : Colors.blue,
                        ),
                      ),
                    ),
                    Text(
                      _formatDuration(remainingTime),
                      style: GoogleFonts.poppins(
                        fontSize: 72,
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate(
                      onPlay: (controller) => controller.repeat(),
                    ).shimmer(
                      duration: 2000.ms,
                      color: isBreak ? Colors.green.shade200 : Colors.blue.shade200,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      heroTag: 'reset',
                      onPressed: () => _showConfirmationDialog(
                        context,
                        'Sigur doriți să resetați cronometrul?',
                        () => provider.resetTimer(),
                      ),
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.refresh),
                    ).animate()
                      .scale(duration: 300.ms)
                      .then()
                      .shimmer(duration: 1000.ms),
                    const SizedBox(width: 20),
                    FloatingActionButton.large(
                      heroTag: 'playPause',
                      onPressed: () {
                        if (isRunning) {
                          provider.pauseTimer();
                        } else {
                          provider.startTimer();
                        }
                      },
                      backgroundColor: isRunning ? Colors.orange : Colors.green,
                      child: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                    ).animate()
                      .scale(duration: 300.ms)
                      .then()
                      .shimmer(duration: 1000.ms),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  '${RomanianTranslations.strings['completed_sessions']!}: $completedSessions',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    RomanianTranslations.motivationalQuotes[_currentQuoteIndex],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                    ),
                  ).animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final provider = Provider.of<UtilsProvider>(context, listen: false);
    final settings = provider.pomodoroSettings;
    
    int workDuration = settings.workDuration;
    int shortBreakDuration = settings.shortBreakDuration;
    int longBreakDuration = settings.longBreakDuration;
    int sessionsBeforeLongBreak = settings.sessionsBeforeLongBreak;
    bool autoStartBreaks = settings.autoStartBreaks;
    bool autoStartPomodoros = settings.autoStartPomodoros;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          RomanianTranslations.strings['settings']!,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDurationField(
                  RomanianTranslations.strings['work_duration']!,
                  workDuration,
                  (value) => setState(() => workDuration = value),
                ),
                const SizedBox(height: 16),
                _buildDurationField(
                  RomanianTranslations.strings['short_break']!,
                  shortBreakDuration,
                  (value) => setState(() => shortBreakDuration = value),
                ),
                const SizedBox(height: 16),
                _buildDurationField(
                  RomanianTranslations.strings['long_break']!,
                  longBreakDuration,
                  (value) => setState(() => longBreakDuration = value),
                ),
                const SizedBox(height: 16),
                _buildDurationField(
                  RomanianTranslations.strings['sessions_before_long_break']!,
                  sessionsBeforeLongBreak,
                  (value) => setState(() => sessionsBeforeLongBreak = value),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(
                    RomanianTranslations.strings['auto_start_breaks']!,
                    style: GoogleFonts.poppins(),
                  ),
                  value: autoStartBreaks,
                  onChanged: (value) => setState(() => autoStartBreaks = value),
                ),
                SwitchListTile(
                  title: Text(
                    RomanianTranslations.strings['auto_start_pomodoros']!,
                    style: GoogleFonts.poppins(),
                  ),
                  value: autoStartPomodoros,
                  onChanged: (value) => setState(() => autoStartPomodoros = value),
                ),
              ],
            ),
          ),
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
              provider.updatePomodoroSettings(PomodoroSettings(
                workDuration: workDuration,
                shortBreakDuration: shortBreakDuration,
                longBreakDuration: longBreakDuration,
                sessionsBeforeLongBreak: sessionsBeforeLongBreak,
                autoStartBreaks: autoStartBreaks,
                autoStartPomodoros: autoStartPomodoros,
              ));
              Navigator.pop(context);
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

  Widget _buildDurationField(String label, int value, ValueChanged<int> onChanged) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      controller: TextEditingController(text: value.toString()),
      onChanged: (text) {
        final newValue = int.tryParse(text);
        if (newValue != null && newValue > 0) {
          onChanged(newValue);
        }
      },
    );
  }
} 