// pdf_viewer_page.dart — versiune corectată pentru pdfx real API
// ------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:internet_file/internet_file.dart';

class PdfViewerPage extends StatefulWidget {
  final String title;
  final String url;

  const PdfViewerPage({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  PdfController? _controller;
  bool _dark = false;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;
  String? _error;
  bool _isFullscreen = false;
  bool _showSearch = false;
  TextEditingController _searchController = TextEditingController();
  int _goToPage = 1;
  late PageController _pageInputController;

  @override
  void initState() {
    super.initState();
    _pageInputController = PageController();
    if (widget.url.isNotEmpty) {
      _loadDocument();
    } else {
      setState(() {
        _error = "URL-ul PDF-ului este gol";
        _isLoading = false;
      });
    }
  }

  // === Helpers ==============================================================
  Future<PdfDocument> _createDocument() {
    if (widget.url.startsWith('http://') || widget.url.startsWith('https://')) {
      return InternetFile.get(widget.url).then(
        (data) => PdfDocument.openData(data),
      );
    } else if (widget.url.startsWith('file://') || widget.url.startsWith('/')) {
      final path = widget.url.startsWith('file://')
          ? widget.url.replaceFirst('file://', '')
          : widget.url;
      return PdfDocument.openFile(path);
    } else {
      if (widget.url.trim().isEmpty) {
        throw Exception("Asset path este gol");
      }
      return PdfDocument.openAsset(widget.url);
    }
  }

  Future<void> _loadDocument() async {
    try {
      if (!mounted) return;
      
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final documentFuture = _createDocument();
      
      if (!mounted) return;
      
      // Configurare pentru calitate maximă
      _controller = PdfController(
        document: documentFuture,
        initialPage: 1,
        viewportFraction: 1.0, // Full viewport pentru calitate maximă
      );

      final document = await documentFuture;
      final pageCount = document.pagesCount;
      
      if (mounted) {
        setState(() {
          _totalPages = pageCount;
          _isLoading = false;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _searchController.dispose();
    _pageInputController.dispose();
    super.dispose();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  void _nextPage() {
    if (_controller != null && _currentPage < _totalPages) {
      _controller!.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_controller != null && _currentPage > 1) {
      _controller!.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
      }
    });
  }

  void _goToSpecificPage() {
    if (_controller != null && _goToPage >= 1 && _goToPage <= _totalPages) {
      _controller!.animateToPage(
        _goToPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // === UI ===================================================================
  @override
  Widget build(BuildContext context) {
    final bg = _dark ? Colors.black : Colors.white;
    final textColor = _dark ? Colors.white : Colors.black87;

    if (widget.url.isEmpty) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: bg,
          foregroundColor: textColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Fișier indisponibil',
                style: TextStyle(fontSize: 18, color: textColor),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: bg,
          foregroundColor: textColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Eroare la încărcarea PDF',
                style: TextStyle(fontSize: 18, color: textColor),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  style: TextStyle(color: textColor.withOpacity(0.6)),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDocument,
                child: const Text('Încearcă din nou'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading || _controller == null) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Se încarcă PDF-ul...',
                style: TextStyle(color: textColor, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Pregătire pentru calitate maximă',
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ---------------- PDF cu SWIPE și CLICK NAVIGATION ---------------
          GestureDetector(
            onTap: _toggleFullscreen,
            onHorizontalDragEnd: (details) {
              const sensitivity = 8.0;
              if (details.velocity.pixelsPerSecond.dx > sensitivity) {
                _previousPage();
              } else if (details.velocity.pixelsPerSecond.dx < -sensitivity) {
                _nextPage();
              }
            },
            child: PdfView(
              controller: _controller!,
              scrollDirection: Axis.horizontal,
              pageSnapping: true,
              physics: const NeverScrollableScrollPhysics(),
              backgroundDecoration: BoxDecoration(color: bg),
              // Configurații pentru calitate maximă
              builders: PdfViewBuilders<DefaultBuilderOptions>(
                options: const DefaultBuilderOptions(),
                documentLoaderBuilder: (_) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      const Text('Încărcare document...'),
                    ],
                  ),
                ),
                pageLoaderBuilder: (_) => Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                    strokeWidth: 2,
                  ),
                ),
                pageBuilder: (context, future, page) => FutureBuilder<PdfPageImage>(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return InteractiveViewer(
                        // Permite zoom pentru calitate maximă
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: MemoryImage(snapshot.data!.bytes),
                              fit: BoxFit.contain,
                              // Filtru pentru randare de înaltă calitate
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      );
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                        strokeWidth: 2,
                      ),
                    );
                  },
                ),
              ),
              onPageChanged: (page) {
                if (mounted) {
                  setState(() {
                    _currentPage = page;
                  });
                }
              },
              onDocumentLoaded: (document) {
                print('Document PDF încărcat cu succes - calitate maximă activată');
              },
              onDocumentError: (error) {
                if (mounted) {
                  setState(() {
                    _error = error.toString();
                  });
                }
              },
            ),
          ),

          // ---------------- UI OVERLAY (doar în modul non-fullscreen) -------
          if (!_isFullscreen) ...[
            // BACK BUTTON
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),

            // SEARCH/GO TO PAGE BUTTON
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 64,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _showSearch ? Icons.close : Icons.location_searching,
                    color: Colors.white,
                  ),
                  onPressed: _toggleSearch,
                ),
              ),
            ),

            // PAGE INDICATOR
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],

          // ---------------- GO TO PAGE PANEL -----------------------------------
          if (_showSearch && !_isFullscreen)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 16,
              right: 16,
              child: Material(
                color: _dark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                elevation: 12,
                shadowColor: Colors.black26,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Navigare rapidă',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Go to page input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: textColor, fontSize: 16),
                              decoration: InputDecoration(
                                labelText: 'Mergi la pagina',
                                labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                                hintText: 'Numărul paginii (1-$_totalPages)',
                                hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                                prefixIcon: Icon(Icons.bookmark, color: textColor.withOpacity(0.7)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: textColor.withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                                ),
                                filled: true,
                                fillColor: _dark ? Colors.grey[800] : Colors.grey[50],
                              ),
                              onChanged: (value) {
                                final page = int.tryParse(value);
                                if (page != null && page >= 1 && page <= _totalPages) {
                                  _goToPage = page;
                                }
                              },
                              onSubmitted: (value) {
                                final page = int.tryParse(value);
                                if (page != null && page >= 1 && page <= _totalPages) {
                                  _goToPage = page;
                                  _goToSpecificPage();
                                  _toggleSearch();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              _goToSpecificPage();
                              _toggleSearch();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Du-te', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Quick navigation buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _goToPage = 1;
                                _goToSpecificPage();
                                _toggleSearch();
                              },
                              icon: const Icon(Icons.first_page),
                              label: const Text('Prima'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _goToPage = _totalPages;
                                _goToSpecificPage();
                                _toggleSearch();
                              },
                              icon: const Icon(Icons.last_page),
                              label: const Text('Ultima'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Instructions
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (_dark ? Colors.blue[900] : Colors.blue[50])?.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.swipe,
                              color: Theme.of(context).primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Swipe stânga/dreapta pentru navigare • Tap pentru fullscreen',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.8),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ---------------- FULLSCREEN EXIT HINT ---------------------------
          if (_isFullscreen)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Apasă pentru a ieși din fullscreen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
