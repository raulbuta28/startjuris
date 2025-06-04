import 'package:flutter/material.dart';
import '../poveste_page.dart';

class CartiDPP extends StatelessWidget {
  const CartiDPP({Key? key}) : super(key: key);

  static const List<Map<String, String>> _carti = [
    {
      'id': 'dpp_1',
      'titlu': 'Principiile procesului penal',
      'imagine': 'assets/carti/cartidpp/19.png',
      'continut': 'Conținutul despre principiile procesului penal va fi disponibil în curând...',
    },
    {
      'id': 'dpp_2',
      'titlu': 'Acțiunea penală și acțiunea civilă',
      'imagine': 'assets/carti/cartidpp/20.png',
      'continut': 'Conținutul despre acțiunea penală și acțiunea civilă va fi disponibil în curând...',
    },
    {
      'id': 'dpp_3',
      'titlu': 'Participanții în procesul penal',
      'imagine': 'assets/carti/cartidpp/21.png',
      'continut': 'Conținutul despre participanții în procesul penal va fi disponibil în curând...',
    },
    {
      'id': 'dpp_4',
      'titlu': 'Probele și mijloacele de probă',
      'imagine': 'assets/carti/cartidpp/22.png',
      'continut': 'Conținutul despre probele și mijloacele de probă va fi disponibil în curând...',
    },
    {
      'id': 'dpp_5',
      'titlu': 'Măsurile preventive',
      'imagine': 'assets/carti/cartidpp/23.png',
      'continut': 'Conținutul despre măsurile preventive va fi disponibil în curând...',
    },
    {
      'id': 'dpp_6',
      'titlu': 'Urmărirea penală',
      'imagine': 'assets/carti/cartidpp/24.png',
      'continut': 'Conținutul despre urmărirea penală va fi disponibil în curând...',
    },
    {
      'id': 'dpp_7',
      'titlu': 'Camera preliminară',
      'imagine': 'assets/carti/cartidpp/25.png',
      'continut': 'Conținutul despre camera preliminară va fi disponibil în curând...',
    },
    {
      'id': 'dpp_8',
      'titlu': 'Judecata',
      'imagine': 'assets/carti/cartidpp/26.png',
      'continut': 'Conținutul despre judecată va fi disponibil în curând...',
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