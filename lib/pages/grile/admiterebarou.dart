import 'package:flutter/material.dart';
import 'admitereinm/planuri.dart';
import 'admitereinm/teme.dart';
import 'admitereinm/testesuplimentare.dart';
import 'admitereinm/testecombinate.dart';
import 'admitereinm/simulari.dart';
import 'admitereinm/flashcards.dart';
import 'admitereinm/grilerandom.dart';
import 'admitereinm/grileanianteriori.dart';
import 'admitereinm/istoricgrile.dart';
import 'admitereinm/istoricmeciuri.dart';
import 'admitereinm/partenerdestudiu.dart';
import 'elemente.dart';

class AdmitereBarouPage extends StatefulWidget {
  const AdmitereBarouPage({Key? key}) : super(key: key);

  @override
  _AdmitereBarouPageState createState() => _AdmitereBarouPageState();
}

class _AdmitereBarouPageState extends State<AdmitereBarouPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const PlanuriPage(),
    const TemePage(exam: 'Barou'),
    const TesteSupPage(),
    const TesteCombinate(),
    const SimulariPage(),
    const FlashcardsPage(),
    const GrileRandomPage(),
    const GrileAniAnterioriPage(),
    const IstoricGrilePage(),
    const IstoricMeciuriPage(),
    const PartenerDeStudiuPage(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Meniul orizontal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: Elemente.elements(context, _onTabSelected).length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final element = Elemente.elements(context, _onTabSelected)[index];
                  final isSelected = _selectedIndex == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: element.onTap,
                      splashColor: Colors.grey.withOpacity(0.2),
                      highlightColor: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected ? Colors.grey.shade100 : Colors.white,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              element.icon,
                              color: isSelected ? Colors.purple : Colors.black,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              element.title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? null : Colors.black,
                                foreground: isSelected
                                    ? (Paint()
                                      ..shader = const LinearGradient(
                                        colors: [Color(0xFF6A1B9A), Color(0xFFE91E63)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(
                                        const Rect.fromLTWH(0, 0, 100, 20),
                                      ))
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Conținut pagina selectată
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }
}