import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GrileAniAnterioriPage extends StatelessWidget {
  const GrileAniAnterioriPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Pagina Grile Ani Anteriori',
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