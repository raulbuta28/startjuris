import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../pages/backend/providers/auth_provider.dart';
import '../../../services/user_utils_service.dart';
import '../../../providers/utils_provider.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:just_audio/just_audio.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> with TickerProviderStateMixin {
  final _player = AudioPlayer();
  Timer? _timer;
  Duration _currentDuration = Duration.zero;
  Duration _selectedDuration = const Duration(minutes: 10);
  bool _isPlaying = false;
  String _selectedType = 'Mindfulness';
  String _selectedSound = 'Ploaie';
  late AnimationController _breathingController;
  late AnimationController _particleController;
  bool _isInhaling = true;
  int _breathCount = 0;
  double _progress = 0.0;
  bool _isSoundEnabled = true;

  // Particle system
  final List<Particle> _particles = List.generate(
    50,
    (index) => Particle(
      position: Offset(
        math.Random().nextDouble() * 400,
        math.Random().nextDouble() * 800,
      ),
      velocity: Offset(
        math.Random().nextDouble() * 2 - 1,
        math.Random().nextDouble() * 2 - 1,
      ),
      color: Colors.white.withOpacity(0.3),
      size: math.Random().nextDouble() * 8 + 4,
    ),
  );

  static const Map<String, String> _meditationTypes = {
    'Mindfulness': 'Concentrează-te pe respirație și momentul prezent',
    'Compasiune': 'Cultivă compasiunea și emoțiile pozitive',
    'Scanare Corporală': 'Relaxare progresivă de la cap la picioare',
    'Vizualizare': 'Creează imagini mentale liniștitoare',
    'Transcendentală': 'Meditație silențioasă cu mantra',
    'Zen': 'Meditație cu mintea goală',
    'Chakra': 'Alinierea centrilor energetici',
    'Baie Sonoră': 'Vindecare prin sunet imersiv',
  };

  static const Map<String, String> _ambientSounds = {
    'Ploaie': 'packages/flutter/assets/sounds/notification.mp3',
    'Ocean': 'packages/flutter/assets/sounds/click.mp3',
    'Pădure': 'packages/flutter/assets/sounds/notification.mp3',
    'Pârâu': 'packages/flutter/assets/sounds/click.mp3',
    'Păsări': 'packages/flutter/assets/sounds/notification.mp3',
    'Clopoței': 'packages/flutter/assets/sounds/click.mp3',
    'Boluri': 'packages/flutter/assets/sounds/notification.mp3',
    'Liniște': ''
  };

  static const List<Duration> _durations = [
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 15),
    Duration(minutes: 20),
    Duration(minutes: 30),
    Duration(minutes: 45),
    Duration(minutes: 60),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _setupAnimationControllers();
  }

  Future<void> _initializeAudio() async {
    try {
      await _player.setVolume(0.5);
      await _player.setLoopMode(LoopMode.one);
    } catch (e) {
      debugPrint('Could not initialize audio: $e');
      _isSoundEnabled = false;
    }
  }

  void _setupAnimationControllers() {
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isInhaling = false;
            _breathCount++;
          });
          _breathingController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          setState(() {
            _isInhaling = true;
          });
          _breathingController.forward();
        }
      });

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateParticles);

    _particleController.repeat();
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.position += particle.velocity;
      
      // Wrap particles around screen
      if (particle.position.dx < 0) particle.position = Offset(400, particle.position.dy);
      if (particle.position.dx > 400) particle.position = Offset(0, particle.position.dy);
      if (particle.position.dy < 0) particle.position = Offset(particle.position.dx, 800);
      if (particle.position.dy > 800) particle.position = Offset(particle.position.dx, 0);
    }
    setState(() {});
  }

  Future<void> _playSound() async {
    if (!_isSoundEnabled || _selectedSound == 'Liniște') return;
    
    try {
      final soundPath = _ambientSounds[_selectedSound]!;
      if (soundPath.isNotEmpty) {
        await _player.setAsset(soundPath);
        await _player.play();
      }
    } catch (e) {
      debugPrint('Could not play sound: $e');
      _isSoundEnabled = false;
    }
  }

  Future<void> _startMeditation() async {
    if (!_isPlaying) {
      HapticFeedback.mediumImpact();
      setState(() {
        _isPlaying = true;
        _progress = 0.0;
      });
      
      Provider.of<UtilsProvider>(context, listen: false).startMeditation(
        _selectedType,
        _selectedDuration,
      );

      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {
          _currentDuration += const Duration(milliseconds: 100);
          _progress = _currentDuration.inMilliseconds / _selectedDuration.inMilliseconds;
        });

        if (_currentDuration >= _selectedDuration) {
          _completeMeditation();
        }
      });

      _breathingController.forward();
      await _playSound();
    } else {
      _pauseMeditation();
    }
  }

  void _pauseMeditation() {
    HapticFeedback.lightImpact();
    setState(() {
      _isPlaying = false;
    });
    _timer?.cancel();
    _player.pause();
    _breathingController.stop();
  }

  void _completeMeditation() {
    HapticFeedback.heavyImpact();
    _stopMeditation();
    _showCompletionDialog();
  }

  void _stopMeditation() {
    if (_isPlaying) {
      setState(() {
        _isPlaying = false;
        _currentDuration = Duration.zero;
        _progress = 0.0;
        _breathCount = 0;
      });
      _timer?.cancel();
      _player.stop();
      _breathingController.reset();
    }
  }

  Future<void> _showCompletionDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Meditație Completă',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 50, color: Colors.purple),
            const SizedBox(height: 16),
            Text(
              'Felicitări! Ai completat ${_formatDuration(_selectedDuration)} de meditație $_selectedType.',
              style: GoogleFonts.poppins(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Cicluri de respirație: $_breathCount',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Închide',
              style: GoogleFonts.poppins(color: Colors.purple),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(Colors.purple.shade200, Colors.blue.shade200, _progress)!,
                  Color.lerp(Colors.blue.shade100, Colors.purple.shade100, _progress)!,
                ],
              ),
            ),
          ),

          // Particle System
          CustomPaint(
            painter: ParticlePainter(_particles),
            size: Size.infinite,
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        'Meditație',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          // Show settings dialog
                        },
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Meditation Type Selector
                        Container(
                          height: 140,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _meditationTypes.length,
                            itemBuilder: (context, index) {
                              final type = _meditationTypes.keys.elementAt(index);
                              final description = _meditationTypes.values.elementAt(index);
                              final isSelected = type == _selectedType;

                              return Container(
                                width: 160,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                child: Card(
                                  color: isSelected 
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.white.withOpacity(0.3),
                                  elevation: isSelected ? 4 : 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      if (!_isPlaying) {
                                        setState(() {
                                          _selectedType = type;
                                        });
                                        HapticFeedback.selectionClick();
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            type,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? Colors.black : Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            description,
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: isSelected ? Colors.black54 : Colors.white70,
                                            ),
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Duration Selector
                        if (!_isPlaying) Container(
                          height: 50,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _durations.length,
                            itemBuilder: (context, index) {
                              final duration = _durations[index];
                              final isSelected = duration == _selectedDuration;
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Material(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(25),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedDuration = duration;
                                      });
                                      HapticFeedback.selectionClick();
                                    },
                                    borderRadius: BorderRadius.circular(25),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${duration.inMinutes} min',
                                        style: GoogleFonts.poppins(
                                          color: isSelected ? Colors.black : Colors.white,
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

                        const SizedBox(height: 20),

                        // Breathing Animation
                        Center(
                          child: AnimatedBuilder(
                            animation: _breathingController,
                            builder: (context, child) {
                              return Container(
                                width: 300 + (_breathingController.value * 50),
                                height: 300 + (_breathingController.value * 50),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.1),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 280,
                                      height: 280,
                                      child: CircularProgressIndicator(
                                        value: _progress,
                                        strokeWidth: 10,
                                        backgroundColor: Colors.white.withOpacity(0.1),
                                        color: Colors.white,
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _formatDuration(_isPlaying ? _selectedDuration - _currentDuration : _selectedDuration),
                                          style: GoogleFonts.poppins(
                                            fontSize: 64,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          _isPlaying ? (_isInhaling ? 'Inspiră' : 'Expiră') : _selectedType,
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        if (_isPlaying) Text(
                                          'Cicluri de respirație: $_breathCount',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.white60,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Sound Selector
                        if (!_isPlaying) Container(
                          height: 50,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _ambientSounds.length,
                            itemBuilder: (context, index) {
                              final sound = _ambientSounds.keys.elementAt(index);
                              final isSelected = sound == _selectedSound;
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Material(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(25),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedSound = sound;
                                      });
                                      HapticFeedback.selectionClick();
                                    },
                                    borderRadius: BorderRadius.circular(25),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      alignment: Alignment.center,
                                      child: Text(
                                        sound,
                                        style: GoogleFonts.poppins(
                                          color: isSelected ? Colors.black : Colors.white,
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

                        const SizedBox(height: 20),

                        // Controls
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isPlaying) FloatingActionButton(
                                heroTag: 'stop',
                                onPressed: _stopMeditation,
                                backgroundColor: Colors.red.withOpacity(0.9),
                                child: const Icon(Icons.stop, color: Colors.white),
                              ),
                              const SizedBox(width: 32),
                              FloatingActionButton(
                                heroTag: 'play',
                                onPressed: _startMeditation,
                                backgroundColor: Colors.white.withOpacity(0.9),
                                child: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.purple,
                                ),
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
          ),
        ],
      ),
    );
  }
}

class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double size;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      paint.color = particle.color;
      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
} 