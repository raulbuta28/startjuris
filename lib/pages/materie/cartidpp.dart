import 'package:flutter/material.dart';
import '../poveste_page.dart';
import '../../services/book_service.dart';

class CartiDPP extends StatelessWidget {
  final List<AdminBook> carti;
  const CartiDPP({Key? key, required this.carti}) : super(key: key);

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
    return Container(
      height: 320,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PovesterePage(
                        titlu: carte.title,
                        imagine: carte.image,
                        continut: carte.content,
                        progress: 0.0,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: AspectRatio(
                        aspectRatio: 0.75,
                        child: _buildImage(carte.image),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            carte.title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: 0.0,
                            backgroundColor: Colors.grey.shade200,
                            color: Colors.blue,
                          ),
                        ],
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