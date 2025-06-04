import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class BurgerMenuPage extends StatelessWidget {
  const BurgerMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Configure status bar and navigation bar colors
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
    );

    // Wrap Scaffold in GestureDetector to allow swipe-right to go back
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        // Detect a right swipe (positive velocity) and navigate back
        if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Meniu',  // Updated title
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.black),
                title: Text(
                  'Planuri de învățat',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Planuri de învățat Coming Soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.book, color: Colors.black),
                title: Text(
                  'Teme',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Teme Coming Soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.quiz, color: Colors.black),
                title: Text(
                  'Teste suplimentare',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Teste suplimentare Coming Soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.merge_type, color: Colors.black),
                title: Text(
                  'Teste combinate',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Teste combinate Coming Soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.school, color: Colors.black),
                title: Text(
                  'Simulări',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Simulări Coming Soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.gavel, color: Colors.black),
                title: Text(
                  'Spețe',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Spețe Coming Soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.card_giftcard, color: Colors.black),
                title: Text(
                  'Flashcards',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Flashcards Coming Soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.shuffle, color: Colors.black),
                title: Text(
                  'Grile random',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Grile random Coming Soon!')),
                  );
                },
              ),
              // Grile date în anii anteriori
              ListTile(
                leading: const Icon(Icons.date_range, color: Colors.black),
                title: Text(
                  'Grile date în anii anteriori',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Grile date în anii anteriori Coming Soon!')),
                  );
                },
              ),
              // Grile dificile
              ListTile(
                leading: const Icon(Icons.whatshot, color: Colors.black),
                title: Text(
                  'Grile dificile',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Grile dificile Coming Soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Colors.black),
                title: Text(
                  'Istoric grile greșite',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Istoric grile greșite Coming Soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.all_inclusive, color: Colors.black),
                title: Text(
                  'Istoric meciuri',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Istoric meciuri Coming Soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.group, color: Colors.black),
                title: Text(
                  'Partener de studiu',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Partener de studiu Coming Soon!')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}