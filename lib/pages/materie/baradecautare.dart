// lib/pages/materie/baradecautare.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BaraDeCautarePage extends StatefulWidget {
  const BaraDeCautarePage({Key? key}) : super(key: key);

  @override
  State<BaraDeCautarePage> createState() => _BaraDeCautarePageState();
}

class _BaraDeCautarePageState extends State<BaraDeCautarePage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _exemple = [
    'Drept penal – articole relevante',
    'Procedură civilă – modele cereri',
    'Codul civil – documente utile',
    'Drept constituțional – sinteze',
    'Regulament notarial – ghid rapid',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // search bar + cancel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.purple, Colors.red, Colors.blue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          controller: _controller,
                          textInputAction: TextInputAction.search,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Găsește articole pentru Barou, Notariat & INM...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                              color: Colors.black54,
                            ),
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.search, size: 20),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 20, maxWidth: 20,
                              minHeight: 20, maxHeight: 20,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Anulează',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.25,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // popular searches
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Căutări populare',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _exemple.length,
                separatorBuilder: (_, __) => Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                ),
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    _exemple[i],
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.25,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
