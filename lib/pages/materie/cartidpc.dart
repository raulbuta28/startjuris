import 'package:flutter/material.dart';
import '../poveste_page.dart';
import '../ebook_reader_page.dart';
import '../book_cover_page.dart';
import '../../services/book_service.dart';

class CartiDPC extends StatelessWidget {
  final List<AdminBook> carti;
  const CartiDPC({Key? key, required this.carti}) : super(key: key);

  Widget _buildImage(String path) {
    final placeholder = Container(
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Icon(Icons.book, size: 50, color: Colors.grey),
    );

    final image = path.startsWith('http://') || path.startsWith('https://')
        ? Image.network(
            path,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => placeholder,
          )
        : Image.asset(
            path,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => placeholder,
          );
    return image;
  }

  @override
  Widget build(BuildContext context) {
    const cardHeight = 270.0;
    return Container(
      height: cardHeight,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: carti.length,
        itemBuilder: (context, index) {
          final carte = carti[index];
          
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  final page = carte.file.isNotEmpty
                      ? PremiumEbookReaderPage(
                          title: carte.title,
                          url: carte.file,
                        )
                      : PovesterePage(
                          titlu: carte.title,
                          imagine: carte.image,
                          continut: carte.content,
                          progress: 0.0,
                        );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => carte.image.isNotEmpty
                          ? BookCoverPage(image: carte.image, nextPage: page)
                          : page,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 0.75,
                        child: _buildImage(carte.image),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        carte.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        height: 6,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: 0.0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF7CC4A2), Color(0xFFB8D8A0)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(3)),
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