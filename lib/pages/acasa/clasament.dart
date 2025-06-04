// clasament.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserScore {
  final String name;
  final int points;
  const UserScore({required this.name, required this.points});
}

class Clasament extends StatefulWidget {
  const Clasament({Key? key}) : super(key: key);

  @override
  _ClasamentState createState() => _ClasamentState();
}

class _ClasamentState extends State<Clasament> with SingleTickerProviderStateMixin {
  static const List<UserScore> _topUsers = [
    UserScore(name: 'Andrei Popescu', points: 1250),
    UserScore(name: 'Maria Ionescu', points: 1150),
    UserScore(name: 'Alexandru Stoica', points: 1080),
    UserScore(name: 'Ioana Dumitru', points: 1020),
    UserScore(name: 'Mihai Georgescu', points: 980),
    UserScore(name: 'Elena Radu', points: 950),
    UserScore(name: 'Cristian Matei', points: 920),
    UserScore(name: 'Raluca Stan', points: 900),
    UserScore(name: 'Bogdan Pavel', points: 880),
    UserScore(name: 'Alina Vlad', points: 850),
  ];

  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
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
    final scaleFactor = screenWidth < 360 ? 0.9 : 1.0;
    final overlay = 36.0 * scaleFactor; // spațiu pentru badge

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // titlu puțin ridicat
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Text(
              'Clasament',
              style: GoogleFonts.poppins(
                fontSize: 22 * scaleFactor,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 200 * scaleFactor + overlay,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0),
                  Colors.white.withOpacity(0),
                  Colors.white,
                ],
                stops: const [0, 0.05, 0.95, 1],
              ).createShader(rect),
              blendMode: BlendMode.dstOut,
              child: Padding(
                padding: EdgeInsets.only(top: overlay),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none, // permit badge overflow
                  padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                  itemCount: _topUsers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final user = _topUsers[index];
                    final isTopThree = index < 3;
                    return AnimatedLeaderboardCard(
                      user: user,
                      index: index,
                      isTopThree: isTopThree,
                      scaleFactor: scaleFactor,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AnimatedLeaderboardCard extends StatefulWidget {
  final UserScore user;
  final int index;
  final bool isTopThree;
  final double scaleFactor;

  const AnimatedLeaderboardCard({
    Key? key,
    required this.user,
    required this.index,
    required this.isTopThree,
    required this.scaleFactor,
  }) : super(key: key);

  @override
  _AnimatedLeaderboardCardState createState() => _AnimatedLeaderboardCardState();
}

class _AnimatedLeaderboardCardState extends State<AnimatedLeaderboardCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
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
    final badgeSize = (widget.isTopThree ? 72.0 : 36.0) * widget.scaleFactor;
    final cardWidth = 90.0 * widget.scaleFactor;
    final cardHeight = widget.index == 0
        ? 180.0 * widget.scaleFactor
        : widget.isTopThree
            ? 150.0 * widget.scaleFactor
            : 130.0 * widget.scaleFactor;
    final avatarSize = (widget.isTopThree ? 52.0 : 40.0) * widget.scaleFactor;
    final borderWidth = 1.5 * widget.scaleFactor;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12 * widget.scaleFactor),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: badgeSize / 2),
                  // avatar cu fundal alb și gradient circular
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.purple, Colors.red, Colors.blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: avatarSize - borderWidth * 2,
                        height: avatarSize - borderWidth * 2,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 20 * widget.scaleFactor,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4 * widget.scaleFactor),
                  Text(
                    widget.user.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: (widget.isTopThree ? 14 : 12) * widget.scaleFactor,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 2 * widget.scaleFactor),
                  Text(
                    '${widget.user.points} puncte',
                    style: GoogleFonts.poppins(
                      fontSize: 9 * widget.scaleFactor,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              // badge cu umbră profesională, formă circulară
              Positioned(
                top: -badgeSize / 2,
                left: (cardWidth - badgeSize) / 2,
                child: Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/clasament/${widget.index + 1}.png',
                      width: badgeSize,
                      height: badgeSize,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: badgeSize,
                        height: badgeSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade300,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '#${widget.index + 1}',
                            style: GoogleFonts.poppins(
                              fontSize: (widget.isTopThree ? 14 : 10) * widget.scaleFactor,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
