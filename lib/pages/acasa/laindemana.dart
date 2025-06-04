import 'package:flutter/material.dart';
import 'package:startjuris/pages/acasa/ajutor.dart';
import 'package:startjuris/pages/acasa/utile.dart';
import 'package:startjuris/pages/chat/chat_page.dart';
import 'package:startjuris/pages/dateexamene.dart';
import 'package:startjuris/pages/setariplan.dart';

class LaIndemanaCarousel extends StatelessWidget {
  const LaIndemanaCarousel({super.key});

  static const List<LinearGradient> _gradients = [
    LinearGradient(
      colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF89F7FE), Color(0xFF66A6FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFFBC2EB), Color(0xFFA6C1EE)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFFAD0C4), Color(0xFFFFD1FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  static const List<String> _gifPaths = [
    'assets/videos/1.gif',
    'assets/videos/2.gif',
    'assets/videos/3.gif',
    'assets/videos/4.gif',
    'assets/videos/5.gif',
  ];

  static const List<String> _titles = [
    'Setează un obiectiv',
    'Date examene',
    'Comunitate',
    'Foarte utile',
    'Ajutor',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _gifPaths.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final gradient = _gradients[index];
          final gif = _gifPaths[index];
          final title = _titles[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                print('Tapped: $title'); // Debug print
                switch (title) {
                  case 'Setează un obiectiv':
                    print('Navigating to SetariPlan'); // Debug print
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SetariPlan()),
                    );
                    break;
                  case 'Date examene':
                    print('Navigating to DateExamene'); // Debug print
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DateExamene()),
                    );
                    break;
                  case 'Comunitate':
                    print('Navigating to ChatPage'); // Debug print
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatPage(showGroups: true)),
                    );
                    break;
                  case 'Foarte utile':
                    print('Navigating to UtilePage'); // Debug print
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UtilePage()),
                    );
                    break;
                  case 'Ajutor':
                    print('Navigating to AjutorPage'); // Debug print
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AjutorPage()),
                    );
                    break;
                }
              },
              child: Container(
                width: 140,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: gradient,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      gif,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}