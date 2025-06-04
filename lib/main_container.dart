import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'pages/acasa/acasa_page.dart';
import 'pages/chat/chat_page.dart';
import 'pages/backend/social/users_search_page.dart';
import 'pages/backend/providers/chat_provider.dart';
import 'package:flutter/rendering.dart';
import 'pages/materie/materie_page.dart';
import 'pages/grile/grile_page.dart';
import 'pages/profil/profil_page.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;
  late ChatProvider _chatProvider;

  final List<Widget> _pages = [
    const AcasaPage(),
    const MateriePage(),
    const GrilePage(),
    const ChatPage(),
    const ProfilPage(),
  ];

  // Standard gradient for all icons
  final List<Color> _iconGradient = [
    Color(0xFF8E2DE2), // Beautiful violet purple
    Color(0xFFD946EF), // Vibrant magenta
    Color(0xFF667EEA), // Elegant blue
  ];

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      await _chatProvider.reloadAfterLogin();
    } catch (e) {
      print('Error initializing chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Eroare la inițializarea chat-ului. Încercați din nou.',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red[400],
            action: SnackBarAction(
              label: 'Reîncearcă',
              textColor: Colors.white,
              onPressed: _initializeChat,
            ),
          ),
        );
      }
    }
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _selectedIndex == index;
    
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedScale(
        scale: isSelected ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: index == 2 ? _iconGradient : [
                  Colors.black87,
                  Colors.grey[600]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Icon(
                index == 0 ? Icons.home_outlined :
                index == 1 ? Icons.book_outlined :
                index == 3 ? Icons.chat_outlined :
                index == 4 ? Icons.person_outlined :
                icon,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.grey[800],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        height: 100,
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Stack(
          children: [
            // Semicircle background
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white.withOpacity(0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.5),
                            Colors.white.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Navigation items in semicircle
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: 80,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Semicircle layout for other items
                    CustomPaint(
                      size: Size(MediaQuery.of(context).size.width, 80),
                      painter: SemicirclePainter(),
                      child: SizedBox(
                        height: 80,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(child: _buildNavItem(0, 'Acasă', Icons.home_rounded)),
                              Expanded(child: _buildNavItem(1, 'Materie', Icons.book_rounded)),
                              const Spacer(), // Space for center button
                              Expanded(child: _buildNavItem(3, 'Chat', Icons.chat_rounded)),
                              Expanded(child: _buildNavItem(4, 'Profil', Icons.person_rounded)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Centered Grile button with S.png
                    Positioned(
                      bottom: 12,
                      child: InkWell(
                        onTap: () => setState(() => _selectedIndex = 2),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.scale(
                              scale: _selectedIndex == 2 ? 1.2 : 1.0,
                              child: Image.asset(
                                'assets/poze/S.png',
                                width: 45,
                                height: 45,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Grile',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: _selectedIndex == 2 ? FontWeight.w600 : FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SemicirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0;

    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
        size.width / 2,
        -size.height * 0.5,
        size.width,
        size.height,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 