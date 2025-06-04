import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:startjuris/pages/grile/level.dart';

/// ---------------------------
///  Dimensiuni & stil global
/// ---------------------------
class _Dim {
  // Margini & spacing
  static const double edgePad = 16;
  static const double gridSpacing = 10;

  // Header
  static const double badgeHdr = 120; // badge mare mărit
  static const double hdrGap = 18; // spațiu badge-text
  static const double progBarH = 16;

  // Fonturi
  static const double hdrLvl = 24;
  static const double hdrPts = 16;
  static const double reqFont = 13;
  static const double cardTtl = 11;

  // Grid
  static const double cardAspect = .9;
  static const double badgePctCard = .75;
}

/// ---------------------------
///        Pagina Nivel
/// ---------------------------
class LevelPage extends StatefulWidget {
  const LevelPage({super.key});
  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> with SingleTickerProviderStateMixin {
  // DEMO
  static const int currentLevel = 1;
  static const int currentPoints = 765;
  static const int pointsForNextLevel = 1000;
  static const int maxDisplayedLevels = 26;

  static const List<double> _greyMatrix = [
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ];

  late final AnimationController _progressCtrl;
  late final Animation<double> _progressAnim;

  // Cerințe explicite
  static const int pagesNeed = 50;
  static const int quizzesNeed = 150;
  static const int winsNeed = 2;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    final progress = (currentPoints / pointsForNextLevel).clamp(0.0, 1.0);
    _progressAnim = Tween<double>(begin: 0, end: progress).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOutCubic),
    );
    _progressCtrl.forward();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    const cross = 3;
    final double cardW = (screenW - 2 * _Dim.edgePad - (cross - 1) * _Dim.gridSpacing) / cross;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Colors.white],
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ----------- HEADER WOW ------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _Dim.edgePad),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge mare animat cu glow
                  ElasticIn(
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      width: _Dim.badgeHdr,
                      height: _Dim.badgeHdr,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Imagine badge
                          Image.asset(
                            'assets/level/$currentLevel.png',
                            width: _Dim.badgeHdr * 0.9,
                            height: _Dim.badgeHdr * 0.9,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.error,
                              size: _Dim.badgeHdr * 0.5,
                              color: Colors.grey,
                            ),
                          ),
                          // Text nivel suprapus
                          Text(
                            '$currentLevel',
                            style: GoogleFonts.montserrat(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: _Dim.hdrGap),

                  /// ----- Texte & progres -----
                  Expanded(
                    child: FadeInRight(
                      duration: const Duration(milliseconds: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titlu nivel
                          Text(
                            'Nivel $currentLevel',
                            style: GoogleFonts.montserrat(
                              fontSize: _Dim.hdrLvl,
                              fontWeight: FontWeight.w800,
                              color: Colors.blue[900],
                              shadows: [
                                Shadow(
                                  color: Colors.blue.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Puncte
                          Text(
                            '$currentPoints / $pointsForNextLevel puncte',
                            style: GoogleFonts.montserrat(
                              fontSize: _Dim.hdrPts,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Progress bar modern cu gradient și shadow
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              height: _Dim.progBarH,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: AnimatedBuilder(
                                animation: _progressAnim,
                                builder: (_, __) {
                                  return FractionallySizedBox(
                                    widthFactor: _progressAnim.value,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF64B5F6),
                                            Color(0xFF1976D2),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Cerințe cu iconițe
                          _reqLine(Icons.book, '$pagesNeed pagini de citit'),
                          _reqLine(Icons.quiz, '$quizzesNeed grile de rezolvat'),
                          _reqLine(Icons.emoji_events, '$winsNeed meciuri de câștigat'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            /// ----------- GRID NIVELE -----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _Dim.edgePad),
              child: Text(
                'Nivele',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue[900],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _Dim.edgePad),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: maxDisplayedLevels,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  crossAxisSpacing: _Dim.gridSpacing,
                  mainAxisSpacing: _Dim.gridSpacing,
                  childAspectRatio: _Dim.cardAspect,
                ),
                itemBuilder: (_, idx) {
                  final lvl = idx + 1;
                  return LevelCard(
                    level: lvl,
                    isLocked: lvl > currentLevel,
                    isCurrent: lvl == currentLevel,
                    cardSize: cardW,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reqLine(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: _Dim.reqFont,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      );
}

/// -------------------- CARD NIVEL --------------------
class LevelCard extends StatefulWidget {
  final int level;
  final bool isLocked;
  final bool isCurrent;
  final double cardSize;

  const LevelCard({
    super.key,
    required this.level,
    required this.isLocked,
    required this.isCurrent,
    required this.cardSize,
  });

  @override
  State<LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<LevelCard> with SingleTickerProviderStateMixin {
  late final AnimationController _tapCtrl;
  late final Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();
    _tapCtrl = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _tapScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _tapCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    super.dispose();
  }

  void _openModal() {
    final p = 20 * widget.level;
    final q = 50 * widget.level;
    final w = widget.level;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          top: 30,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge mare colorat
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                'assets/level/${widget.level}.png',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.error,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Detalii nivel ${widget.level}',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            _detail('Pagini de citit', '$p'),
            _detail('Grile de rezolvat', '$q'),
            _detail('Meciuri de câștigat', '$w'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Închide'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(String t, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                t,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              v,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final badgeSz = widget.cardSize * _Dim.badgePctCard;

    return GestureDetector(
      onTapDown: (_) => _tapCtrl.forward(),
      onTapUp: (_) {
        _tapCtrl.reverse();
        _openModal();
      },
      onTapCancel: () => _tapCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _tapCtrl,
        builder: (_, child) => Transform.scale(scale: _tapScale.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: widget.isCurrent ? Colors.blue[50] : Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.07),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ColorFiltered(
                colorFilter: widget.isLocked
                    ? const ColorFilter.matrix(_LevelPageState._greyMatrix)
                    : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                child: Image.asset(
                  'assets/level/${widget.level}.png',
                  width: badgeSz,
                  height: badgeSz,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.error,
                    size: badgeSz,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nivel ${widget.level}',
                style: GoogleFonts.montserrat(
                  fontSize: _Dim.cardTtl,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}