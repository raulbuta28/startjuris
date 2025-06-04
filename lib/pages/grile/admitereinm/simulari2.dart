// filename: simulari2.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'package:share_plus/share_plus.dart';
import 'simulari.dart' show ThemeProvider;

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

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _MenuItemTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: itemHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: Colors.white, size: iconSize),
              ),
              const SizedBox(width: 16),
              Text(
                item.label,
                style: GoogleFonts.poppins(
                  fontSize: fontSize,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
  bool _showBreathingExercise = false;

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

  void _startBreathingExercise() {
    setState(() => _showBreathingExercise = true);
  }

  void _stopBreathingExercise() {
    setState(() => _showBreathingExercise = false);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showBreathingExercise) {
      return _BreathingExercise(
        onClose: _stopBreathingExercise,
        isDark: widget.isDark,
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isLargeScreen = screenWidth > 600;

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
        label: 'Exercițiu de respirație',
        onTap: _startBreathingExercise,
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

class SimularePage extends StatefulWidget {
  final String simulareTitle;
  final List<Question> questions;
  const SimularePage({
    super.key,
    required this.simulareTitle,
    required this.questions,
  });

  @override
  State<SimularePage> createState() => _SimularePageState();
}

class _SimularePageState extends State<SimularePage> {
  final Map<int, Set<String>> _selectedAnswers = {};
  int _fontScale = 1;
  bool _isMenuOpen = false;

  double _getQuestionFontSize() {
    switch (_fontScale) {
      case 0:
        return 14.0;
      case 1:
        return 16.0;
      case 2:
        return 18.0;
      case 3:
        return 20.0;
      case 4:
        return 22.0;
      default:
        return 16.0;
    }
  }

  double _getAnswerFontSize() {
    switch (_fontScale) {
      case 0:
        return 12.0;
      case 1:
        return 14.0;
      case 2:
        return 16.0;
      case 3:
        return 18.0;
      case 4:
        return 20.0;
      default:
        return 14.0;
    }
  }

  double _getLetterFontSize() {
    switch (_fontScale) {
      case 0:
        return 13.0;
      case 1:
        return 15.0;
      case 2:
        return 17.0;
      case 3:
        return 19.0;
      case 4:
        return 21.0;
      default:
        return 15.0;
    }
  }

  double _getLetterContainerSize() {
    switch (_fontScale) {
      case 0:
        return 20.0;
      case 1:
        return 22.0;
      case 2:
        return 24.0;
      case 3:
        return 26.0;
      case 4:
        return 28.0;
      default:
        return 22.0;
    }
  }

  final List<Question> _longQuestion = [
    Question(
      id: 1,
      text:
          'Ce este consimțământul în contextul actului juridic civil și ce vicii pot afecta validitatea acestuia?',
      answers: [
        Answer(
          letter: 'A',
          text:
              'Consimțământul este acordul de voință al părții la încheierea actului juridic. Viciile includ eroarea, dolul și violența. De exemplu, un contract semnat sub amenințare este invalid.',
        ),
        Answer(
          letter: 'B',
          text:
              'Consimțământul nu este obligatoriu pentru toate actele juridice, cum ar fi testamentul. Viciile pot fi ignorate dacă nu sunt demonstrate. Un contract fără consimțământ este valabil.',
        ),
        Answer(
          letter: 'C',
          text:
              'Consimțământul implică doar intenția de a încheia actul, fără a necesita capacitate. Viciile, precum eroarea, sunt rare. Un contract cu dol este valid dacă părțile agreează.',
        ),
      ],
      correctAnswers: ['A'],
      explanation:
          'Consimțământul este esențial și trebuie să fie liber. Viciile (eroare, dol, violența) anulează validitatea actului juridic.',
    ),
    Question(
      id: 2,
      text:
          'Explicați condițiile de validitate ale obiectului unui act juridic civil. Cum se determină dacă obiectul este licit și posibil? Includeți exemple practice și analizați impactul unui obiect ilicit asupra contractului.',
      answers: [
        Answer(
          letter: 'A',
          text:
              'Obiectul actului juridic trebuie să fie determinat, posibil, licit și moral. Licitatea este verificată conform legii, iar posibilitatea implică fezabilitatea fizică sau juridică. De exemplu, vânzarea unui bun furat este ilicită.',
        ),
        Answer(
          letter: 'B',
          text:
              'Obiectul nu trebuie să fie neapărat licit, dar trebuie să fie determinat. Posibilitatea nu este o condiție strictă. Un contract cu obiect ilicit este valabil dacă părțile agreează. De exemplu, un contract de închiriere este licit.',
        ),
        Answer(
          letter: 'C',
          text:
              'Obiectul actului juridic este valid dacă este specificat, indiferent de licitate. Un obiect ilicit nu afectează contractul. De exemplu, un contract de vânzare a unui bun inexistent este valabil dacă există acord.',
        ),
      ],
      correctAnswers: ['A'],
      explanation:
          'Obiectul trebuie să fie determinat, posibil, licit și moral. Un obiect ilicit duce la nulitatea contractului.',
    ),
    Question(
      id: 3,
      text:
          'Care sunt diferențele dintre actul juridic unilateral, bilateral și multilateral în dreptul civil român? Explicați situațiile practice în care fiecare tip de act este utilizat, oferind exemple concrete. Cum influențează numărul părților implicate structura și efectele juridice ale actului? Ce rol joacă principiul libertății contractuale?',
      answers: [
        Answer(
          letter: 'A',
          text:
              'Actul unilateral implică o singură voință (ex. testament), bilateralul necesită acordul a două părți (ex. vânzare), iar multilateralul implică mai multe părți (ex. asociere). Libertatea contractuală permite structurarea actului conform voinței părților, cu limitări legale.',
        ),
        Answer(
          letter: 'B',
          text:
              'Actul unilateral nu necesită acord (ex. donație), bilateralul implică o singură parte (ex. testament), iar multilateralul este rar. Libertatea contractuală nu se aplică actelor unilaterale. Structura actului nu depinde de numărul părților.',
        ),
        Answer(
          letter: 'C',
          text:
              'Toate actele juridice sunt bilaterale, indiferent de părți. Numărul părților nu influențează efectele. Libertatea contractuală este irelevantă. De exemplu, un contract de închiriere este unilateral dacă o parte nu semnează.',
        ),
      ],
      correctAnswers: ['A'],
      explanation:
          'Actele juridice diferă prin numărul părților implicate, influențând structura și efectele. Libertatea contractuală este limitată de lege.',
    ),
    Question(
      id: 4,
      text:
          'Analizați în detaliu principiul libertății contractuale în dreptul civil român, explicând cum permite părților să stabilească conținutul actelor juridice. Care sunt limitările legale ale acestui principiu, cum ar fi ordinea publică și bunele moravuri? Oferiți exemple de contracte care pot fi invalidate din cauza încălcării acestor limitări. Cum influențează capacitatea juridică a părților libertatea contractuală? Ce măsuri legale există pentru protejarea părților vulnerabile, cum ar fi minorii sau persoanele lipsite de discernământ, în contextul încheierii actelor juridice?',
      answers: [
        Answer(
          letter: 'A',
          text:
              'Libertatea contractuală permite părților să definească termenii actului juridic, dar este limitată de ordinea publică și bunele moravuri. De exemplu, un contract de vânzare a organelor este nul. Capacitatea juridică restricționează minorii, iar tutorele protejează persoanele vulnerabile.',
        ),
        Answer(
          letter: 'B',
          text:
              'Libertatea contractuală nu are limitări legale, iar ordinea publică nu afectează contractele. Capacitatea juridică este irelevantă. De exemplu, un contract semnat de un minor este valabil. Nu există măsuri pentru persoanele vulnerabile în dreptul civil.',
        ),
        Answer(
          letter: 'C',
          text:
              'Libertatea contractuală se aplică doar actelor unilaterale. Limitările legale sunt rare. De exemplu, un contract de muncă cu un minor este valid. Capacitatea juridică nu influențează contractele, iar protecția părților vulnerabile nu este reglementată.',
        ),
      ],
      correctAnswers: ['A'],
      explanation:
          'Libertatea contractuală este limitată de ordinea publică și bunele moravuri. Capacitatea juridică și măsurile de protecție asigură validitatea contractelor.',
    ),
    Question(
      id: 5,
      text:
          'În contextul dreptului civil român, care sunt principalele caracteristici ale actului juridic civil, incluzând elementele constitutive, condițiile de validitate, precum și efectele juridice generate de încheierea acestuia? Explicați în detaliu modul în care consimțământul, capacitate, obiectul și causa influențează validitatea actului juridic, oferind exemple practice pentru fiecare element. De asemenea, analizați diferențele dintre actul juridic unilateral, bilateral și multilateral, evidențiind situațiile în care fiecare tip de act este utilizat în practică. Cum se aplică principiul libertății contractuale în acest context, și ce limitări legale există pentru protejarea părților implicate într-un act juridic civil?',
      answers: [
        Answer(
          letter: 'A',
          text:
              'Actul juridic civil este o manifestare de voință destinată să producă efecte juridice, necesitând consimțământ liber, capacitate juridică, obiect determinat și cauză licită. Consimțământul trebuie să fie neviciat, iar capacitatea trebuie să respecte normele legale. De exemplu, un contract de vânzare necesită acordul ambelor părți.',
        ),
        Answer(
          letter: 'B',
          text:
              'Actele juridice unilaterale, precum testamentul, implică voința unei singure părți, spre deosebire de cele bilaterale, ca vânzarea, care necesită acordul a două părți. Actele multilaterale, precum asocierea, implică mai multe părți. Libertatea contractuală este limitată de ordinea publică.',
        ),
        Answer(
          letter: 'C',
          text:
              'Validitatea actului juridic depinde de respectarea condițiilor legale, iar efectele juridice pot include transferul drepturilor sau crearea obligațiilor. De exemplu, un contract de donație fără consimțământ valabil este nul. Limitările legale protejează părțile vulnerabile, cum ar fi minorii.',
        ),
      ],
      correctAnswers: ['A'],
      explanation:
          'Actul juridic civil trebuie să îndeplinească toate condițiile de validitate pentru a producă efecte juridice. Consimțământul, capacitatea, obiectul și causa sunt esențiale.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          _buildSimulareContent(context, isDark, screenWidth),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: _isMenuOpen
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _isMenuOpen = false;
                      });
                    },
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: _SemicircleMenu(
                          onClose: () {
                            setState(() {
                              _isMenuOpen = false;
                            });
                          },
                          isDark: isDark,
                          onToggleTheme: () => context.read<ThemeProvider>().toggleTheme(),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isMenuOpen = !_isMenuOpen;
          });
          HapticFeedback.mediumImpact();
        },
        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
        elevation: 4,
        mini: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Icon(
            _isMenuOpen ? Icons.close : Icons.add,
            color: isDark ? Colors.white : Colors.black,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildSimulareContent(BuildContext context, bool isDark, double screenWidth) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: widget.questions.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            color: isDark ? Colors.black : Colors.white,
            padding: const EdgeInsets.only(top: 64, bottom: 12),
            child: Column(
              children: [
                Container(
                  height: 2,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text(
                    widget.simulareTitle.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  height: 2,
                  color: Colors.grey[400],
                ),
              ],
            ),
          );
        }

        if (index == widget.questions.length + 1) {
          return Container(
            color: isDark ? Colors.black : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  print('Simulare finalizată!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
                ).copyWith(
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
                  backgroundBuilder: (context, states, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: _gradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: child,
                    );
                  },
                ),
                child: Text(
                  'Finalizează simularea',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }

        final questionIndex = index - 1;
        final question = widget.questions[questionIndex];
        return Column(
          children: [
            Container(
              color: isDark ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${questionIndex + 1}. ${question.text}',
                      style: GoogleFonts.roboto(
                        fontSize: _getQuestionFontSize(),
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                        height: 1.2,
                        wordSpacing: -0.5,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...question.answers.asMap().entries.map(
                        (entry) {
                      final answer = entry.value;
                      final isSelected = _selectedAnswers[question.id]?.contains(answer.letter) ?? false;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAnswers[question.id] ??= {};
                            if (_selectedAnswers[question.id]!.contains(answer.letter)) {
                              _selectedAnswers[question.id]!.remove(answer.letter);
                              if (_selectedAnswers[question.id]!.isEmpty) {
                                _selectedAnswers.remove(question.id);
                              }
                            } else {
                              _selectedAnswers[question.id]!.add(answer.letter);
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: _getLetterContainerSize(),
                                height: _getLetterContainerSize(),
                                decoration: BoxDecoration(
                                  shape: isSelected ? BoxShape.circle : BoxShape.rectangle,
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  border: isSelected
                                      ? Border.all(
                                          color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
                                          width: 1,
                                        )
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    answer.letter.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: _getLetterFontSize(),
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      color: isDark ? Colors.white : Colors.black,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: isSelected
                                      ? BoxDecoration(
                                          border: Border.all(
                                            color: isDark ? Colors.white.withOpacity(0.5) : Colors.grey.withOpacity(0.5),
                                            width: 0.5,
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        )
                                      : null,
                                  child: Text(
                                    answer.text,
                                    style: GoogleFonts.poppins(
                                      fontSize: _getAnswerFontSize(),
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      color: isDark ? Colors.white : Colors.black,
                                      height: 1.2,
                                      wordSpacing: -0.5,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (questionIndex < widget.questions.length - 1)
              Divider(
                color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.5),
                thickness: 1,
                height: 8,
              ),
          ],
        );
      },
    );
  }
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
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: currentThemeColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  if (_isFinishing) {
                    setState(() => _isFinishing = false);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {
                      Share.share('Check out my score on StartJuris: $_score/10');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () => setState(() => _showTools = !_showTools),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.testTitle,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.questions.length} întrebări',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestResults() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Rezultate',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildResultItem(
                icon: Icons.check_circle,
                color: Colors.green,
                value: _correctAnswers,
                label: 'Corecte',
              ),
              _buildResultItem(
                icon: Icons.cancel,
                color: Colors.red,
                value: _wrongAnswers,
                label: 'Greșite',
              ),
              _buildResultItem(
                icon: Icons.star,
                color: Colors.amber,
                value: _score,
                label: 'Nota',
                isScore: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem({
    required IconData icon,
    required Color color,
    required dynamic value,
    required String label,
    bool isScore = false,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          isScore ? value.toStringAsFixed(1) : value.toString(),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
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

  Widget _buildQuestionCard(Question question, int index) {
    final isAnswered = _answeredQuestions[index];
    final selectedAnswers = _selectedAnswers[index];
    final isCorrect = _showExplanations &&
        selectedAnswers.length == question.correctAnswers.length &&
        selectedAnswers.every((answer) => question.correctAnswers.contains(answer));

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  currentThemeColors[0].withOpacity(0.1),
                  currentThemeColors[1].withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: currentThemeColors[0].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Întrebarea ${index + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: currentThemeColors[0],
                    ),
                  ),
                ),
                if (_showExplanations)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isCorrect ? 'Corect' : 'Greșit',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              question.text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: textColor,
              ),
            ),
          ),
          ...question.answers.map((answer) {
            final isSelected = selectedAnswers.contains(answer.letter);
            final isCorrect = _showExplanations && question.correctAnswers.contains(answer.letter);
            final isWrong = _showExplanations && isSelected && !isCorrect;

            return InkWell(
              onTap: () => _handleAnswer(index, answer.letter),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (_showExplanations
                          ? (isCorrect
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1))
                          : currentThemeColors[0].withOpacity(0.1))
                      : null,
                  border: Border(
                    top: BorderSide(
                      color: _isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? (_showExplanations
                                ? (isCorrect
                                    ? Colors.green
                                    : Colors.red)
                                : currentThemeColors[0])
                            : (_isDarkMode ? Colors.grey[700] : Colors.grey[200]),
                      ),
                      child: Center(
                        child: Text(
                          answer.letter,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : secondaryTextColor,
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
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          if (_showExplanations && question.explanation != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isDarkMode ? Colors.grey[900] : Colors.grey[100],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explicație:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.explanation!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: textColor,
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
    return GestureDetector(
      onTap: () => setState(() => _showTools = false),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: _SemicircleMenu(
            onClose: () => setState(() => _showTools = false),
            isDark: _isDarkMode,
            onToggleTheme: _toggleDarkMode,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: AnimatedOpacity(
        opacity: _isBreathingActive ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: _canSubmitTest ? _submitTest : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: currentThemeColors[0],
          ),
          child: Text(
            'Finalizează simularea',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _BreathingExercise extends StatefulWidget {
  final VoidCallback onClose;
  final bool isDark;

  const _BreathingExercise({
    required this.onClose,
    required this.isDark,
  });

  @override
  _BreathingExerciseState createState() => _BreathingExerciseState();
}

class _BreathingExerciseState extends State<_BreathingExercise> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String _phase = 'Inspiră';
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _phase = 'Expiră';
          _controller.reverse();
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _count++;
          if (_count < 4) {
            _phase = 'Inspiră';
            _controller.forward();
          } else {
            widget.onClose();
          }
        });
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _phase,
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade300, Colors.pink.shade300],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Respirația ${_count + 1}/4',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}