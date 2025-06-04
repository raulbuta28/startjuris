import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../pages/backend/providers/auth_provider.dart';
import '../../../services/user_utils_service.dart';
import '../../../providers/utils_provider.dart' as utils;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'models/sleep_settings.dart';
import 'models/sleep_data.dart';
import 'sleep_sounds.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _moonController;
  late AnimationController _starsController;
  late FlutterLocalNotificationsPlugin _notifications;
  final _audioPlayer = AudioPlayer();
  
  // Sleep tracking
  Map<String, SleepData> _sleepHistory = {};
  SleepSettings _settings = SleepSettings(
    bedtime: const TimeOfDay(hour: 22, minute: 0),
    wakeTime: const TimeOfDay(hour: 6, minute: 30),
    enableReminders: true,
    reminderOffset: 30, // minutes before bedtime
    sleepGoal: const Duration(hours: 8),
  );
  
  bool _isLoading = true;
  Timer? _bedtimeTimer;
  int _selectedSoundIndex = -1;
  bool _isPlayingSound = false;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupNotifications();
    _loadData().then((_) {
      if (mounted) {
        _startBedtimeTimer();
      }
    });
  }

  void _initializeControllers() {
    _tabController = TabController(length: 4, vsync: this);
    _moonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _setupNotifications() async {
    _notifications = FlutterLocalNotificationsPlugin();
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _notifications.initialize(initializationSettings);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _settings = SleepSettings.fromJson(
        jsonDecode(prefs.getString('sleep_settings') ?? '{}'),
      );
      final historyJson = jsonDecode(prefs.getString('sleep_history') ?? '{}') as Map<String, dynamic>;
      _sleepHistory = Map.fromEntries(
        historyJson.entries.map((e) => MapEntry(e.key, SleepData.fromJson(e.value as Map<String, dynamic>))),
      );
      _isLoading = false;
    });

    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated && auth.token != null) {
      final service = UserUtilsService(auth.token!);
      final data = await service.fetchUtils();
      if (data['sleep_settings'] != null) {
        _settings = SleepSettings.fromJson(
            data['sleep_settings'] as Map<String, dynamic>);
      }
      if (data['sleep_history'] != null) {
        final h = data['sleep_history'] as Map<String, dynamic>;
        _sleepHistory = h.map((k, v) => MapEntry(k, SleepData.fromJson(v)));
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sleep_settings', jsonEncode(_settings.toJson()));
    await prefs.setString(
      'sleep_history',
      jsonEncode(Map.fromEntries(
        _sleepHistory.entries.map((e) => MapEntry(e.key, e.value.toJson())),
      )),
    );

    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated && auth.token != null) {
      final service = UserUtilsService(auth.token!);
      await service.saveUtils({
        'sleep_settings': _settings.toJson(),
        'sleep_history': _sleepHistory.map((k, v) => MapEntry(k, v.toJson())),
      });
    }
  }

  void _startBedtimeTimer() {
    _bedtimeTimer?.cancel();
    if (_settings.enableReminders) {
      final now = DateTime.now();
      final bedtime = DateTime(
        now.year,
        now.month,
        now.day,
        _settings.bedtime.hour,
        _settings.bedtime.minute,
      );
      
      if (now.isBefore(bedtime)) {
        _bedtimeTimer = Timer(
          bedtime.difference(now) - Duration(minutes: _settings.reminderOffset),
          _showBedtimeReminder,
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _moonController.dispose();
    _starsController.dispose();
    _audioPlayer.dispose();
    _bedtimeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final timeUntilBedtime = _settings.getTimeUntilBedtime();
    final lastNight = _getLastNightSleep();
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade900,
              Colors.indigo.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Somn Sănătos',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: _showSettingsDialog,
                    ),
                  ],
                ),
              ),
              
              // Main Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Sleep Score Card
                    if (lastNight != null)
                      _buildSleepScoreCard(lastNight)
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    // Bedtime Reminder
                    _buildBedtimeCard(timeUntilBedtime)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 200.ms)
                      .slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    // Sleep Stats
                    _buildSleepStatsCard()
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 400.ms)
                      .slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    // Sleep Sounds
                    _buildSleepSoundsCard()
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 600.ms)
                      .slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    // Sleep Tips
                    _buildSleepTipsCard()
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 800.ms)
                      .slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSleepDialog,
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo.shade900,
        icon: const Icon(Icons.add),
        label: Text(
          'Înregistrează Somn',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ).animate()
        .fadeIn(duration: 500.ms, delay: 1000.ms)
        .scale(delay: 300.ms),
    );
  }

  Widget _buildSleepScoreCard(SleepData sleepData) {
    final score = sleepData.getSleepScore();
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.indigo.shade400,
              Colors.indigo.shade300,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scor Somn',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '${score.toInt()}',
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: score / 100,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 8,
                      ),
                      Center(
                        child: Icon(
                          score >= 80 ? Icons.sentiment_very_satisfied :
                          score >= 60 ? Icons.sentiment_satisfied :
                          score >= 40 ? Icons.sentiment_neutral :
                          Icons.sentiment_dissatisfied,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSleepMetric(
                  'Durata',
                  sleepData.getFormattedDuration(),
                  Icons.access_time,
                ),
                _buildSleepMetric(
                  'Calitate',
                  '${sleepData.sleepQuality}/5',
                  Icons.star,
                ),
                _buildSleepMetric(
                  'Deep Sleep',
                  '${sleepData.sleepStages['deep']} min',
                  Icons.waves,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildBedtimeCard(Duration timeUntilBedtime) {
    final hours = timeUntilBedtime.inHours;
    final minutes = timeUntilBedtime.inMinutes % 60;
    
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.nightlight_round,
                  color: Colors.indigo.shade400,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Timp până la culcare',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '$hours ore și $minutes minute',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade900,
              ),
            ),
            Text(
              'Ora de culcare: ${_settings.bedtime.format(context)}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SleepData? _getLastNightSleep() {
    if (_sleepHistory.isEmpty) return null;
    final sortedDates = _sleepHistory.keys.toList()..sort();
    return _sleepHistory[sortedDates.last];
  }

  Widget _buildSleepStatsCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistici Somn',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 12,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                          return Text(
                            days[value.toInt()],
                            style: GoogleFonts.poppins(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}h',
                            style: GoogleFonts.poppins(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _getWeeklyBarData(),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _getWeeklyBarData() {
    final now = DateTime.now();
    final weekData = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final dateStr = date.toIso8601String().split('T')[0];
      final sleepData = _sleepHistory[dateStr];
      return sleepData?.duration.inHours.toDouble() ?? 0;
    });

    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: weekData[index],
            color: Colors.indigo.shade400,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSleepSoundsCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sunete Relaxante',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_isPlayingSound)
                  IconButton(
                    icon: const Icon(Icons.stop_circle, color: Colors.red),
                    onPressed: _stopSound,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: sleepSounds.length,
                itemBuilder: (context, index) {
                  final sound = sleepSounds[index];
                  final isSelected = _selectedSoundIndex == index;
                  return GestureDetector(
                    onTap: () => _playSound(index),
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.indigo.shade50 : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.indigo : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.waves,
                            color: isSelected ? Colors.indigo : Colors.grey[600],
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            sound.title,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isSelected ? Colors.indigo : Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepTipsCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sfaturi pentru un Somn Mai Bun',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ..._settings.getSleepTips().map((tip) => _buildTip(tip)).take(4),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[400], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _playSound(int index) {
    if (_selectedSoundIndex == index && _isPlayingSound) {
      _stopSound();
      return;
    }
    
    setState(() {
      _selectedSoundIndex = index;
      _isPlayingSound = true;
    });
    
    _audioPlayer.setAsset(sleepSounds[index].assetPath);
    _audioPlayer.setLoopMode(LoopMode.one);
    _audioPlayer.play();
  }

  void _stopSound() {
    setState(() {
      _isPlayingSound = false;
      _selectedSoundIndex = -1;
    });
    _audioPlayer.stop();
  }

  void _showBedtimeReminder() async {
    const androidDetails = AndroidNotificationDetails(
      'sleep_reminders',
      'Reminders de somn',
      channelDescription: 'Notificări pentru programul de somn',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );
    
    await _notifications.show(
      1,
      'Timp pentru somn',
      'Este timpul să te pregătești de culcare pentru a-ți menține rutina de somn.',
      details,
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        var tempSettings = _settings;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.settings, color: Colors.indigo.shade400),
                const SizedBox(width: 10),
                Text(
                  'Setări Somn',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      'Ora de Culcare',
                      style: GoogleFonts.poppins(),
                    ),
                    subtitle: Text(
                      tempSettings.bedtime.format(context),
                      style: GoogleFonts.poppins(),
                    ),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: tempSettings.bedtime,
                      );
                      if (time != null) {
                        setState(() {
                          tempSettings = tempSettings.copyWith(bedtime: time);
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Ora de Trezire',
                      style: GoogleFonts.poppins(),
                    ),
                    subtitle: Text(
                      tempSettings.wakeTime.format(context),
                      style: GoogleFonts.poppins(),
                    ),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: tempSettings.wakeTime,
                      );
                      if (time != null) {
                        setState(() {
                          tempSettings = tempSettings.copyWith(wakeTime: time);
                        });
                      }
                    },
                  ),
                  SwitchListTile(
                    title: Text(
                      'Remindere',
                      style: GoogleFonts.poppins(),
                    ),
                    value: tempSettings.enableReminders,
                    onChanged: (value) {
                      setState(() {
                        tempSettings = tempSettings.copyWith(enableReminders: value);
                      });
                    },
                  ),
                  if (tempSettings.enableReminders)
                    ListTile(
                      title: Text(
                        'Reminder înainte cu',
                        style: GoogleFonts.poppins(),
                      ),
                      subtitle: Text(
                        '${tempSettings.reminderOffset} minute',
                        style: GoogleFonts.poppins(),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (tempSettings.reminderOffset > 5) {
                                setState(() {
                                  tempSettings = tempSettings.copyWith(
                                    reminderOffset: tempSettings.reminderOffset - 5,
                                  );
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                tempSettings = tempSettings.copyWith(
                                  reminderOffset: tempSettings.reminderOffset + 5,
                                );
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  SwitchListTile(
                    title: Text(
                      'Sunete Relaxante',
                      style: GoogleFonts.poppins(),
                    ),
                    value: tempSettings.enableSoundscapes,
                    onChanged: (value) {
                      setState(() {
                        tempSettings = tempSettings.copyWith(enableSoundscapes: value);
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Anulează',
                  style: GoogleFonts.poppins(),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _settings = tempSettings;
                    _saveData();
                    _startBedtimeTimer();
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                ),
                child: Text(
                  'Salvează',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddSleepDialog() {
    showDialog(
      context: context,
      builder: (context) {
        DateTime? bedtime;
        DateTime? wakeTime;
        int quality = 3;
        final habits = Map<String, bool>.from(_settings.sleepHabits);
        final selectedTags = <String>[];
        
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.nightlight_round, color: Colors.indigo.shade400),
                const SizedBox(width: 10),
                Text(
                  'Înregistrează Somn',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.bedtime),
                    title: Text(
                      'Ora de Culcare',
                      style: GoogleFonts.poppins(),
                    ),
                    subtitle: Text(
                      bedtime != null
                          ? DateFormat('HH:mm').format(bedtime!)
                          : 'Selectează ora',
                      style: GoogleFonts.poppins(),
                    ),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        final now = DateTime.now();
                        setState(() {
                          bedtime = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.wb_sunny),
                    title: Text(
                      'Ora de Trezire',
                      style: GoogleFonts.poppins(),
                    ),
                    subtitle: Text(
                      wakeTime != null
                          ? DateFormat('HH:mm').format(wakeTime!)
                          : 'Selectează ora',
                      style: GoogleFonts.poppins(),
                    ),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        final now = DateTime.now();
                        setState(() {
                          wakeTime = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Calitatea Somnului',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          quality > index ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            quality = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Obiceiuri',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ...habits.entries.map((e) => CheckboxListTile(
                    title: Text(
                      e.key,
                      style: GoogleFonts.poppins(),
                    ),
                    value: e.value,
                    onChanged: (value) {
                      setState(() {
                        habits[e.key] = value ?? false;
                      });
                    },
                  )),
                  const SizedBox(height: 16),
                  Text(
                    'Etichete',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: _settings.sleepTags.map((tag) {
                      final isSelected = selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(
                          tag,
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              selectedTags.add(tag);
                            } else {
                              selectedTags.remove(tag);
                            }
                          });
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: Colors.indigo,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Anulează',
                  style: GoogleFonts.poppins(),
                ),
              ),
              ElevatedButton(
                onPressed: bedtime != null && wakeTime != null
                    ? () {
                        final sleepData = SleepData(
                          bedtime: bedtime!,
                          wakeTime: wakeTime!,
                          sleepQuality: quality,
                          habits: habits,
                          tags: selectedTags,
                        );
                        
                        setState(() {
                          final dateStr = bedtime!.toIso8601String().split('T')[0];
                          _sleepHistory[dateStr] = sleepData;
                          _saveData();
                        });
                        
                        Navigator.pop(context);
                        _showSuccessSnackbar();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                ),
                child: Text(
                  'Salvează',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessSnackbar() {
    final messages = [
      "Somn înregistrat cu succes! 😴",
      "Odihnă bună pentru o zi productivă! 🌙",
      "Un pas spre un somn mai sănătos! 💫",
      "Continuă să monitorizezi somnul! 📊",
      "Rutina de somn este cheia succesului! 🎯",
    ];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              messages[DateTime.now().second % messages.length],
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.indigo,
      ),
    );
  }
} 