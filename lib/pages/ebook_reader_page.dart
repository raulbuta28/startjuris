import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

import '../utils/epub_utils.dart';

class PremiumEbookReaderPage extends StatefulWidget {
  final String title;
  final String url;
  const PremiumEbookReaderPage({super.key, required this.title, required this.url});

  @override
  State<PremiumEbookReaderPage> createState() => _PremiumEbookReaderPageState();
}

class _PremiumEbookReaderPageState extends State<PremiumEbookReaderPage>
    with TickerProviderStateMixin {
  PageController? _pageController;
  ScrollController? _thumbnailController;
  List<PageData> _pages = [];
  bool _loading = true;
  bool _showUI = false;
  bool _darkMode = false;
  bool _showThumbnails = false;
  bool _showSettings = false;
  double _fontSize = 18;
  double _lineHeight = 1.6;
  int _currentPage = 0;
  String _selectedFont = 'System';
  Color _backgroundColor = Colors.white;
  Color _textColor = Colors.black87;
  
  // Animation controllers
  late AnimationController _uiAnimationController;
  late AnimationController _thumbnailAnimationController;
  late AnimationController _settingsAnimationController;
  late Animation<double> _uiAnimation;
  late Animation<double> _thumbnailAnimation;
  late Animation<Offset> _settingsSlideAnimation;

  final List<String> _fontOptions = ['System', 'Georgia', 'Times', 'Palatino', 'Charter'];
  final List<Color> _backgroundOptions = [
    Colors.white,
    const Color(0xFFFFF8E1), // Sepia
    const Color(0xFF1E1E1E), // Dark
    const Color(0xFF0D1117), // True Black
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _load();
  }

  void _initAnimations() {
    _uiAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _thumbnailAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _settingsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _uiAnimation = CurvedAnimation(
      parent: _uiAnimationController,
      curve: Curves.easeInOut,
    );
    _thumbnailAnimation = CurvedAnimation(
      parent: _thumbnailAnimationController,
      curve: Curves.elasticOut,
    );
    _settingsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _settingsAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _uiAnimationController.dispose();
    _thumbnailAnimationController.dispose();
    _settingsAnimationController.dispose();
    _thumbnailController?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final res = await http.get(Uri.parse(widget.url));
      if (res.statusCode == 200) {
        final book = await EpubDocument.openData(res.bodyBytes);
        final chapters = parseChapters(book);
        _pages = parsePages(chapters);
        _pageController = PageController();
        _thumbnailController = ScrollController();
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _toggleUI() {
    HapticFeedback.lightImpact();
    setState(() => _showUI = !_showUI);
    if (_showUI) {
      _uiAnimationController.forward();
    } else {
      _uiAnimationController.reverse();
      if (_showThumbnails) _toggleThumbnails();
      if (_showSettings) _toggleSettings();
    }
  }

  void _toggleThumbnails() {
    HapticFeedback.mediumImpact();
    setState(() => _showThumbnails = !_showThumbnails);
    if (_showThumbnails) {
      _thumbnailAnimationController.forward();
      _scrollToCurrentThumbnail();
    } else {
      _thumbnailAnimationController.reverse();
    }
  }

  void _toggleSettings() {
    HapticFeedback.mediumImpact();
    setState(() => _showSettings = !_showSettings);
    if (_showSettings) {
      _settingsAnimationController.forward();
    } else {
      _settingsAnimationController.reverse();
    }
  }

  void _scrollToCurrentThumbnail() {
    if (_thumbnailController != null && _pages.isNotEmpty) {
      final itemWidth = 80.0;
      final targetOffset = _currentPage * itemWidth - (MediaQuery.of(context).size.width / 2) + (itemWidth / 2);
      _thumbnailController!.animateTo(
        targetOffset.clamp(0.0, _thumbnailController!.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _goToPage(int index) {
    HapticFeedback.selectionClick();
    _pageController?.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    if (_showThumbnails) _toggleThumbnails();
  }

  void _performSearch(String query) {
    final idx = _pages.indexWhere(
      (p) => p.preview.toLowerCase().contains(query.toLowerCase()),
    );
    if (idx >= 0) {
      _goToPage(idx);
    }
  }

  String _getFontFamily() {
    switch (_selectedFont) {
      case 'Georgia': return 'Georgia';
      case 'Times': return 'Times New Roman';
      case 'Palatino': return 'Palatino';
      case 'Charter': return 'Charter';
      default: return 'System';
    }
  }

  Widget _buildPage(int index) {
    final html = _pages[index].html;
    return Container(
      color: _backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            const SizedBox(height: 40), // Space for top UI
            Html(
              data: html,
              style: {
                'html': Style.fromTextStyle(
                  TextStyle(
                    fontSize: _fontSize,
                    height: _lineHeight,
                    color: _textColor,
                    fontFamily: _getFontFamily(),
                    letterSpacing: 0.2,
                  ),
                ),
                'p': Style(
                  margin: Margins.only(bottom: 16),
                  textAlign: TextAlign.justify,
                ),
                'h1, h2, h3, h4, h5, h6': Style(
                  fontWeight: FontWeight.w600,
                  margin: Margins.only(top: 24, bottom: 16),
                ),
              },
            ),
            const SizedBox(height: 100), // Space for bottom UI
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(int index) {
    final isSelected = index == _currentPage;
    final preview = _pages[index].preview;
    return GestureDetector(
      onTap: () => _goToPage(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 60,
        height: 80,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade400,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                preview,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.blue.shade900 : Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${index + 1}',
              style: TextStyle(
                color: isSelected ? Colors.blue.shade900 : Colors.grey.shade600,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(_uiAnimation),
      child: Container(
        decoration: BoxDecoration(
          color: _backgroundColor.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: _textColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_pages.isNotEmpty)
                        Text(
                          'Pagina ${_currentPage + 1} din ${_pages.length}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _textColor.withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _toggleSettings,
                  icon: const Icon(Icons.tune),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: _textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_uiAnimation),
      child: Container(
        decoration: BoxDecoration(
          color: _backgroundColor.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: _currentPage > 0 
                    ? () => _goToPage(_currentPage - 1)
                    : null,
                  icon: const Icon(Icons.chevron_left),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: _textColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _pages.isEmpty
                        ? 0
                        : (_currentPage + 1) / _pages.length,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _currentPage < _pages.length - 1
                    ? () => _goToPage(_currentPage + 1)
                    : null,
                  icon: const Icon(Icons.chevron_right),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: _textColor,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _toggleThumbnails,
                  icon: const Icon(Icons.view_module),
                  style: IconButton.styleFrom(
                    backgroundColor: _showThumbnails 
                      ? Colors.blue 
                      : Colors.grey.shade200,
                    foregroundColor: _showThumbnails 
                      ? Colors.white 
                      : _textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailStrip() {
    return AnimatedBuilder(
      animation: _thumbnailAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _thumbnailAnimation.value) * 100),
          child: Opacity(
            opacity: _thumbnailAnimation.value.clamp(0.0, 1.0),
            child: Container(
              height: 100,
              margin: const EdgeInsets.only(bottom: 80),
              decoration: BoxDecoration(
                color: _backgroundColor.withOpacity(0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ListView.builder(
                controller: _thumbnailController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _buildThumbnail(index),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsPanel() {
    return AnimatedBuilder(
      animation: _settingsSlideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _settingsSlideAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Font Size
                    Row(
                      children: [
                        Icon(Icons.text_fields, color: _textColor),
                        const SizedBox(width: 12),
                        Text('Mărime text', style: TextStyle(color: _textColor, fontWeight: FontWeight.w500)),
                        const Spacer(),
                        Text('${_fontSize.round()}', style: TextStyle(color: _textColor.withOpacity(0.7))),
                      ],
                    ),
                    Slider(
                      value: _fontSize,
                      min: 12,
                      max: 32,
                      divisions: 20,
                      onChanged: (value) => setState(() => _fontSize = value),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Line Height
                    Row(
                      children: [
                        Icon(Icons.format_line_spacing, color: _textColor),
                        const SizedBox(width: 12),
                        Text('Spațiere rânduri', style: TextStyle(color: _textColor, fontWeight: FontWeight.w500)),
                        const Spacer(),
                        Text('${_lineHeight.toStringAsFixed(1)}', style: TextStyle(color: _textColor.withOpacity(0.7))),
                      ],
                    ),
                    Slider(
                      value: _lineHeight,
                      min: 1.0,
                      max: 2.5,
                      divisions: 15,
                      onChanged: (value) => setState(() => _lineHeight = value),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Font Selection
                    Text('Font', style: TextStyle(color: _textColor, fontWeight: FontWeight.w500, fontSize: 16)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _fontOptions.map((font) {
                        final isSelected = _selectedFont == font;
                        return ChoiceChip(
                          label: Text(font),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedFont = font);
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Background Colors
                    Text('Fundal', style: TextStyle(color: _textColor, fontWeight: FontWeight.w500, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _backgroundOptions.map((color) {
                        final isSelected = _backgroundColor == color;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _backgroundColor = color;
                              _textColor = color == Colors.white || color == const Color(0xFFFFF8E1)
                                ? Colors.black87
                                : Colors.white;
                            });
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey.shade400,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: isSelected 
                              ? const Icon(Icons.check, color: Colors.blue)
                              : null,
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Search
                    TextField(
                      style: TextStyle(color: _textColor),
                      decoration: InputDecoration(
                        labelText: 'Căutați în carte',
                        prefixIcon: Icon(Icons.search, color: _textColor.withOpacity(0.7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (value) {
                        _performSearch(value);
                        _toggleSettings();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // Main content
          GestureDetector(
            onTap: _toggleUI,
            child: _loading
                ? Container(
                    color: _backgroundColor,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) => _buildPage(index),
                  ),
          ),
          
          // Top bar
          if (_showUI)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(),
            ),
          
          // Bottom bar
          if (_showUI)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(),
            ),
          
          // Thumbnail strip
          if (_showThumbnails)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildThumbnailStrip(),
            ),
          
          // Settings panel
          if (_showSettings)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildSettingsPanel(),
            ),
        ],
      ),
    );
  }
}
