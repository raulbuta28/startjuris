import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class AdmitereSNG extends StatelessWidget {
  const AdmitereSNG({Key? key}) : super(key: key);

  static final List<String> _bookTitles = List.generate(
    12,
    (i) => 'Curs SNG ${i + 1}',
  );

  static final List<int> _bookIndices = List.generate(12, (i) {
    return 11 + Random().nextInt(8); // Random from 11 to 18 (cartidp)
  });

  static final List<double> _progress = List.generate(
    12,
    (i) => ((100 - i * 5).clamp(0, 100)).toDouble(),
  );

  @override
  Widget build(BuildContext context) {
    const imageHeight = 220.0;
    const aspectRatio = 1 / 1.4142;
    final tileWidth = imageHeight * aspectRatio;

    const totalHeight = imageHeight + 6 + 16 + 6 + 6 + 36 + 6; // 296.0

    return SizedBox(
      height: totalHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: 12,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return SizedBox(
            width: tileWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: imageHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: aspectRatio,
                      child: Image.asset(
                        'assets/carti/cartidp/${_bookIndices[index]}.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image, size: 40),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 16,
                  child: Text(
                    '${_progress[index].toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 6,
                  width: tileWidth,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 6,
                        width: tileWidth,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(3)),
                        ),
                      ),
                      Container(
                        height: 6,
                        width: tileWidth * (_progress[index] / 100),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green, Colors.teal],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 36,
                  width: tileWidth,
                  child: Text(
                    _bookTitles[index],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}