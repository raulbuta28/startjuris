import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../modern_code_reader.dart';

class CodItem {
  final String path;
  final String date;
  final double progress;
  final String title;
  final String codId;

  const CodItem({
    required this.path, 
    required this.date, 
    required this.progress,
    required this.title,
    required this.codId,
  });
}

class CodurileActualizate extends StatelessWidget {
  const CodurileActualizate({Key? key}) : super(key: key);

  // Display the GIFs in an A4-like ratio (width/height ~= 0.7) so
  // they appear taller while keeping the current rounded corners.
  static const double _imageAspectRatio = 0.7;
  static const double _titleHeight = 34;
  static const double _dateHeight = 14;

  static const List<CodItem> _items = [
    // Order: Civil, Procedura Civila, Penal, Procedura Penala
    CodItem(
      path: 'assets/videos/7.gif',
      date: '20 Mai 2025',
      progress: 0.75,
      title: 'Codul Civil',
      codId: 'civil',
    ),
    CodItem(
      path: 'assets/videos/9.gif',
      date: '15 Mai 2025',
      progress: 0.90,
      title: 'Codul de Procedură Civilă',
      codId: 'proc_civil',
    ),
    CodItem(
      path: 'assets/videos/8.gif',
      date: '18 Mai 2025',
      progress: 0.50,
      title: 'Codul Penal',
      codId: 'penal',
    ),
    CodItem(
      path: 'assets/videos/10.gif',
      date: '10 Mai 2025',
      progress: 0.30,
      title: 'Codul de Procedură Penală',
      codId: 'proc_penal',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 16;
    const double spacing = 12.0;
    final int count = _items.length;
    final double availableWidth = MediaQuery.of(context).size.width - horizontalPadding * 2 - spacing * (count - 1);
    final double itemWidth = availableWidth / count;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Codurile actualizate',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.75,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _items.map((item) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ModernCodeReader(
                        codeId: item.codId,
                        codeTitle: item.title,
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  width: itemWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _imageAspectRatio,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.asset(
                                    item.path,
                                    fit: BoxFit.cover,
                                    gaplessPlayback: true,
                                  ),
                                ),
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ModernCodeReader(
                                              codeId: item.codId,
                                              codeTitle: item.title,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: _titleHeight,
                        child: Center(
                          child: Text(
                            item.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: _dateHeight,
                        child: Text(
                          'Actualizare: ${item.date}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.grey[600],
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: itemWidth,
                        height: 16,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [Colors.green.shade200, Colors.green.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                            BoxShadow(color: Colors.white24, blurRadius: 2, offset: Offset(0, -1)),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: FractionallySizedBox(
                                widthFactor: item.progress,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    gradient: LinearGradient(
                                      colors: [Colors.green.shade800, Colors.green.shade600],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                '${(item.progress * 100).round()}%',
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  shadows: [
                                    const Shadow(
                                      color: Colors.black54,
                                      offset: Offset(0.5, 0.5),
                                      blurRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
