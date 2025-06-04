import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpetePage extends StatelessWidget {
  const SpetePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Pagina Spețe',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}