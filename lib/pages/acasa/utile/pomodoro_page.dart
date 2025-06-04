import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../backend/providers/auth_provider.dart';
import '../../../services/user_utils_service.dart';
import 'models/pomodoro_settings.dart';
import 'models/pomodoro_stats.dart';

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> with TickerProviderStateMixin {
  late PomodoroSettings _settings;
  late PomodoroStats _stats;
  Timer? _timer;
  bool _isRunning = false;
  bool _isBreak = false;
  int _currentCycle = 0;
  int _minutes = 25;
  int _seconds = 0;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _loadData();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _bounceController.repeat(reverse: true);
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _settings = PomodoroSettings.fromJson(
        jsonDecode(prefs.getString('pomodoro_settings') ?? '{}')
      );
      _stats = PomodoroStats.fromJson(
        jsonDecode(prefs.getString('pomodoro_stats') ?? '{}')
      );
      _minutes = _settings.workDuration;
    });

    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated && auth.token != null) {
      final service = UserUtilsService(auth.token!);
      final data = await service.fetchUtils();
      if (data['pomodoro_settings'] != null) {
        _settings = PomodoroSettings.fromJson(
            data['pomodoro_settings'] as Map<String, dynamic>);
      }
      if (data['pomodoro_stats'] != null) {
        _stats = PomodoroStats.fromJson(
            data['pomodoro_stats'] as Map<String, dynamic>);
      }
      setState(() {
        _minutes = _settings.workDuration;
      });
    }
  }

  Future<void> _saveData() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pomodoro_settings', jsonEncode(_settings.toJson()));
    await prefs.setString('pomodoro_stats', jsonEncode(_stats.toJson()));

    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated && auth.token != null) {
      final service = UserUtilsService(auth.token!);
      await service.saveUtils({
        'pomodoro_settings': _settings.toJson(),
        'pomodoro_stats': _stats.toJson(),
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          if (_minutes > 0) {
            _minutes--;
            _seconds = 59;
          } else {
            timer.cancel();
            _isRunning = false;
            _handleSessionComplete();
          }
        }
      });
    });
    setState(() {
      _isRunning = true;
    });
  }

  void _handleSessionComplete() {
    if (!mounted) return;
    if (!_isBreak) {
      _stats = _stats.copyWith(
        totalFocusMinutes: _stats.totalFocusMinutes + _settings.workDuration,
        completedSessions: _stats.completedSessions + 1,
      );
      _stats.addFocusMinutes(_settings.workDuration);
      _currentCycle++;
      
      if (_currentCycle >= _settings.cyclesBeforeLongBreak) {
        _minutes = _settings.longBreakDuration;
        _currentCycle = 0;
        _stats = _stats.copyWith(completedCycles: _stats.completedCycles + 1);
      } else {
        _minutes = _settings.shortBreakDuration;
      }
      _isBreak = true;
    } else {
      _minutes = _settings.workDuration;
      _isBreak = false;
    }
    _seconds = 0;
    _saveData();
    _showSessionCompleteDialog();
  }

  void _showSessionCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          _isBreak ? 'Pauză completă!' : 'Sesiune completă!',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_isBreak 
              ? 'Este timpul să revii la studiu.' 
              : 'Este timpul pentru o pauză bine meritată!'),
            const SizedBox(height: 16),
            if (!_isBreak) ...[
              const Text(
                'Statistici sesiune:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildStatRow(
                'Timp total focusat',
                '${_stats.totalFocusMinutes} minute',
                Icons.timer,
              ),
              _buildStatRow(
                'Sesiuni complete',
                '${_stats.completedSessions}',
                Icons.check_circle,
              ),
              _buildStatRow(
                'Cicluri complete',
                '${_stats.completedCycles}',
                Icons.repeat,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_settings.autoStartBreaks && !_isBreak || 
                  _settings.autoStartNextSession && _isBreak) {
                _startTimer();
              }
              if (_isBreak) {
                _showBreakSuggestions();
              }
            },
            child: const Text('Continuă'),
          ),
        ],
      ),
    );
  }

  void _showBreakSuggestions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sugestii pentru pauză',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBreakSuggestion(
                    'Exerciții pentru ochi',
                    'Privește în depărtare timp de 20 secunde',
                    Icons.remove_red_eye,
                  ),
                  _buildBreakSuggestion(
                    'Hidratare',
                    'Bea un pahar cu apă',
                    Icons.water_drop,
                  ),
                  _buildBreakSuggestion(
                    'Mișcare',
                    'Fă câțiva pași sau stretching ușor',
                    Icons.directions_walk,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        PomodoroSettings tempSettings = _settings;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Setări'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDurationSetting(
                    'Durată sesiune',
                    tempSettings.workDuration,
                    (value) => setState(() => tempSettings = tempSettings.copyWith(workDuration: value)),
                    15,
                    60,
                  ),
                  _buildDurationSetting(
                    'Pauză scurtă',
                    tempSettings.shortBreakDuration,
                    (value) => setState(() => tempSettings = tempSettings.copyWith(shortBreakDuration: value)),
                    3,
                    15,
                  ),
                  _buildDurationSetting(
                    'Pauză lungă',
                    tempSettings.longBreakDuration,
                    (value) => setState(() => tempSettings = tempSettings.copyWith(longBreakDuration: value)),
                    15,
                    30,
                  ),
                  _buildDurationSetting(
                    'Sesiuni până la pauza lungă',
                    tempSettings.cyclesBeforeLongBreak,
                    (value) => setState(() => tempSettings = tempSettings.copyWith(cyclesBeforeLongBreak: value)),
                    2,
                    6,
                  ),
                  SwitchListTile(
                    title: const Text('Pornire automată pauze'),
                    value: tempSettings.autoStartBreaks,
                    onChanged: (value) => setState(() => tempSettings = tempSettings.copyWith(autoStartBreaks: value)),
                  ),
                  SwitchListTile(
                    title: const Text('Pornire automată sesiuni'),
                    value: tempSettings.autoStartNextSession,
                    onChanged: (value) => setState(() => tempSettings = tempSettings.copyWith(autoStartNextSession: value)),
                  ),
                  SwitchListTile(
                    title: const Text('Notificări'),
                    value: tempSettings.showNotifications,
                    onChanged: (value) => setState(() => tempSettings = tempSettings.copyWith(showNotifications: value)),
                  ),
                  SwitchListTile(
                    title: const Text('Vibrații'),
                    value: tempSettings.vibrationEnabled,
                    onChanged: (value) => setState(() => tempSettings = tempSettings.copyWith(vibrationEnabled: value)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Anulează'),
              ),
              TextButton(
                onPressed: () {
                  _settings = tempSettings;
                  _saveData();
                  Navigator.pop(context);
                },
                child: const Text('Salvează'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistici'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow(
              'Timp total focusat',
              '${_stats.totalFocusMinutes} minute',
              Icons.timer,
            ),
            _buildStatRow(
              'Sesiuni complete',
              '${_stats.completedSessions}',
              Icons.check_circle,
            ),
            _buildStatRow(
              'Cicluri complete',
              '${_stats.completedCycles}',
              Icons.repeat,
            ),
            _buildStatRow(
              'Timp astăzi',
              '${_stats.getTodayFocusMinutes()} minute',
              Icons.today,
            ),
            _buildStatRow(
              'Serie zilnică',
              '${_stats.dailyStreak} zile',
              Icons.local_fire_department,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Închide'),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSetting(
    String label,
    int value,
    ValueChanged<int> onChanged,
    int min,
    int max,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: max - min,
                label: '$value min',
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
            Text('$value min'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _isBreak ? Colors.green : Colors.blue),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakSuggestion(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_minutes * 60 + _seconds) / 
      (_isBreak ? 
        (_currentCycle >= _settings.cyclesBeforeLongBreak - 1 ? 
          _settings.longBreakDuration : 
          _settings.shortBreakDuration) : 
        _settings.workDuration) / 60;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Metoda Pomodoro',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.black87),
            onPressed: _showStatsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _isBreak ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: (_isBreak ? Colors.green : Colors.blue).withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      _isBreak ? 
                        (_currentCycle >= _settings.cyclesBeforeLongBreak - 1 ? 
                          'Pauză lungă' : 
                          'Pauză scurtă') : 
                        'Concentrare',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _isBreak ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: (_isBreak ? Colors.green : Colors.blue).withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        height: 260,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 15,
                          backgroundColor: (_isBreak ? Colors.green : Colors.blue).withOpacity(0.1),
                          color: _isBreak ? Colors.green : Colors.blue,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(
                        icon: _isRunning ? Icons.pause : Icons.play_arrow,
                        color: _isBreak ? Colors.green : Colors.blue,
                        onPressed: _isRunning ? () {
                          _timer?.cancel();
                          setState(() => _isRunning = false);
                        } : _startTimer,
                      ),
                      const SizedBox(width: 20),
                      _buildControlButton(
                        icon: Icons.refresh,
                        color: Colors.red,
                        onPressed: () {
                          _timer?.cancel();
                          setState(() {
                            _minutes = _settings.workDuration;
                            _seconds = 0;
                            _isRunning = false;
                            _isBreak = false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildStatRow(
                          'Ciclul curent',
                          '${_currentCycle + 1}/${_settings.cyclesBeforeLongBreak}',
                          Icons.repeat,
                        ),
                        const Divider(),
                        _buildStatRow(
                          'Timp astăzi',
                          '${_stats.getTodayFocusMinutes()} minute',
                          Icons.today,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 32),
        onPressed: onPressed,
        padding: const EdgeInsets.all(20),
      ),
    );
  }
} 