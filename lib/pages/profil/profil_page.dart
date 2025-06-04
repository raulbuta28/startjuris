import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../backend/providers/auth_provider.dart';
import '../backend/models/user_model.dart';
import '../../services/url_utils.dart';
import '../backend/social/users_search_page.dart';
import '../backend/social/followers_following_page.dart';
import 'edit_profile_screen.dart';
import 'plans_page.dart';
import 'news_page.dart';
import 'solved_page.dart';
import 'level_page.dart';
import 'performance_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _searchResults = [];
  bool _isSearching = false;
  late final TabController _tabController;
  late final AnimationController _storyAnimationController;
  bool _hasStory = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    _storyAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _searchController.addListener(() => _searchUsers(_searchController.text));
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _storyAnimationController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _searchUsers(String query) {
    setState(() {
      _isSearching = query.trim().isNotEmpty;
      if (query.trim().isEmpty) {
        _searchResults = [];
      } else {
        // Aici vom implementa căutarea reală de utilizatori
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UsersSearchPage()),
        );
      }
    });
  }

  void _showProfileMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return ProfileMenuModal(
          onLogout: () async {
            Navigator.pop(context);
            await context.read<AuthProvider>().logout();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        if (user == null) return const Center(child: CircularProgressIndicator());

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: NestedScrollView(
              physics: const ClampingScrollPhysics(),
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: FadeIn(
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          child: _buildProfileContent(user),
                        ),
                      ),
                    ),
                  ),
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                    sliver: SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        minHeight: 85.0,
                        maxHeight: 85.0,
                        child: Container(
                          color: Colors.white,
                          child: TabBar(
                            controller: _tabController,
                            isScrollable: false,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.grey.shade600,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: const BoxDecoration(),
                            padding: EdgeInsets.zero,
                            tabs: [
                              _buildTab('Planuri', Icons.event_note_rounded, 0),
                              _buildTab('Noutăți', Icons.new_releases_rounded, 1),
                              _buildTab('Rezolvate', Icons.check_circle_rounded, 2),
                              _buildTab('Nivel', Icons.rocket_launch_rounded, 3),
                              _buildTab('Statistici', Icons.show_chart_rounded, 4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  SafeArea(
                    top: false,
                    bottom: false,
                    child: Builder(
                      builder: (BuildContext context) {
                        return CustomScrollView(
                          key: const PageStorageKey<String>('Planuri'),
                          physics: const ClampingScrollPhysics(),
                          slivers: <Widget>[
                            SliverOverlapInjector(
                              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                            ),
                            const SliverPadding(
                              padding: EdgeInsets.only(top: 8),
                              sliver: SliverToBoxAdapter(
                                child: PlansPage(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    top: false,
                    bottom: false,
                    child: Builder(
                      builder: (BuildContext context) {
                        return CustomScrollView(
                          key: const PageStorageKey<String>('Noutăți'),
                          physics: const ClampingScrollPhysics(),
                          slivers: <Widget>[
                            SliverOverlapInjector(
                              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                            ),
                            const SliverPadding(
                              padding: EdgeInsets.only(top: 8),
                              sliver: SliverToBoxAdapter(
                                child: NewsPage(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    top: false,
                    bottom: false,
                    child: Builder(
                      builder: (BuildContext context) {
                        return CustomScrollView(
                          key: const PageStorageKey<String>('Rezolvate'),
                          physics: const ClampingScrollPhysics(),
                          slivers: <Widget>[
                            SliverOverlapInjector(
                              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                            ),
                            const SliverPadding(
                              padding: EdgeInsets.only(top: 8),
                              sliver: SliverToBoxAdapter(
                                child: SolvedPage(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    top: false,
                    bottom: false,
                    child: Builder(
                      builder: (BuildContext context) {
                        return CustomScrollView(
                          key: const PageStorageKey<String>('Nivel'),
                          physics: const ClampingScrollPhysics(),
                          slivers: <Widget>[
                            SliverOverlapInjector(
                              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                            ),
                            const SliverPadding(
                              padding: EdgeInsets.only(top: 8),
                              sliver: SliverToBoxAdapter(
                                child: LevelPage(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    top: false,
                    bottom: false,
                    child: Builder(
                      builder: (BuildContext context) {
                        return CustomScrollView(
                          key: const PageStorageKey<String>('Statistici'),
                          physics: const ClampingScrollPhysics(),
                          slivers: <Widget>[
                            SliverOverlapInjector(
                              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                            ),
                            const SliverPadding(
                              padding: EdgeInsets.only(top: 8),
                              sliver: SliverToBoxAdapter(
                                child: PerformancePage(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileContent(User user) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UsersSearchPage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        'Caută utilizatori...',
                        style: GoogleFonts.montserrat(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.black54,
                size: 24,
              ),
              onPressed: () => _showProfileMenu(context),
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black87,
                          Colors.black,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: AnimatedBuilder(
                      animation: _storyAnimationController,
                      builder: (_, child) => CustomPaint(
                        painter: SparkleBorderPainter(
                          animationValue: _storyAnimationController.value,
                          borderRadius: 20,
                          borderWidth: 4,
                          gradient: LinearGradient(
                            colors: [
                              Colors.black87,
                              Colors.black54,
                              Colors.black87,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: child,
                      ),
                      child: _buildAvatar(user),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElasticIn(
                          child: Text(
                            user.username,
                            style: GoogleFonts.montserrat(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        if (user.username.toLowerCase() == 'startjuris') ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    ZoomIn(
                      child: Text(
                        user.bio ?? 'Nicio descriere adăugată',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: _buildStat('${user.following.length}', 'Urmărește')),
                        Container(
                          height: 24,
                          width: 1,
                          color: Colors.grey.shade300,
                        ),
                        Expanded(child: _buildStat('${user.followers.length}', 'Urmăritori')),
                      ],
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      color: Colors.black87,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(user: user),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(User user) {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: user.avatarUrl != null
            ? CachedNetworkImage(
                imageUrl: resolveUrl(user.avatarUrl),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.person, size: 40, color: Colors.black54),
                ),
              )
            : Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.person, size: 40, color: Colors.black54),
              ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return GestureDetector(
      onTap: () {
        if (label == 'Urmăritori' || label == 'Urmărește') {
          final user = context.read<AuthProvider>().currentUser;
          if (user != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FollowersFollowingPage(
                  user: user,
                  showFollowers: label == 'Urmăritori',
                ),
              ),
            );
          }
        }
      },
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, IconData icon, int index) {
    bool isSelected = _tabController.index == index;
    List<Color> gradientColors = _getTabGradient(index);
    
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = 0.5;
    final totalSpacing = spacing * 4;
    final tabSize = (screenWidth - totalSpacing) / 5;
    final squareSize = tabSize - 0.5;
    final fontSize = squareSize * 0.115;
    
    return Container(
      width: tabSize,
      height: tabSize,
      padding: EdgeInsets.symmetric(horizontal: spacing / 2),
      child: Center(
        child: Container(
          width: squareSize,
          height: squareSize * 0.85,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: isSelected
                ? LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: gradientColors.first.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: isSelected ? 1.2 : 1.0,
                child: Icon(
                  icon,
                  size: squareSize * 0.3,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
              SizedBox(height: squareSize * 0.02),
              Container(
                width: squareSize,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  text,
                  style: GoogleFonts.montserrat(
                    fontSize: fontSize,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getTabGradient(int index) {
    switch (index) {
      case 0:
        return [const Color(0xFFE91E63), const Color(0xFFFF8A80)];
      case 1:
        return [const Color(0xFF2196F3), const Color(0xFF64B5F6)];
      case 2:
        return [const Color(0xFF4CAF50), const Color(0xFF81C784)];
      case 3:
        return [const Color(0xFFF44336), const Color(0xFFFF8A80)];
      case 4:
        return [const Color(0xFF0288D1), const Color(0xFF4FC3F7)];
      default:
        return [Colors.grey, Colors.grey.shade300];
    }
  }
}

class ProfileMenuModal extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileMenuModal({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black54, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.subscriptions_outlined, color: Colors.black87, size: 24),
              title: Text(
                'Abonament',
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                debugPrint('Abonament pressed');
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline, color: Colors.black87, size: 24),
              title: Text(
                'Setări confidențialitate',
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                debugPrint('Setări confidențialitate pressed');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.black87, size: 24),
              title: Text(
                'Date personale',
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                debugPrint('Date personale pressed');
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment_outlined, color: Colors.black87, size: 24),
              title: Text(
                'Plăți',
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                debugPrint('Plăți pressed');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.black87, size: 24),
              title: Text(
                'Ajutor',
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                debugPrint('Ajutor pressed');
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red, size: 24),
              title: Text(
                'Deconectare',
                style: TextStyle(
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                  color: Colors.red,
                ),
              ),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

class SparkleBorderPainter extends CustomPainter {
  final double animationValue;
  final double borderRadius;
  final double borderWidth;
  final Gradient gradient;

  SparkleBorderPainter({
    required this.animationValue,
    required this.borderRadius,
    required this.borderWidth,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final path = Path()..addRRect(rrect);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = gradient.createShader(rect);
    canvas.drawPath(path, borderPaint);

    final sparklePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = const LinearGradient(
        colors: [Colors.white, Colors.white70, Colors.transparent],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect);

    final totalLength =
        path.computeMetrics().fold<double>(0, (s, pm) => s + pm.length);
    final segmentLength = totalLength * 0.08;
    final offset = totalLength * animationValue;

    for (final metric in path.computeMetrics()) {
      final start = offset % totalLength;
      final end = (start + segmentLength).clamp(0.0, totalLength);

      if (start + segmentLength <= totalLength) {
        canvas.drawPath(metric.extractPath(start, end), sparklePaint);
      } else {
        final first = metric.extractPath(start, totalLength);
        final second =
            metric.extractPath(0, segmentLength - (totalLength - start));
        canvas.drawPath(first, sparklePaint);
        canvas.drawPath(second, sparklePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SparkleBorderPainter old) =>
      animationValue != old.animationValue ||
      borderRadius != old.borderRadius ||
      borderWidth != old.borderWidth ||
      gradient != old.gradient;
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}