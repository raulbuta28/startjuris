import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class Flashcard {
  final String question;
  final String answer;

  const Flashcard({required this.question, required this.answer});
}

const List<Flashcard> _sampleFlashcards = [
  Flashcard(
    question: 'Care este definiția proprietății private?',
    answer: 'Dreptul subiectiv al titularului de a deține, folosi și dispune de bun în mod exclusiv.',
  ),
  Flashcard(
    question: 'Ce este infracțiunea?',
    answer: 'Fapta prevăzută de legea penală, săvârșită cu vinovăție.',
  ),
  Flashcard(
    question: 'Ce este consimțământul în actul juridic civil?',
    answer: 'Acordul liber și neviciat al părților.',
  ),
];

class FlashcardsPage extends StatefulWidget {
  const FlashcardsPage({super.key});

  @override
  State<FlashcardsPage> createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> with TickerProviderStateMixin {
  String? _selectedSubject;
  String? _selectedChapter;
  bool _isFlashcardMode = false;
  int _currentCardIndex = 0;
  late AnimationController _gradientController;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;
  late Animation<Color?> _color3;
  bool _isFlipped = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
    _color1 = ColorTween(
      begin: const Color(0xFFFF6F61),
      end: const Color(0xFFFF8A65),
    ).animate(_gradientController);
    _color2 = ColorTween(
      begin: const Color(0xFFFFA07A),
      end: const Color(0xFFFFB6C1),
    ).animate(_gradientController);
    _color3 = ColorTween(
      begin: const Color(0xFFE91E63),
      end: const Color(0xFFBA55D3),
    ).animate(_gradientController);

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  void _startFlashcards() {
    if (_selectedSubject != null && _selectedChapter != null) {
      setState(() {
        _isFlashcardMode = true;
        _currentCardIndex = 0;
        _isFlipped = false;
      });
      HapticFeedback.mediumImpact();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te rugăm să selectezi materia și capitolul!')),
      );
    }
  }

  void _nextCard() {
    if (_currentCardIndex < _sampleFlashcards.length - 1) {
      setState(() {
        _currentCardIndex++;
        _isFlipped = false;
        _flipController.reset();
      });
      HapticFeedback.lightImpact();
    }
  }

  void _previousCard() {
    if (_currentCardIndex > 0) {
      setState(() {
        _currentCardIndex--;
        _isFlipped = false;
        _flipController.reset();
      });
      HapticFeedback.lightImpact();
    }
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
      _isFlipped ? _flipController.forward() : _flipController.reverse();
    });
    HapticFeedback.lightImpact();
  }

  void _closeFlashcards() {
    Navigator.pop(context);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: _isFlashcardMode
              ? _buildFlashcardScreen(context, screenWidth, screenHeight, isDark)
              : _buildSettingsScreen(context, screenWidth, isDark),
        ),
      ),
    );
  }

  Widget _buildSettingsScreen(BuildContext context, double screenWidth, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? Colors.grey[900]! : Colors.white,
            isDark ? Colors.grey[800]! : Colors.grey[100]!,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Configurare Flashcards',
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              hint: Text(
                'Selectează materia',
                style: GoogleFonts.poppins(color: isDark ? Colors.white70 : Colors.black54),
              ),
              items: const [
                DropdownMenuItem(value: 'Drept Civil', child: Text('Drept Civil')),
                DropdownMenuItem(value: 'Drept Penal', child: Text('Drept Penal')),
                DropdownMenuItem(value: 'Drept Procesual Civil', child: Text('Drept Procesual Civil')),
                DropdownMenuItem(value: 'Drept Procesual Penal', child: Text('Drept Procesual Penal')),
              ],
              onChanged: (value) => setState(() => _selectedSubject = value),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
              dropdownColor: isDark ? Colors.grey[800] : Colors.white,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedChapter,
              hint: Text(
                'Selectează capitolul',
                style: GoogleFonts.poppins(color: isDark ? Colors.white70 : Colors.black54),
              ),
              items: const [
                DropdownMenuItem(value: 'Proprietatea', child: Text('Proprietatea')),
                DropdownMenuItem(value: 'Infracțiunea', child: Text('Infracțiunea')),
                DropdownMenuItem(value: 'Consimțământul', child: Text('Consimțământul')),
                DropdownMenuItem(value: 'Urmărirea Penală', child: Text('Urmărirea Penală')),
              ],
              onChanged: (value) => setState(() => _selectedChapter = value),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
              dropdownColor: isDark ? Colors.grey[800] : Colors.white,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startFlashcards,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.3),
              ).copyWith(
                backgroundBuilder: (context, states, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6F61), Color(0xFFE91E63)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: child,
                  );
                },
              ),
              child: Text(
                'Începe',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashcardScreen(BuildContext context, double screenWidth, double screenHeight, bool isDark) {
    final card = _sampleFlashcards[_currentCardIndex];

    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_color1.value!, _color2.value!, _color3.value!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      final angle = _flipAnimation.value * 3.14159;
                      final isFront = _flipAnimation.value <= 0.5;
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        alignment: Alignment.center,
                        child: isFront
                            ? _buildFlashcardSide(
                                context,
                                screenWidth,
                                screenHeight,
                                card.question,
                                'Întrebare',
                                isDark,
                                true,
                              )
                            : Transform(
                                transform: Matrix4.identity()..rotateY(3.14159),
                                alignment: Alignment.center,
                                child: _buildFlashcardSide(
                                  context,
                                  screenWidth,
                                  screenHeight,
                                  card.answer,
                                  'Răspuns',
                                  isDark,
                                  false,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 32,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavButton(
                      icon: Icons.arrow_back,
                      onPressed: _previousCard,
                      enabled: _currentCardIndex > 0,
                      isDark: isDark,
                    ),
                    _buildNavButton(
                      icon: Icons.arrow_forward,
                      onPressed: _nextCard,
                      enabled: _currentCardIndex < _sampleFlashcards.length - 1,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: _buildNavButton(
                  icon: Icons.close,
                  onPressed: _closeFlashcards,
                  enabled: true,
                  isDark: isDark,
                  size: 40,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlashcardSide(
    BuildContext context,
    double screenWidth,
    double screenHeight,
    String text,
    String label,
    bool isDark,
    bool isFront,
  ) {
    return Container(
      width: screenWidth * 0.85,
      height: screenHeight * 0.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      text,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.4,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool enabled,
    required bool isDark,
    double size = 48,
  }) {
    return AnimatedScale(
      scale: enabled ? 1.0 : 0.8,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.5),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: enabled ? Colors.white : Colors.white.withOpacity(0.5),
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}