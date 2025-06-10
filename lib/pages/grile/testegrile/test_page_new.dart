import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../admitereinm/models.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  double _progress = 0.0;
  bool _isBreathingActive = false;
  int _breathCount = 0;
  bool _showTools = false;
  bool _isDarkMode = false;
  int _selectedTheme = 0;
  bool _hasSavedProgress = false;

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
      _score = (correct / widget.questions.length) * 10; // Calculăm nota din 10
      _showExplanations = true;
      _progress = 1.0;
      _hasSavedProgress = true;
    });

    _saveCompleted();

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  Future<void> _saveCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final key = widget.testTitle.replaceAll(' ', '_');
    await prefs.setBool('test_${key}_completed', true);
    await prefs.setDouble('test_${key}_score', _score);
    await prefs.setInt('test_${key}_completedAt', DateTime.now().millisecondsSinceEpoch);
    await prefs.remove('test_${key}_answers');
    await prefs.remove('test_${key}_index');
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final key = widget.testTitle.replaceAll(' ', '_');
    await prefs.setString('test_${key}_answers', jsonEncode(_selectedAnswers));
    int nextIndex = _selectedAnswers.indexWhere((a) => a.isEmpty);
    if (nextIndex == -1) nextIndex = widget.questions.length;
    await prefs.setInt('test_${key}_index', nextIndex);
    await prefs.setBool('test_${key}_completed', false);
    setState(() {
      _hasSavedProgress = true;
    });
  }

  Future<void> _loadSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final key = widget.testTitle.replaceAll(' ', '_');
    final saved = prefs.getString('test_${key}_answers');
    final completed = prefs.getBool('test_${key}_completed') ?? false;
    _hasSavedProgress = saved != null || completed;
    if (saved != null) {
      final decoded = jsonDecode(saved) as List<dynamic>;
      _selectedAnswers = decoded
          .map<List<String>>((e) => List<String>.from(e as List))
          .toList();
      _answeredQuestions =
          _selectedAnswers.map((e) => e.isNotEmpty).toList();
      _progress =
          _selectedAnswers.where((a) => a.isNotEmpty).length / widget.questions.length;
    }
  }

  Future<void> _restartTest() async {
    final prefs = await SharedPreferences.getInstance();
    final key = widget.testTitle.replaceAll(' ', '_');
    await prefs.remove('test_${key}_answers');
    await prefs.remove('test_${key}_index');
    await prefs.remove('test_${key}_completed');
    await prefs.remove('test_${key}_score');
    await prefs.remove('test_${key}_completedAt');
    setState(() {
      _answeredQuestions = List.filled(widget.questions.length, false);
      _selectedAnswers = List.generate(widget.questions.length, (_) => []);
      _progress = 0.0;
      _showExplanations = false;
      _hasSavedProgress = false;
    });
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
    _progress = 0.0;
    _loadSavedProgress();
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
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedAnswers[questionIndex].contains(letter)) {
        _selectedAnswers[questionIndex].remove(letter);
      } else {
        _selectedAnswers[questionIndex].add(letter);
      }
      _answeredQuestions[questionIndex] =
          _selectedAnswers[questionIndex].isNotEmpty;
      _progress = _selectedAnswers
              .where((answers) => answers.isNotEmpty)
              .length /
          widget.questions.length;
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
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: widget.questions.length + (_showExplanations ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_showExplanations && index == 0) {
                        return _buildTestResults();
                      }
                      final qIndex = _showExplanations ? index - 1 : index;
                      return _buildQuestionCard(widget.questions[qIndex], qIndex);
                    },
                  ),
                ),
              ],
            ),
            if (_showTools) _buildToolsOverlay(),
            if (!_showExplanations) _buildSubmitButton(),
            if (_hasSavedProgress) _buildRestartButton(),
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
                  '${(_progress * 100).toStringAsFixed(0)}%',
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

  Widget _buildRestartButton() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: _showExplanations ? 16 : 72,
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _restartTest,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.grey.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Începe din nou',
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
                      onTap: _showExplanations ? null : () {
                        setState(() {
                          if (isSelected) {
                            _selectedAnswers[index].remove(answer.letter);
                          } else {
                            _selectedAnswers[index].add(answer.letter);
                          }
                        });
                      },
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
                if (question.note.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.info_outline,
                            size: 14, color: secondaryTextColor),
                        const SizedBox(width: 4),
                        Text(
                          'Nota: ${question.note}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_showExplanations)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: currentThemeColors.map((c) => c.withOpacity(0.1)).toList(),
                      ),
                      borderRadius: BorderRadius.circular(20),
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
                                color: currentThemeColors[0],
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Explicație',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: currentThemeColors[0],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          question.explanation,
                          textAlign: TextAlign.justify,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            height: 1.6,
                            color: textColor,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                onTap: () {},
              ),
              _buildToolButton(
                icon: Icons.bookmark_outlined,
                text: 'Salvează progresul',
                description: 'Continuă mai târziu de unde ai rămas',
                onTap: _saveProgress,
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
                onTap: () {},
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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: currentThemeColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: Colors.white),
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
    );
  }
} 