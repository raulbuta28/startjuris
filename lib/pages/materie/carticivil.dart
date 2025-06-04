import 'package:flutter/material.dart';
import '../poveste_page.dart';

class CartiCivil extends StatelessWidget {
  const CartiCivil({Key? key}) : super(key: key);

  static const List<Map<String, String>> _carti = [
    {
      'id': 'civil_1',
      'titlu': 'Despre persoane',
      'imagine': 'assets/carti/1.png',
      'continut': '''Persoana fizică este ființa umană, privită individual, ca titular de drepturi și obligații civile.
    
Capacitatea civilă este recunoscută tuturor persoanelor fizice.

Orice persoană fizică are capacitate de folosință. Capacitatea de folosință este aptitudinea persoanei de a avea drepturi și obligații civile.

Capacitatea de folosință începe la nașterea persoanei și încetează odată cu moartea acesteia.

Drepturile copilului sunt recunoscute și garantate, în condițiile legii, de la concepțiune, însă numai dacă el se naște viu.

Capacitatea de exercițiu este aptitudinea persoanei de a încheia singură acte juridice civile.''',
    },
    {
      'id': 'civil_2',
      'titlu': 'Căsătoria',
      'imagine': 'assets/carti/2.png',
      'continut': 'Conținutul despre căsătorie va fi disponibil în curând...',
    },
    {
      'id': 'civil_3',
      'titlu': 'Rudenia',
      'imagine': 'assets/carti/3.png',
      'continut': 'Conținutul despre rudenie va fi disponibil în curând...',
    },
    {
      'id': 'civil_4',
      'titlu': 'Autoritatea părintească',
      'imagine': 'assets/carti/4.png',
      'continut': 'Conținutul despre autoritatea părintească va fi disponibil în curând...',
    },
    {
      'id': 'civil_5',
      'titlu': 'Obligația de întreținere',
      'imagine': 'assets/carti/5.png',
      'continut': 'Conținutul despre obligația de întreținere va fi disponibil în curând...',
    },
    {
      'id': 'civil_6',
      'titlu': 'Proprietatea privată',
      'imagine': 'assets/carti/6.png',
      'continut': 'Conținutul despre proprietatea privată va fi disponibil în curând...',
    },
    {
      'id': 'civil_7',
      'titlu': 'Dezmembrămintele dreptului de proprietate privată',
      'imagine': 'assets/carti/7.png',
      'continut': 'Conținutul despre dezmembrămintele dreptului de proprietate privată va fi disponibil în curând...',
    },
    {
      'id': 'civil_8',
      'titlu': 'Proprietatea publică',
      'imagine': 'assets/carti/8.png',
      'continut': 'Conținutul despre proprietatea publică va fi disponibil în curând...',
    },
    {
      'id': 'civil_9',
      'titlu': 'Cartea funciară',
      'imagine': 'assets/carti/9.png',
      'continut': 'Conținutul despre cartea funciară va fi disponibil în curând...',
    },
    {
      'id': 'civil_10',
      'titlu': 'Posesia',
      'imagine': 'assets/carti/10.png',
      'continut': 'Conținutul despre posesie va fi disponibil în curând...',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _carti.length,
        itemBuilder: (context, index) {
          final carte = _carti[index];
          
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PovesterePage(
                        titlu: carte['titlu']!,
                        imagine: carte['imagine']!,
                        continut: carte['continut']!,
                        progress: 0.0,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.asset(
                          carte['imagine']!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.book,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              carte['titlu']!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: 0.0, // Default progress
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
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
            ),
          );
        },
      ),
    );
  }
}