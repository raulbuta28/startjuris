// filename: teme.dart
// ────────────────────────────────────────────────────────────────────────────
// IMPORTURI
// ────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../testegrile/test_page_new.dart';
import 'models.dart'; // Answer, Question
import '../../../services/tests_service.dart';

// ────────────────────────────────────────────────────────────────────────────
// CONSTANTE & STILURI
// ────────────────────────────────────────────────────────────────────────────
const Color kPrimaryPastel = Color(0xFFB7E4F7); // cyan pal
const Color kSecondaryPastel = Color(0xFFE3D7F3); // lila pal

LinearGradient get pastelGradient =>
    const LinearGradient(colors: [kPrimaryPastel, kSecondaryPastel]);

TextStyle tabTextStyle(bool selected) => GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: selected ? Colors.black : Colors.grey[600],
    );

// ────────────────────────────────────────────────────────────────────────────
// 1. PROVIDER PENTRU TEMA
// ────────────────────────────────────────────────────────────────────────────
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData => _isDarkMode ? _darkTheme : _lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

final _lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  textTheme: GoogleFonts.poppinsTextTheme(),
  colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryPastel),
);

final _darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212),
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
  colorScheme:
      ColorScheme.fromSeed(seedColor: kSecondaryPastel, brightness: Brightness.dark),
);

// ────────────────────────────────────────────────────────────────────────────
// 2. STRUCTURI
// ────────────────────────────────────────────────────────────────────────────
class TemaItem {
  final String title;
  final List<Question> questions;
  final int order;
  const TemaItem({required this.title, required this.questions, required this.order});
}

const _sampleQuestions = [
  Question(
    id: 1,
    text: 'Care este definiția proprietății private?',
    answers: [
      Answer(letter: 'A', text: 'Dreptul de a dispune și folosi un bun'),
      Answer(letter: 'B', text: 'Dreptul statului asupra bunurilor'),
      Answer(letter: 'C', text: 'Dreptul comunității de a gestiona un bun'),
    ],
    correctAnswers: ['A'],
    explanation:
        'Proprietatea privată reprezintă dreptul subiectiv al titularului de a deține, folosi și dispune de bun în mod exclusiv.',
  ),
];

const _placeholderQuestions = [
  Question(
    id: 1,
    text: 'Întrebare generică despre tema respectivă?',
    answers: [
      Answer(letter: 'A', text: 'Răspuns A'),
      Answer(letter: 'B', text: 'Răspuns B'),
      Answer(letter: 'C', text: 'Răspuns C'),
    ],
    correctAnswers: ['A'],
    explanation: 'Explicație generică pentru tema respectivă.',
    note: "",
  ),
];

// ────────────────────────────────────────────────────────────────────────────
// 3. LISTA TEME – Populată din API
// ────────────────────────────────────────────────────────────────────────────
List<Map<String, dynamic>> _teme = [];

