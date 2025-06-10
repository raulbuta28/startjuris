// filename: testesuplimentare.dart
// ────────────────────────────────────────────────────────────────────────────
// IMPORTURI
// ────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'models.dart';   // Answer, Question
import 'testesuplimentare2.dart';    // TestPage
import 'teme.dart' show ThemeProvider;

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
// 1. STRUCTURI
// ────────────────────────────────────────────────────────────────────────────
class TemaItem {
  final String title;
  final List<Question> questions;
  const TemaItem({required this.title, required this.questions});
}

const _placeholderQuestions = [
  Question(
    id: 1,
    text: 'Întrebare generică pentru testul suplimentar?',
    answers: [
      Answer(letter: 'A', text: 'Răspuns A'),
      Answer(letter: 'B', text: 'Răspuns B'),
      Answer(letter: 'C', text: 'Răspuns C'),
    ],
    correctAnswers: ['A'],
    explanation: 'Explicație generică pentru testul suplimentar.',
    note: "",
  ),
];

// ────────────────────────────────────────────────────────────────────────────
// 2. LISTA TESTE SUPLIMENTARE
// ────────────────────────────────────────────────────────────────────────────
final List<Map<String, dynamic>> _teme = [
  // Drept civil
  {
    'header': 'Drept civil',
    'subheaders': [
      {
        'title': 'Teste suplimentare',
        'themes': List.generate(
          30,
          (index) => TemaItem(
            title: 'Test suplimentar - ${index + 1}',
            questions: _placeholderQuestions,
          ),
        ),
      },
    ],
  },
  // Drept procesual civil
  {
    'header': 'Drept procesual civil',
    'subheaders': [
      {
        'title': 'Teste suplimentare',
        'themes': List.generate(
          30,
          (index) => TemaItem(
            title: 'Test suplimentar - ${index + 1}',
            questions: _placeholderQuestions,
          ),
        ),
      },
    ],
  },
  // Drept penal
  {
    'header': 'Drept penal',
    'subheaders': [
      {
        'title': 'Teste suplimentare',
        'themes': List.generate(
          30,
          (index) => TemaItem(
            title: 'Test suplimentar - ${index + 1}',
            questions: _placeholderQuestions,
          ),
        ),
      },
    ],
  },
  // Drept procesual penal
  {
    'header': 'Drept procesual penal',
    'subheaders': [
      {
        'title': 'Teste suplimentare',
        'themes': List.generate(
          30,
          (index) => TemaItem(
            title: 'Test suplimentar - ${index + 1}',
            questions: _placeholderQuestions,
          ),
        ),
      },
    ],
  },
];

// ────────────────────────────────────────────────────────────────────────────
// 3. PAGINA PRINCIPALĂ
// ────────────────────────────────────────────────────────────────────────────
class TesteSupPage extends StatefulWidget {
  const TesteSupPage({super.key});

  @override
  State<TesteSupPage> createState() => _TesteSupPageState();
}

class _TesteSupPageState extends State<TesteSupPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _teme.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _selectedIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _getThemeColor(int index) {
    final colors = [
      Colors.purple.shade300,
      Colors.blue.shade300,
      Colors.green.shade300,
      Colors.orange.shade300,
      Colors.pink.shade300,
      Colors.teal.shade300,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
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
        themes.add({
          'title': theme.title,
          'questions': theme.questions,
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
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => TestPage(
                          testTitle: theme['title'],
                          questions: theme['questions'],
                        ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 1.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOutCubic;
                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(position: offsetAnimation, child: child);
                        },
                      ),
                    );
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
}

// ────────────────────────────────────────────────────────────────────────────
// 4. CARD PENTRU TEMĂ
// ────────────────────────────────────────────────────────────────────────────
class _ThemeCard extends StatelessWidget {
  final Map<String, dynamic> theme;
  final Color color;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Test suplimentar',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                theme['title'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.question_answer_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${(theme['questions'] as List).length} întrebări',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// 8. MAIN
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
        title: 'Teste Suplimentare App',
        theme: p.themeData,
        home: const TesteSupPage(),
      ),
    );
  }
}