import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/utils_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math' show pi, sin, cos;
import 'package:flutter/rendering.dart';
import 'dart:ui';  // Add this import for ImageFilter
import 'models/water_settings.dart';
import 'models/water_stats.dart';
import 'models/water_calculator.dart';
import 'widgets/water_onboarding_dialog.dart';
import 'package:intl/intl.dart';

class WaterPage extends StatefulWidget {
  const WaterPage({super.key});

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> with TickerProviderStateMixin {
  WaterSettings _settings = WaterSettings();
  WaterStats _stats = WaterStats();
  late TabController _tabController;
  late AnimationController _waveController;
  late FlutterLocalNotificationsPlugin _notifications;
  Timer? _reminderTimer;
  bool _isLoading = true;
  double _temperature = 25.0;
  double _humidity = 50.0;
  int _activeMinutes = 0;
  double _weight = 70.0;
  final ScrollController _scrollController = ScrollController();

  final List<Color> _waveGradient = [
    const Color(0xFF3AA1FF),
    const Color(0xFF3AA1FF).withOpacity(0.5),
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupNotifications();
    _loadData().then((_) {
      if (mounted) {
        _startReminderTimer();
        _checkFirstLaunch();
      }
    });
  }

  void _initializeControllers() {
    _tabController = TabController(length: 4, vsync: this);
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  Future<void> _setupNotifications() async {
    _notifications = FlutterLocalNotificationsPlugin();
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _notifications.initialize(initializationSettings);
  }

  void _startReminderTimer() {
    _reminderTimer?.cancel();
    if (_settings.enableReminders) {
      _reminderTimer = Timer.periodic(
        Duration(minutes: _settings.reminderIntervals[0]),
        (timer) => _showHydrationReminder(),
      );
    }
  }

  Future<void> _showHydrationReminder() async {
    if (!_settings.enableReminders) return;
    
    final progress = _stats.getTodayProgress();
    final goal = _stats.getTodayGoal();
    
    if (progress < goal) {
      const androidDetails = AndroidNotificationDetails(
        'water_reminders',
        'Reminders de hidratare',
        channelDescription: 'Notificări pentru a vă reaminti să beți apă',
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
        0,
        'Timp pentru hidratare!',
        'Mai ai nevoie de ${_settings.formatVolume(goal - progress)} pentru a-ți atinge obiectivul zilnic.',
        details,
      );
      
      if (mounted) {
        setState(() {
          _stats.incrementReminderResponse(
            DateTime.now().toIso8601String().split('T')[0],
          );
        });
      }
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _settings = WaterSettings.fromJson(
        jsonDecode(prefs.getString('water_settings') ?? '{}'),
      );
      _stats = WaterStats.fromJson(
        jsonDecode(prefs.getString('water_stats') ?? '{}'),
      );
      _isLoading = false;
    });
  }

  Future<void> _saveData() async {
    if (!mounted) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('water_settings', jsonEncode(_settings.toJson()));
    await prefs.setString('water_stats', jsonEncode(_stats.toJson()));
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('water_first_launch') ?? true;
    
    if (isFirstLaunch && mounted) {
      await prefs.setBool('water_first_launch', false);
      _showOnboardingDialog();
    }
  }

  void _showOnboardingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WaterOnboardingDialog(
        onComplete: (settings) {
          setState(() {
            _settings = settings;
            _saveData();
          });
          Navigator.pop(context);
          
          // Afișează recomandările
          _showRecommendationsDialog();
        },
      ),
    );
  }

  void _showRecommendationsDialog() {
    final recommendedIntake = _settings.getAdjustedGoal(
      temperature: _temperature,
      humidity: _humidity,
      activeMinutes: _activeMinutes,
    );
    
    // Actualizăm statisticile cu noul obiectiv
    setState(() {
      _stats.updateDailyGoal(
        DateTime.now().toIso8601String().split('T')[0],
        recommendedIntake,
      );
      _saveData();
    });
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Planul tău de hidratare'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Necesarul tău zilnic de apă este:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.water_drop, color: Colors.blue, size: 32),
                  const SizedBox(width: 8),
                  Text(
                    _settings.formatVolume(recommendedIntake),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ...(_settings.getPersonalizedTips().map((tip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade300, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(tip),
                  ),
                ],
              ),
            ))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Începe'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _waveController.dispose();
    _reminderTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _stats.getTodayProgress() / _stats.getTodayGoal();
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Hidratare',
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: CircularProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            strokeWidth: 15,
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            color: Colors.blue,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${_stats.getTodayProgress()} ml',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'din ${_stats.getTodayGoal()} ml',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Adaugă apă',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildWaterButton(100, Icons.water_drop),
                        _buildWaterButton(200, Icons.water_drop),
                        _buildWaterButton(300, Icons.water_drop),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildWaterButton(400, Icons.local_drink),
                        _buildWaterButton(500, Icons.local_drink),
                        _buildWaterButton(600, Icons.local_drink),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (progress >= 1.0)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Felicitări! Ți-ai atins obiectivul zilnic!',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWaterButton(int amount, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _addWater(amount),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: Colors.blue,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                '$amount ml',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addWater(int amount) {
    setState(() {
      _stats.incrementWaterIntake(amount.toDouble());
      _saveData();
    });
  }

  void _resetWaterIntake() {
    setState(() {
      _stats.resetWaterIntake();
      _saveData();
    });
  }

  void _quickAddWater(String container, int volume) {
    final entry = WaterEntry(
      timestamp: DateTime.now(),
      volume: volume.toDouble(),
      beverageType: 'Apă plată',
      container: container,
    );
    
    setState(() {
      _stats.addEntry(entry);
      _saveData();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Adăugat ${_settings.formatVolume(volume.toDouble())}'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Anulează',
          onPressed: () {
            // Implementează anularea adăugării
          },
        ),
      ),
    );
  }

  void _showAddEntryDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Adaugă băutură',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Implementează formularul pentru adăugarea unei băuturi
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEntryDetails(WaterEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry.beverageType),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Volum', _settings.formatVolume(entry.volume)),
            _buildDetailRow('Container', entry.container),
            _buildDetailRow(
              'Oră',
              DateFormat('HH:mm').format(entry.timestamp),
            ),
            if (entry.caffeineContent > 0)
              _buildDetailRow(
                'Cafeină',
                '${entry.caffeineContent} mg',
              ),
            if (entry.sodiumContent > 0)
              _buildDetailRow(
                'Sodiu',
                '${entry.sodiumContent} mg',
              ),
            if (entry.note != null && entry.note!.isNotEmpty)
              _buildDetailRow('Notă', entry.note!),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        WaterSettings tempSettings = _settings;
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.settings, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Setări',
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_settings.hasPersonalInfo())
                            Card(
                              color: Colors.blue.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.info, color: Colors.blue.shade700),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Completează informațiile personale pentru un obiectiv personalizat de hidratare',
                                        style: GoogleFonts.roboto(
                                          color: Colors.blue.shade700,
                                          letterSpacing: -0.3,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          _buildSettingSection(
                            'Informații Personale',
                            [
                              Theme(
                                data: Theme.of(context).copyWith(
                                  textTheme: GoogleFonts.robotoTextTheme(
                                    Theme.of(context).textTheme,
                                  ).copyWith(
                                    bodyMedium: GoogleFonts.roboto(
                                      letterSpacing: -0.3,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    DropdownButtonFormField<String>(
                                      value: tempSettings.gender,
                                      decoration: const InputDecoration(labelText: 'Gen'),
                                      items: const [
                                        DropdownMenuItem(value: 'masculin', child: Text('Masculin')),
                                        DropdownMenuItem(value: 'feminin', child: Text('Feminin')),
                                      ],
                                      onChanged: (value) => setState(() {
                                        tempSettings = tempSettings.copyWith(gender: value);
                                      }),
                                    ),
                                    TextFormField(
                                      initialValue: tempSettings.age?.toString() ?? '',
                                      decoration: const InputDecoration(labelText: 'Vârstă'),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) => setState(() {
                                        tempSettings = tempSettings.copyWith(
                                          age: int.tryParse(value),
                                        );
                                      }),
                                    ),
                                    TextFormField(
                                      initialValue: tempSettings.weight?.toString() ?? '',
                                      decoration: const InputDecoration(
                                        labelText: 'Greutate (kg)',
                                        suffixText: 'kg',
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) => setState(() {
                                        tempSettings = tempSettings.copyWith(
                                          weight: double.tryParse(value),
                                        );
                                      }),
                                    ),
                                    TextFormField(
                                      initialValue: tempSettings.height?.toString() ?? '',
                                      decoration: const InputDecoration(
                                        labelText: 'Înălțime (cm)',
                                        suffixText: 'cm',
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) => setState(() {
                                        tempSettings = tempSettings.copyWith(
                                          height: double.tryParse(value),
                                        );
                                      }),
                                    ),
                                    DropdownButtonFormField<int>(
                                      value: tempSettings.activityLevel,
                                      decoration: const InputDecoration(
                                        labelText: 'Nivel de activitate',
                                        alignLabelWithHint: true,
                                      ),
                                      isExpanded: true,
                                      menuMaxHeight: 300,
                                      items: List.generate(5, (index) => index + 1).map((level) {
                                        return DropdownMenuItem(
                                          value: level,
                                          child: Text(
                                            WaterCalculator.getActivityLevelDescription(level),
                                            style: const TextStyle(fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) => setState(() {
                                        tempSettings = tempSettings.copyWith(
                                          activityLevel: value,
                                        );
                                      }),
                                    ),
                                    if (tempSettings.gender == 'feminin') ...[
                                      SwitchListTile(
                                        title: const Text('Sarcină'),
                                        value: tempSettings.isPregnant,
                                        onChanged: (value) => setState(() {
                                          tempSettings = tempSettings.copyWith(
                                            isPregnant: value,
                                            isBreastfeeding: value ? false : tempSettings.isBreastfeeding,
                                          );
                                        }),
                                      ),
                                      SwitchListTile(
                                        title: const Text('Alăptare'),
                                        value: tempSettings.isBreastfeeding,
                                        onChanged: (value) => setState(() {
                                          tempSettings = tempSettings.copyWith(
                                            isBreastfeeding: value,
                                            isPregnant: value ? false : tempSettings.isPregnant,
                                          );
                                        }),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          _buildSettingSection(
                            'Ajustări',
                            [
                              SwitchListTile(
                                title: Text(
                                  'Ajustare după vreme',
                                  style: GoogleFonts.roboto(
                                    fontSize: 13,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                value: tempSettings.enableWeatherAdjustment,
                                onChanged: (value) => setState(() {
                                  tempSettings = tempSettings.copyWith(
                                    enableWeatherAdjustment: value,
                                  );
                                }),
                              ),
                              SwitchListTile(
                                title: Text(
                                  'Ajustare după activitate',
                                  style: GoogleFonts.roboto(
                                    fontSize: 13,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                value: tempSettings.enableActivityAdjustment,
                                onChanged: (value) => setState(() {
                                  tempSettings = tempSettings.copyWith(
                                    enableActivityAdjustment: value,
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSettingSection(
                            'Resetare',
                            [
                              ListTile(
                                leading: const Icon(Icons.refresh, color: Colors.red),
                                title: Text(
                                  'Resetează planul de hidratare',
                                  style: GoogleFonts.roboto(
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                subtitle: Text(
                                  'Această acțiune va șterge doar datele legate de hidratare',
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                onTap: () => _showResetConfirmationDialog(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Actions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Anulează',
                            style: GoogleFonts.roboto(
                              letterSpacing: -0.3,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final calculatedGoal = tempSettings.getAdjustedGoal(
                              temperature: _temperature,
                              humidity: _humidity,
                              activeMinutes: _activeMinutes,
                            );
                            
                            setState(() {
                              _settings = tempSettings;
                              final today = DateTime.now().toIso8601String().split('T')[0];
                              _stats.updateDailyGoal(today, calculatedGoal);
                              _saveData();
                            });
                            
                            Navigator.pop(context);
                            
                            if (_settings.hasPersonalInfo()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Noul tău obiectiv zilnic: ${_settings.formatVolume(calculatedGoal)}',
                                    style: GoogleFonts.roboto(
                                      letterSpacing: -0.3,
                                      height: 1.1,
                                    ),
                                  ),
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'Salvează',
                            style: GoogleFonts.roboto(
                              letterSpacing: -0.3,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Resetare plan hidratare',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        content: Text(
          'Ești sigur că vrei să resetezi datele de hidratare? Această acțiune nu poate fi anulată.',
          style: GoogleFonts.roboto(
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Anulează',
              style: GoogleFonts.roboto(
                letterSpacing: -0.3,
                height: 1.1,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Închide dialogul de confirmare
              Navigator.of(context).pop();
              // Închide dialogul de setări
              Navigator.of(context).pop();
              
              final prefs = await SharedPreferences.getInstance();
              // Ștergem doar datele legate de hidratare
              await prefs.remove('water_settings');
              await prefs.remove('water_stats');
              
              if (mounted) {
                setState(() {
                  _settings = WaterSettings(); // Resetează setările
                  _stats = WaterStats(); // Resetează statisticile
                });
                _saveData(); // Salvează starea inițială
                _showOnboardingDialog(); // Arată din nou dialogul de onboarding
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              'Resetează',
              style: GoogleFonts.roboto(
                letterSpacing: -0.3,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistici'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatRow(
                'Serie curentă',
                '${_stats.getCurrentStreak()} zile',
                Icons.local_fire_department,
              ),
              const Divider(),
              _buildStatRow(
                'Media zilnică',
                _settings.formatVolume(
                  _calculateAverageDailyIntake(),
                ),
                Icons.analytics,
              ),
              const Divider(),
              _buildStatRow(
                'Cel mai bun record',
                _settings.formatVolume(
                  _findBestDayIntake(),
                ),
                Icons.emoji_events,
              ),
            ],
          ),
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

  double _calculateAverageDailyIntake() {
    final entries = _stats.dailyEntries;
    if (entries.isEmpty) return 0;

    double total = 0;
    for (var dayEntries in entries.values) {
      total += dayEntries.fold(
        0.0,
        (sum, entry) => sum + entry.volume,
      );
    }
    return total / entries.length;
  }

  double _findBestDayIntake() {
    final entries = _stats.dailyEntries;
    if (entries.isEmpty) return 0;

    double best = 0;
    for (var dayEntries in entries.values) {
      final dayTotal = dayEntries.fold(
        0.0,
        (sum, entry) => sum + entry.volume,
      );
      if (dayTotal > best) best = dayTotal;
    }
    return best;
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Istoric hidratare',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
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
                          _settings.formatVolume(value),
                          style: const TextStyle(
                            color: Colors.grey,
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
                        final date = DateTime.now().subtract(
                          Duration(days: (6 - value).toInt()),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('E').format(date),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
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
                    spots: _getWeeklyData(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                  ),
                ],
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: _findMaxIntake(),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Detalii săptămânale',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildWeeklyStats(),
        ],
      ),
    );
  }

  List<FlSpot> _getWeeklyData() {
    final spots = <FlSpot>[];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now()
          .subtract(Duration(days: i))
          .toIso8601String()
          .split('T')[0];
      final entries = _stats.dailyEntries[date] ?? [];
      final total = entries.fold(
        0.0,
        (sum, entry) => sum + entry.volume,
      );
      spots.add(FlSpot(6 - i.toDouble(), total));
    }
    return spots;
  }

  double _findMaxIntake() {
    double max = 0;
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now()
          .subtract(Duration(days: i))
          .toIso8601String()
          .split('T')[0];
      final entries = _stats.dailyEntries[date] ?? [];
      final total = entries.fold(
        0.0,
        (sum, entry) => sum + entry.volume,
      );
      if (total > max) max = total;
    }
    return max > 0 ? max : 3000;
  }

  Widget _buildWeeklyStats() {
    return Column(
      children: [
        _buildWeeklyStat(
          'Media zilnică',
          _settings.formatVolume(_calculateAverageDailyIntake()),
          Icons.analytics,
          Colors.blue,
        ),
        _buildWeeklyStat(
          'Zile peste obiectiv',
          _countDaysAboveGoal().toString(),
          Icons.emoji_events,
          Colors.orange,
        ),
        _buildWeeklyStat(
          'Băuturi preferate',
          _getFavoriteBevarages(),
          Icons.local_drink,
          Colors.green,
        ),
        if (_settings.trackCaffeine)
          _buildWeeklyStat(
            'Media cafeină',
            '${_calculateAverageCaffeineIntake()} mg',
            Icons.coffee,
            Colors.brown,
          ),
      ],
    );
  }

  Widget _buildWeeklyStat(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _countDaysAboveGoal() {
    int count = 0;
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now()
          .subtract(Duration(days: i))
          .toIso8601String()
          .split('T')[0];
      final entries = _stats.dailyEntries[date] ?? [];
      final total = entries.fold(
        0.0,
        (sum, entry) => sum + entry.volume,
      );
      final goal = _stats.dailyGoals[date] ?? _settings.dailyGoal;
      if (total >= goal) {
        count++;
      }
    }
    return count;
  }

  String _getFavoriteBevarages() {
    final beverages = <String, int>{};
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now()
          .subtract(Duration(days: i))
          .toIso8601String()
          .split('T')[0];
      final prefs = _stats.beveragePreferences[date] ?? {};
      for (var entry in prefs.entries) {
        beverages[entry.key] = (beverages[entry.key] ?? 0) + entry.value;
      }
    }
    if (beverages.isEmpty) return 'Nu există date';
    final sorted = beverages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  double _calculateAverageCaffeineIntake() {
    int total = 0;
    int days = 0;
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now()
          .subtract(Duration(days: i))
          .toIso8601String()
          .split('T')[0];
      if (_stats.dailyCaffeineIntake.containsKey(date)) {
        total += _stats.dailyCaffeineIntake[date]!;
        days++;
      }
    }
    return days > 0 ? total.toDouble() / days : 0;
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analiză detaliată',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),
          _buildAnalysisCard(
            'Distribuție orară',
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${value.toInt()}:00',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
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
                  barGroups: _getHourlyDistribution(),
                  maxY: _findMaxHourlyIntake(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildAnalysisCard(
            'Impact vreme',
            _buildWeatherImpactChart(),
          ),
          const SizedBox(height: 20),
          _buildAnalysisCard(
            'Eficiență remindere',
            _buildReminderEfficiencyChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(String title, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          chart,
        ],
      ),
    );
  }

  List<BarChartGroupData> _getHourlyDistribution() {
    final distribution = <int, double>{};
    for (var entries in _stats.dailyEntries.values) {
      for (var entry in entries) {
        final hour = entry.timestamp.hour;
        distribution[hour] = (distribution[hour] ?? 0) + entry.volume;
      }
    }

    return List.generate(24, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: distribution[index] ?? 0,
            color: Colors.blue,
            width: 12,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  double _findMaxHourlyIntake() {
    double max = 0;
    for (var entries in _stats.dailyEntries.values) {
      final hourly = <int, double>{};
      for (var entry in entries) {
        final hour = entry.timestamp.hour;
        hourly[hour] = (hourly[hour] ?? 0) + entry.volume;
      }
      for (var value in hourly.values) {
        if (value > max) max = value;
      }
    }
    return max > 0 ? max : 1000;
  }

  Widget _buildWeatherImpactChart() {
    // Implementează un grafic care arată corelația dintre vreme și consum
    return const Center(
      child: Text('Grafic impact vreme - în dezvoltare'),
    );
  }

  Widget _buildReminderEfficiencyChart() {
    // Implementează un grafic care arată eficiența reminderelor
    return const Center(
      child: Text('Grafic eficiență remindere - în dezvoltare'),
    );
  }

  Widget _buildTipsTab() {
    final tips = [
      {
        'title': 'Cel mai bun moment pentru hidratare',
        'description':
            'Consumă un pahar de apă imediat după trezire pentru a-ți stimula metabolismul.',
        'icon': Icons.wb_sunny,
      },
      {
        'title': 'Semne de deshidratare',
        'description':
            'Urmărește culoarea urinei - ar trebui să fie galben pai sau mai deschisă.',
        'icon': Icons.warning,
      },
      {
        'title': 'Hidratare și exerciții',
        'description':
            'Bea 500ml de apă cu 2 ore înainte de exerciții și menține hidratarea în timpul acestora.',
        'icon': Icons.fitness_center,
      },
      {
        'title': 'Alimente hidratante',
        'description':
            'Include castraveți, pepene verde și țelină în dietă pentru hidratare suplimentară.',
        'icon': Icons.restaurant,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tips.length,
      itemBuilder: (context, index) {
        final tip = tips[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: Icon(tip['icon'] as IconData, color: Colors.blue),
            title: Text(
              tip['title'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(tip['description'] as String),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  final double percentage;
  final double value;

  _WaveClipper(this.percentage, this.value);

  @override
  Path getClip(Size size) {
    final path = Path();
    final y = size.height * (1 - percentage);
    
    path.moveTo(0, y);
    
    final firstControlPoint = Offset(
      size.width * .25,
      y + sin(value * pi * 2) * 15,
    );
    final firstEndPoint = Offset(
      size.width * .5,
      y + cos(value * pi * 2) * 15,
    );
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    
    final secondControlPoint = Offset(
      size.width * .75,
      y + sin(value * pi * 2) * 15,
    );
    final secondEndPoint = Offset(
      size.width,
      y + cos(value * pi * 2) * 15,
    );
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => true;
} 