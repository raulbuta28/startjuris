import 'package:flutter/material.dart';
import 'laindemana.dart';
import 'statistici.dart';
import 'codurileactualizate.dart';
import 'clasament.dart';

class AcasaPage extends StatefulWidget {
  const AcasaPage({super.key});

  @override
  State<AcasaPage> createState() => _AcasaPageState();
}

class _AcasaPageState extends State<AcasaPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          shrinkWrap: true, // Permite copiilor să-și seteze propria înălțime
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: ScaleTransition(
                scale: _scaleAnim,
                child: const Text(
                  'La îndemână...',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const LaIndemanaCarousel(),
            const SizedBox(height: 16),
            const CodurileActualizate(),
            const SizedBox(height: 4), // Redus și mai mult pentru a ridica Clasament
            const Clasament(),
            const SizedBox(height: 16),
            const StatisticiPage(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}