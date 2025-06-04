import 'package:flutter/material.dart';
import '../poveste_page.dart';

class CartiDPC extends StatelessWidget {
  const CartiDPC({Key? key}) : super(key: key);

  static const List<Map<String, String>> _carti = [
    {
      'id': 'dpc_1',
      'titlu': 'Principiile procesului civil',
      'imagine': 'assets/carti/cartidpc/1.png',
      'continut': 'Conținutul despre principiile procesului civil va fi disponibil în curând...',
    },
    {
      'id': 'dpc_2',
      'titlu': 'Competența instanțelor judecătorești',
      'imagine': 'assets/carti/cartidpc/2.png',
      'continut': 'Conținutul despre competența instanțelor judecătorești va fi disponibil în curând...',
    },
    {
      'id': 'dpc_3',
      'titlu': 'Participanții la procesul civil',
      'imagine': 'assets/carti/cartidpc/3.png',
      'continut': 'Conținutul despre participanții la procesul civil va fi disponibil în curând...',
    },
    {
      'id': 'dpc_4',
      'titlu': 'Actele de procedură',
      'imagine': 'assets/carti/cartidpc/4.png',
      'continut': 'Conținutul despre actele de procedură va fi disponibil în curând...',
    },
    {
      'id': 'dpc_5',
      'titlu': 'Termenele procedurale',
      'imagine': 'assets/carti/cartidpc/5.png',
      'continut': 'Conținutul despre termenele procedurale va fi disponibil în curând...',
    },
    {
      'id': 'dpc_6',
      'titlu': 'Judecata în primă instanță',
      'imagine': 'assets/carti/cartidpc/6.png',
      'continut': 'Conținutul despre judecata în primă instanță va fi disponibil în curând...',
    },
    {
      'id': 'dpc_7',
      'titlu': 'Căile de atac',
      'imagine': 'assets/carti/cartidpc/7.png',
      'continut': 'Conținutul despre căile de atac va fi disponibil în curând...',
    },
    {
      'id': 'dpc_8',
      'titlu': 'Proceduri speciale',
      'imagine': 'assets/carti/cartidpc/8.png',
      'continut': 'Conținutul despre procedurile speciale va fi disponibil în curând...',
    },
    {
      'id': 'dpc_9',
      'titlu': 'Executarea silită',
      'imagine': 'assets/carti/cartidpc/9.png',
      'continut': 'Conținutul despre executarea silită va fi disponibil în curând...',
    },
    {
      'id': 'dpc_10',
      'titlu': 'Arbitrajul',
      'imagine': 'assets/carti/cartidpc/10.png',
      'continut': 'Conținutul despre arbitraj va fi disponibil în curând...',
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