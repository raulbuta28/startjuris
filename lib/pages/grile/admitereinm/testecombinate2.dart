// filename: testecombinate2.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'testecombinate.dart' show ThemeProvider;
import 'package:share_plus/share_plus.dart';

final _gradient = LinearGradient(
  colors: [
    Color(0xFF6A1B9A).withOpacity(0.7),
    Color(0xFFE91E63).withOpacity(0.7),
    Color(0xFF2196F3).withOpacity(0.7),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

final List<LinearGradient> _iconGradients = [
  LinearGradient(
    colors: [Color(0xFF8E24AA), Color(0xFFEC407A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFF1E88E5), Color(0xFF4FC3F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFFF4511E), Color(0xFFFF8A65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFFAB47BC), Color(0xFFCE93D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFFD81B60), Color(0xFFF06292)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFFFFCA28), Color(0xFFFFF176)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFF009688), Color(0xFF4DB6AC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
];

class _SemicircleMenu extends StatefulWidget {
  final VoidCallback onClose;
  final bool isDark;
  final VoidCallback onToggleTheme;

  const _SemicircleMenu({
    required this.onClose,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  _SemicircleMenuState createState() => _SemicircleMenuState();
}

class _SemicircleMenuState extends State<_SemicircleMenu> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isLargeScreen = screenWidth > 600;

    // Dynamic sizing for modal
    final modalWidth = screenWidth - (isLargeScreen ? 48 : 24);
    final modalHeight = screenHeight * (isLargeScreen ? 0.5 : 0.45);
    final itemHeight = isLargeScreen ? 56.0 : 48.0;
    final fontSize = isSmallScreen ? 12.0 : (isLargeScreen ? 14.0 : 13.0);
    final iconSize = isSmallScreen ? 16.0 : (isLargeScreen ? 20.0 : 18.0);

    final items = [
      _MenuItem(
        icon: Icons.report,
        label: 'Raportează o grilă',
        onTap: () => print('Raportează o grilă tapped'),
      ),
      _MenuItem(
        icon: Icons.book,
        label: 'Consultă codul civil',
        onTap: () => print('Consultă codul civil tapped'),
      ),
      _MenuItem(
        icon: Icons.library_books,
        label: 'Consultă materia',
        onTap: () => print('Consultă materia tapped'),
      ),
      _MenuItem(
        icon: Icons.center_focus_strong,
        label: 'Modul focus',
        onTap: () => print('Modul focus tapped'),
      ),
      _MenuItem(
        icon: Icons.save,
        label: 'Salvează și continuă mai târziu',
        onTap: () => print('Salvează și continuă mai târziu tapped'),
      ),
      _MenuItem(
        icon: Icons.self_improvement,
        label: 'Concentrare',
        onTap: () => print('Concentrare tapped'),
      ),
      _MenuItem(
        icon: Icons.timer,
        label: 'Setează un timp',
        onTap: () => print('Setează un timp tapped'),
      ),
      _MenuItem(
        icon: widget.isDark ? Icons.light_mode : Icons.dark_mode,
        label: widget.isDark ? 'Mod luminos' : 'Mod întunecat',
        onTap: widget.onToggleTheme,
      ),
    ];

    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: modalWidth,
                height: modalHeight,
                margin: EdgeInsets.symmetric(horizontal: isLargeScreen ? 24 : 12),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.grey[900]!.withOpacity(0.85)
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: widget.isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isDark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Meniu',
                        style: GoogleFonts.poppins(
                          fontSize: isLargeScreen ? 18 : 16,
                          fontWeight: FontWeight.w600,
                          color: widget.isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        physics: const BouncingScrollPhysics(),
                        cacheExtent: modalHeight,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _MenuItemTile(
                            item: item,
                            gradient: _iconGradients[index % _iconGradients.length],
                            fontSize: fontSize,
                            iconSize: iconSize,
                            itemHeight: itemHeight,
                            isDark: widget.isDark,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              item.onTap();
                              widget.onClose();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItemTile extends StatefulWidget {
  final _MenuItem item;
  final LinearGradient gradient;
  final double fontSize;
  final double iconSize;
  final double itemHeight;
  final bool isDark;
  final VoidCallback onTap;

  const _MenuItemTile({
    required this.item,
    required this.gradient,
    required this.fontSize,
    required this.iconSize,
    required this.itemHeight,
    required this.isDark,
    required this.onTap,
  });

  @override
  _MenuItemTileState createState() => _MenuItemTileState();
}

class _MenuItemTileState extends State<_MenuItemTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: widget.itemHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.gradient,
                  boxShadow: [
                    BoxShadow(
                      color: widget.isDark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  widget.item.icon,
                  size: widget.iconSize,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: GoogleFonts.roboto(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w600,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _MenuItem({required this.icon, required this.label, required this.onTap});
}

class TestPage extends StatefulWidget {
  final String testTitle;
  final List<Question> questions;

  const TestPage({
    Key? key,
    required this.testTitle,
    required this.questions,
  }) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late List<bool> _answeredQuestions;
  late List<List<String>> _selectedAnswers;
  bool _showExplanations = false;
  bool _isFinishing = false;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  double _score = 0.0;
  bool _isBreathingActive = false;
  int _breathCount = 0;
  bool _showTools = false;
  bool _isDarkMode = false;
  int _selectedTheme = 0;

  final List<List<Color>> themeColors = [
    [Colors.purple.shade200, Colors.pink.shade200], // Default
    [Colors.black, Colors.grey.shade800], // Dark
    [Colors.blue.shade300, Colors.cyan.shade300], // Ocean
    [Colors.green.shade300, Colors.teal.shade300], // Forest
    [Colors.orange.shade300, Colors.amber.shade300], // Sunset
    [Colors.indigo.shade300, Colors.blue.shade300], // Night Sky
  ];

  List<Color> get currentThemeColors => themeColors[_selectedTheme];
  Color get backgroundColor => _isDarkMode ? Colors.grey.shade900 : Colors.white;
  Color get textColor => _isDarkMode ? Colors.white : Colors.black87;
  Color get secondaryTextColor => _isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600;

  bool get _canSubmitTest {
    return _selectedAnswers.every((answers) => answers.isNotEmpty);
  }

  void _submitTest() {
    if (!_canSubmitTest) return;

    int correct = 0;
    int wrong = 0;

    for (int i = 0; i < widget.questions.length; i++) {
      final currentQuestion = widget.questions[i];
      final selectedAnswers = _selectedAnswers[i];
      final correctAnswers = currentQuestion.correctAnswers;

      bool isCorrect = selectedAnswers.length == correctAnswers.length &&
          selectedAnswers.every((answer) => correctAnswers.contains(answer));

      if (isCorrect) {
        correct++;
      } else {
        wrong++;
      }
    }

    setState(() {
      _correctAnswers = correct;
      _wrongAnswers = wrong;
      _score = (correct / widget.questions.length) * 10;
      _showExplanations = true;
    });

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _answeredQuestions = List.filled(widget.questions.length, false);
    _selectedAnswers = List.generate(widget.questions.length, (_) => []);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDarkMode() {
    setState(() => _isDarkMode = !_isDarkMode);
    _showTools = false;
  }

  void _changeTheme(int index) {
    setState(() => _selectedTheme = index);
    _showTools = false;
  }

  void _handleAnswer(int questionIndex, String letter) {
    if (_answeredQuestions[questionIndex]) return;

    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedAnswers[questionIndex].contains(letter)) {
        _selectedAnswers[questionIndex].remove(letter);
      } else {
        if (_selectedAnswers[questionIndex].length < 2) {
          _selectedAnswers[questionIndex].add(letter);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                if (_showExplanations) _buildTestResults(),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: widget.questions.length,
                    itemBuilder: (context, index) {
                      return _buildQuestionCard(widget.questions[index], index);
                    },
                  ),
                ),
              ],
            ),
            if (_showTools) _buildToolsOverlay(),
            if (!_showExplanations) _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildBackButton(),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.testTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: currentThemeColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.auto_awesome, color: Colors.white),
                  onPressed: () => setState(() => _showTools = !_showTools),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: currentThemeColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_score.toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: _isDarkMode ? Colors.grey[800]! : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.arrow_back_ios_new, size: 20, color: textColor),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final answeredCount = _answeredQuestions.where((x) => x).length;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 6,
              width: constraints.maxWidth * (answeredCount / widget.questions.length),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: currentThemeColors,
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: currentThemeColors[0].withOpacity(0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTestResults() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: currentThemeColors.map((c) => c.withOpacity(0.1)).toList(),
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: currentThemeColors[0].withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Nota finală: ',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: currentThemeColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _score.toStringAsFixed(2),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatistic(
                icon: Icons.check_circle,
                color: Colors.green,
                label: 'Corecte',
                value: _correctAnswers,
              ),
              _buildStatistic(
                icon: Icons.cancel,
                color: Colors.red,
                label: 'Greșite',
                value: _wrongAnswers,
              ),
              _buildStatistic(
                icon: Icons.quiz,
                color: Colors.blue,
                label: 'Total',
                value: widget.questions.length,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistic({
    required IconData icon,
    required Color color,
    required String label,
    required int value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _canSubmitTest ? _submitTest : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: currentThemeColors[0],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Verifică testul',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Question question, int index) {
    final selectedAnswers = _selectedAnswers[index];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
              ),
              boxShadow: [
                BoxShadow(
                  color: currentThemeColors[0].withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 12, top: 4),
                      child: Text(
                        '${question.id}.',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        question.text,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  children: question.answers.map((answer) {
                    final isSelected = selectedAnswers.contains(answer.letter);
                    final isCorrect = _showExplanations && question.correctAnswers.contains(answer.letter);
                    final isWrong = _showExplanations && isSelected && !isCorrect;

                    return GestureDetector(
                      onTap: _showExplanations ? null : () => _handleAnswer(index, answer.letter),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: isSelected || isCorrect || isWrong
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isCorrect
                                      ? [Colors.green.shade100, Colors.teal.shade100]
                                      : isWrong
                                          ? [Colors.red.shade100, Colors.orange.shade100]
                                          : currentThemeColors.map((c) => c.withOpacity(0.2)).toList(),
                                )
                              : null,
                          color: isSelected || isCorrect || isWrong ? null : backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCorrect
                                ? Colors.green.shade300
                                : isWrong
                                    ? Colors.red.shade300
                                    : isSelected
                                        ? currentThemeColors[0]
                                        : _isDarkMode
                                            ? Colors.grey[800]!
                                            : Colors.grey[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected || isCorrect || isWrong
                                    ? Colors.white.withOpacity(0.9)
                                    : _isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.grey[100],
                                border: Border.all(
                                  color: isCorrect
                                      ? Colors.green.shade300
                                      : isWrong
                                          ? Colors.red.shade300
                                          : isSelected
                                              ? currentThemeColors[0]
                                              : _isDarkMode
                                                  ? Colors.grey[700]!
                                                  : Colors.grey[300]!,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  answer.letter,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isCorrect
                                        ? Colors.green.shade700
                                        : isWrong
                                            ? Colors.red.shade700
                                            : isSelected
                                                ? currentThemeColors[0]
                                                : _isDarkMode
                                                    ? Colors.grey[300]
                                                    : Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                answer.text,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  height: 1.4,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (_showExplanations && question.explanation.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.grey[850] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explicație:',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          question.explanation,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.5,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsOverlay() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        color: backgroundColor,
        child: Container(
          width: 280,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                backgroundColor,
                _isDarkMode ? Colors.black : Colors.grey.shade50,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Instrumente',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              const Divider(height: 1),
              _buildToolButton(
                icon: _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                text: _isDarkMode ? 'Mod luminos' : 'Mod întunecat',
                description: 'Schimbă aspectul aplicației',
                onTap: _toggleDarkMode,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temă culori',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Personalizează aspectul testului',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: themeColors.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _changeTheme(index),
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: themeColors[index],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedTheme == index
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: themeColors[index][0].withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: _selectedTheme == index
                                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              _buildToolButton(
                icon: Icons.self_improvement,
                text: 'Respirație',
                description: 'Exercițiu de respirație pentru focus',
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (context, _, __) => _BreathingExercise(
                        onClose: () => Navigator.of(context).pop(),
                      ),
                    ),
                  );
                },
              ),
              _buildToolButton(
                icon: Icons.bookmark_outlined,
                text: 'Salvează progresul',
                description: 'Continuă mai târziu de unde ai rămas',
                onTap: () {},
              ),
              _buildToolButton(
                icon: Icons.flag_outlined,
                text: 'Raportează grila',
                description: 'Ajută-ne să îmbunătățim conținutul',
                onTap: () {},
              ),
              _buildToolButton(
                icon: Icons.share_outlined,
                text: 'Distribuie',
                description: 'Împărtășește cu colegii tăi',
                onTap: () {
                  Share.share('Încearcă această grilă din aplicația StartJuris!');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String text,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: currentThemeColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: secondaryTextColor,
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
  }
}

class _BreathingExercise extends StatefulWidget {
  final VoidCallback onClose;
  const _BreathingExercise({required this.onClose});

  @override
  _BreathingExerciseState createState() => _BreathingExerciseState();
}

class _BreathingExerciseState extends State<_BreathingExercise> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _currentPhase = 0;
  final List<String> _phases = ['Inspiră', 'Ține', 'Expiră', 'Ține'];
  final List<int> _durations = [4, 4, 4, 4];
  int _remainingTime = 4;
  int _completedCycles = 0;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed && _currentPhase == 0) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isActive = true;
      _remainingTime = _durations[_currentPhase];
    });
    _controller.forward();
    _updateTimer();
  }

  void _updateTimer() {
    if (!_isActive) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _remainingTime--;
        if (_remainingTime <= 0) {
          _currentPhase = (_currentPhase + 1) % 4;
          if (_currentPhase == 0) {
            _completedCycles++;
          }
          _remainingTime = _durations[_currentPhase];
          if (_currentPhase == 0 || _currentPhase == 2) {
            _controller.forward();
          }
        }
      });
      _updateTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Exercițiu de respirație',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.purple.shade200, Colors.pink.shade200],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _remainingTime.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  _phases[_currentPhase],
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cicluri completate: $_completedCycles',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isActive)
                      ElevatedButton(
                        onPressed: _startBreathing,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Începe',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (_isActive)
                      ElevatedButton(
                        onPressed: widget.onClose,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Închide',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}