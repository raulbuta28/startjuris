import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'teme.dart' show ThemeProvider;

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
  late PageController _pageController;
  late AnimationController _animationController;
  late List<bool> _answeredQuestions;
  late List<List<String>> _selectedAnswers;
  int _currentIndex = 0;
  bool _showExplanation = false;
  bool _isFinishing = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _answeredQuestions = List.filled(widget.questions.length, false);
    _selectedAnswers = List.generate(widget.questions.length, (_) => []);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleAnswer(String letter) {
    if (_answeredQuestions[_currentIndex]) return;

    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedAnswers[_currentIndex].contains(letter)) {
        _selectedAnswers[_currentIndex].remove(letter);
      } else {
        _selectedAnswers[_currentIndex].add(letter);
      }
    });
  }

  void _submitAnswer() {
    if (_answeredQuestions[_currentIndex]) return;

    setState(() {
      _answeredQuestions[_currentIndex] = true;
      _showExplanation = true;
    });
    HapticFeedback.mediumImpact();
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else if (!_isFinishing) {
      setState(() => _isFinishing = true);
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                        _showExplanation = _answeredQuestions[index];
                      });
                    },
                    itemCount: widget.questions.length,
                    itemBuilder: (context, index) {
                      return _buildQuestionPage(widget.questions[index]);
                    },
                  ),
                ),
              ],
            ),
            if (_isFinishing) _buildFinishOverlay(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNavigation(),
            ),
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
        color: Colors.white,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.testTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Întrebarea ${_currentIndex + 1} din ${widget.questions.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
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
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: constraints.maxWidth * ((_currentIndex + 1) / widget.questions.length),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.pink.shade400],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.shade200.withOpacity(0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionPage(Question question) {
    final isAnswered = _answeredQuestions[_currentIndex];
    final selectedAnswers = _selectedAnswers[_currentIndex];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildQuestionCard(question),
          const SizedBox(height: 16),
          _buildAnswersList(question, isAnswered, selectedAnswers),
          if (_showExplanation) ...[
            const SizedBox(height: 16),
            _buildExplanationCard(question),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade100.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 16,
                  color: Colors.purple.shade400,
                ),
                const SizedBox(width: 6),
                Text(
                  'Întrebarea ${_currentIndex + 1}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple.shade400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            question.text,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswersList(Question question, bool isAnswered, List<String> selectedAnswers) {
    return Column(
      children: question.answers.map((answer) {
        final isSelected = selectedAnswers.contains(answer.letter);
        final isCorrect = isAnswered && question.correctAnswers.contains(answer.letter);
        final isWrong = isAnswered && isSelected && !isCorrect;

        return _AnswerCard(
          letter: answer.letter,
          text: answer.text,
          isSelected: isSelected,
          isCorrect: isCorrect,
          isWrong: isWrong,
          isAnswered: isAnswered,
          onTap: () => _handleAnswer(answer.letter),
        );
      }).toList(),
    );
  }

  Widget _buildExplanationCard(Question question) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: 0, end: 1),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple.shade50,
                Colors.pink.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.shade100.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.lightbulb_outline,
                      color: Colors.purple.shade400,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Explicație',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                question.explanation,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.purple.shade900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentIndex > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousQuestion,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Anterior',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (_currentIndex > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _answeredQuestions[_currentIndex]
                    ? _nextQuestion
                    : _submitAnswer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _answeredQuestions[_currentIndex]
                      ? 'Următoarea'
                      : 'Verifică',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishOverlay() {
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: Colors.purple.shade400,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Felicitări!',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ai finalizat toate întrebările din acest test.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
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
          ),
        ),
      ),
    );
  }
}

class _AnswerCard extends StatefulWidget {
  final String letter;
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool isAnswered;
  final VoidCallback onTap;

  const _AnswerCard({
    Key? key,
    required this.letter,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.isAnswered,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<_AnswerCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
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

  Color _getBackgroundColor() {
    if (!widget.isAnswered) {
      return widget.isSelected ? Colors.purple.shade50 : Colors.white;
    }
    if (widget.isCorrect) return Colors.green.shade50;
    if (widget.isWrong) return Colors.red.shade50;
    return Colors.white;
  }

  LinearGradient? _getGradient() {
    if (!widget.isAnswered) {
      if (widget.isSelected) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade50,
            Colors.pink.shade50,
          ],
        );
      }
      return null;
    }
    if (widget.isCorrect) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.green.shade50,
          Colors.teal.shade50,
        ],
      );
    }
    if (widget.isWrong) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.red.shade50,
          Colors.orange.shade50,
        ],
      );
    }
    return null;
  }

  Color _getBorderColor() {
    if (!widget.isAnswered) {
      return widget.isSelected ? Colors.purple.shade200 : Colors.grey.shade200;
    }
    if (widget.isCorrect) return Colors.green.shade200;
    if (widget.isWrong) return Colors.red.shade200;
    return Colors.grey.shade200;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTapDown: widget.isAnswered ? null : (_) => _controller.forward(),
        onTapUp: widget.isAnswered ? null : (_) => _controller.reverse(),
        onTapCancel: widget.isAnswered ? null : () => _controller.reverse(),
        onTap: widget.isAnswered ? null : widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: widget.isAnswered ? 1.0 : _scaleAnimation.value,
            child: child,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: _getGradient(),
              color: _getGradient() == null ? _getBackgroundColor() : null,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _getBorderColor()),
              boxShadow: [
                BoxShadow(
                  color: _getBorderColor().withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildLetterBadge(),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.text,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (widget.isAnswered) _buildResultIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLetterBadge() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.isSelected
            ? (widget.isCorrect
                ? Colors.green.shade100
                : widget.isWrong
                    ? Colors.red.shade100
                    : Colors.purple.shade100)
            : Colors.grey.shade100,
        border: Border.all(
          color: widget.isSelected
              ? (widget.isCorrect
                  ? Colors.green.shade300
                  : widget.isWrong
                      ? Colors.red.shade300
                      : Colors.purple.shade300)
              : Colors.grey.shade300,
        ),
      ),
      child: Center(
        child: Text(
          widget.letter,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: widget.isSelected
                ? (widget.isCorrect
                    ? Colors.green.shade700
                    : widget.isWrong
                        ? Colors.red.shade700
                        : Colors.purple.shade700)
                : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildResultIcon() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: widget.isCorrect
          ? Icon(
              Icons.check_circle,
              color: Colors.green.shade400,
              size: 24,
            )
          : widget.isWrong
              ? Icon(
                  Icons.cancel,
                  color: Colors.red.shade400,
                  size: 24,
                )
              : const SizedBox(width: 24),
    );
  }
}