// ────────────────────────────────────────────────────────────────────────────
// 4. WIDGET TAB PERSONALIZAT
// ────────────────────────────────────────────────────────────────────────────
class _CustomTab extends StatelessWidget {
  const _CustomTab({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// 5. PAGINA PRINCIPALĂ
// ────────────────────────────────────────────────────────────────────────────
class TemePage extends StatefulWidget {
  final String exam;
  const TemePage({super.key, required this.exam});

  @override
  State<TemePage> createState() => _TemePageState();
}

class _TemePageState extends State<TemePage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _selectedIndex = 0;
  final _scrollController = ScrollController();
  final Map<String, Map<String, dynamic>> _progressData = {};

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProgress();
  }

  Future<void> _loadTests() async {
    final fetched = await TestsService.fetchTests();
    final filtered = fetched.where((t) => t.categories.contains(widget.exam)).toList();
    final Map<String, List<TemaItem>> bySubject = {};
    for (final t in filtered) {
      final item = TemaItem(title: t.name, questions: t.questions, order: t.order);
      bySubject.putIfAbsent(t.subject, () => []).add(item);
    }
    for (final list in bySubject.values) {
      list.sort((a, b) => a.order.compareTo(b.order));
    }
    setState(() {
      _teme = bySubject.entries
          .map((e) => {
                'header': e.key,
                'subheaders': [
                  {'title': null, 'themes': e.value}
                ],
              })
          .toList();
      _tabController = TabController(length: _teme.length, vsync: this);
      _tabController!.addListener(() {
        if (_tabController!.indexIsChanging) {
          setState(() => _selectedIndex = _tabController!.index);
        }
      });
      _loadProgress();
    });
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, Map<String, dynamic>> data = {};
    for (final tema in _teme) {
      final sub = tema['subheaders'] as List<dynamic>;
      for (final sh in sub) {
        final themes = sh['themes'] as List<TemaItem>;
        for (final t in themes) {
          final titleKey = t.title.replaceAll(' ', '_');
          data[t.title] = {
            'progress': prefs.getInt('test_${titleKey}_index') ?? 0,
            'completed': prefs.getBool('test_${titleKey}_completed') ?? false,
            'score': prefs.getDouble('test_${titleKey}_score') ?? 0.0,
            'completedAt': prefs.getInt('test_${titleKey}_completedAt'),
          };
        }
      }
    }
    setState(() => _progressData.addAll(data));
  }


  @override
  void dispose() {
    _tabController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 3.0, color: Colors.purple.shade300),
                insets: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
              tabs: _teme.map((tema) => Tab(text: tema['header'] as String)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _teme.map((tema) => _buildThemeSection(tema)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection(Map<String, dynamic> tema) {
    final List<Map<String, dynamic>> themes = [];
    final subheaders = tema['subheaders'] as List<Map<String, dynamic>>;
    
    for (var subheader in subheaders) {
      final themesList = subheader['themes'] as List<TemaItem>;
      for (var theme in themesList) {
        final prog = _progressData[theme.title] ?? {};
        themes.add({
          'title': theme.title,
          'questions': theme.questions,
          'progress': prog['progress'] ?? 0,
          'completed': prog['completed'] ?? false,
          'score': prog['score'] ?? 0.0,
          'completedAt': prog['completedAt'],
        });
      }
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text(
              tema['header'] as String,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final theme = themes[index];
                return _ThemeCard(
                  theme: theme,
                  color: _getThemeColor(index),
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    await Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => TestPage(
                          testTitle: theme['title'],
                          questions: theme['questions'],
                        ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 1.0);
                          const end = Offset.zero;
                          const curve = Curves.easeOutCubic;
                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(position: offsetAnimation, child: child);
                        },
                      ),
                    );
                    _loadProgress();
                  },
                );
              },
              childCount: themes.length,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
      ],
    );
  }

  Color _getThemeColor(int index) {
    final colors = [
      Color(0xFFE3F2FD),
      Color(0xFFF3E5F5),
      Color(0xFFFCE4EC),
      Color(0xFFF1F8E9),
      Color(0xFFE8EAF6),
      Color(0xFFE0F7FA),
      Color(0xFFFFF3E0),
      Color(0xFFE8F5E9),
    ];
    return colors[index % colors.length];
  }
}

class _ThemeCard extends StatefulWidget {
  final Map<String, dynamic> theme;
  final Color color;
  final VoidCallback onTap;

  const _ThemeCard({
    Key? key,
    required this.theme,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_ThemeCard> createState() => _ThemeCardState();
}

class _ThemeCardState extends State<_ThemeCard> with SingleTickerProviderStateMixin {
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

  String _getThemeNumber() {
    final parts = widget.theme['title'] as String;
    return parts.split(' - ')[0].replaceAll('Tema ', '');
  }

  String _getThemeTitle() {
    final parts = widget.theme['title'] as String;
    return parts.split(' - ').length > 1 ? parts.split(' - ')[1] : parts.split(' - ')[0];
  }

  @override
  Widget build(BuildContext context) {
    final int progress = widget.theme['progress'] as int? ?? 0;
    final bool completed = widget.theme['completed'] as bool? ?? false;
    final double score = widget.theme['score'] as double? ?? 0.0;
    final int? completedAt = widget.theme['completedAt'] as int?;
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Transform.rotate(
                  angle: 0.2,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              if (completed || progress > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: completed ? Colors.green : Colors.orange,
                      ),
                    ),
                    child: Icon(
                      completed ? Icons.check : Icons.play_arrow,
                      size: 16,
                      color: completed ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getThemeNumber(),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Text(
                        _getThemeTitle(),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (progress > 0 && !completed)
                      Text(
                        'Ai rămas la grila $progress, continuă te rog..',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    if (completed)
                      Text(
                        'Nota ${score.toStringAsFixed(2)} - ${completedAt != null ? DateFormat('dd.MM.yyyy').format(DateTime.fromMillisecondsSinceEpoch(completedAt)) : ''}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.green.shade700,
                        ),
                      ),
                    if (progress > 0 || completed)
                      const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.quiz_outlined,
                                size: 14,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.theme['questions'].length}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.black54,
                        ),
                      ],
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

// ────────────────────────────────────────────────────────────────────────────
// 6. HELPER
// ────────────────────────────────────────────────────────────────────────────
List<Map<String, dynamic>> _filterCategories(List<String> headers) =>
    _teme.where((cat) => headers.contains(cat['header'] as String)).toList();

// ────────────────────────────────────────────────────────────────────────────
// 7. MAIN
// ────────────────────────────────────────────────────────────────────────────
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, p, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Teme App',
        theme: p.themeData,
        home: const TemePage(exam: 'INM'),
      ),
    );
  }
}