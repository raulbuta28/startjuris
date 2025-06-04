import 'package:flutter/material.dart';
import '../poveste_page.dart';

class CartiDP extends StatelessWidget {
  const CartiDP({Key? key}) : super(key: key);

  static const List<Map<String, String>> _carti = [
    {
      'id': 'dp_1',
      'titlu': 'Drept penal - Partea generală',
      'imagine': 'assets/carti/cartidp/11.png',
      'continut': 'Conținutul despre dreptul penal - partea generală va fi disponibil în curând...',
    },
    {
      'id': 'dp_2',
      'titlu': 'Drept penal - Partea specială',
      'imagine': 'assets/carti/cartidp/12.png',
      'continut': 'Conținutul despre dreptul penal - partea specială va fi disponibil în curând...',
    },
    {
      'id': 'dp_3',
      'titlu': 'Infracțiuni contra persoanei',
      'imagine': 'assets/carti/cartidp/13.png',
      'continut': 'Conținutul despre infracțiunile contra persoanei va fi disponibil în curând...',
    },
    {
      'id': 'dp_4',
      'titlu': 'Infracțiuni contra patrimoniului',
      'imagine': 'assets/carti/cartidp/14.png',
      'continut': 'Conținutul despre infracțiunile contra patrimoniului va fi disponibil în curând...',
    },
    {
      'id': 'dp_5',
      'titlu': 'Infracțiuni de corupție',
      'imagine': 'assets/carti/cartidp/15.png',
      'continut': 'Conținutul despre infracțiunile de corupție va fi disponibil în curând...',
    },
    {
      'id': 'dp_6',
      'titlu': 'Infracțiuni de serviciu',
      'imagine': 'assets/carti/cartidp/16.png',
      'continut': 'Conținutul despre infracțiunile de serviciu va fi disponibil în curând...',
    },
    {
      'id': 'dp_7',
      'titlu': 'Infracțiuni contra înfăptuirii justiției',
      'imagine': 'assets/carti/cartidp/17.png',
      'continut': 'Conținutul despre infracțiunile contra înfăptuirii justiției va fi disponibil în curând...',
    },
    {
      'id': 'dp_8',
      'titlu': 'Infracțiuni de fals',
      'imagine': 'assets/carti/cartidp/18.png',
      'continut': 'Conținutul despre infracțiunile de fals va fi disponibil în curând...',
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