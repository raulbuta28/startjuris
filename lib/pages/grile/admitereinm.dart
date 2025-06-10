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

class AdmitereINMPage extends StatefulWidget {
  final int initialTabIndex;
  const AdmitereINMPage({super.key, this.initialTabIndex = 0});

  @override
  _AdmitereINMPageState createState() => _AdmitereINMPageState();
}

class _AdmitereINMPageState extends State<AdmitereINMPage> {
  late int _selectedIndex;
  final _scrollCtrl = ScrollController();

  final List<Widget> _pages = [
    const PlanuriPage(),
    const TemePage(exam: 'INM'),
    const TesteSupPage(),
    const TesteCombinate(),
    const SimulariPage(),
    const SizedBox(),
    const SizedBox(),
    const GrileAniAnterioriPage(),
    const IstoricGrilePage(),
    const IstoricMeciuriPage(),
    const PartenerDeStudiuPage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollCtrl.animateTo(
        _selectedIndex * 80.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      print('Scrolled to index: $_selectedIndex'); // Debug print
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (index == 5) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FlashcardsPage()),
      );
    } else if (index == 6) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GrileRandomPage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
        _scrollCtrl.animateTo(
          _selectedIndex * 80.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
      print('Tab selected: $index'); // Debug print
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                controller: _scrollCtrl,
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