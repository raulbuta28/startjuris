import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:math' as math;

class PovesterePage extends StatefulWidget {
  final String titlu;
  final String imagine;
  final String continut;
  final double progress;

  const PovesterePage({
    Key? key,
    required this.titlu,
    required this.imagine,
    required this.continut,
    required this.progress,
  }) : super(key: key);

  @override
  State<PovesterePage> createState() => _PovesteRePageState();
}

class _PovesteRePageState extends State<PovesterePage>
    with TickerProviderStateMixin {
  // Controllers pentru animatii
  late ScrollController _scrollController;
  late AnimationController _readerModeController;
  late AnimationController _progressController;
  late AnimationController _backgroundController;
  late AnimationController _readingStatsController;
  late AnimationController _pageTransitionController;
  late AnimationController _textAnimationController;

  // Animatii
  late Animation<double> _readerModeAnimation;
  late Animation<double> _progressAnimation;
  late Animation<Color?> _backgroundAnimation;
  late Animation<double> _readingStatsAnimation;
  late Animation<double> _pageTransitionAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  // State
  bool _showProgress = false;
  bool _isReaderMode = false;
  bool _showReadingStats = false;
  double _currentProgress = 0.0;
  int _wordsRead = 0;
  int _timeSpent = 0;
  int _currentPage = 1;
  int _totalPages = 1;
  DateTime _sessionStartTime = DateTime.now();

  // Settings
  double _fontSize = 18.0;
  double _lineHeight = 1.4;
  double _letterSpacing = 0.5;
  double _wordSpacing = 1.0;
  double _paragraphSpacing = 16.0;
  bool _isDarkMode = false;
  bool _isSepia = false;
  bool _isNightMode = false;

  Color _backgroundColor = const Color(0xFFFFFBF7);
  Color _textColor = const Color(0xFF2C2C2E);
  Color _accentColor = const Color(0xFF007AFF);
  String _fontFamily = GoogleFonts.literata().fontFamily ?? '';

  int _totalWordsInStory = 0;
  double _readingSpeed = 200;
  Duration _estimatedTimeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _calculateStoryStats();
    _scrollController = ScrollController()..addListener(_onScroll);
    _startReadingSession();
  }

  void _initializeControllers() {
    _readerModeController =
        AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _progressController =
        AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _backgroundController =
        AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _readingStatsController =
        AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _pageTransitionController =
        AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _textAnimationController =
        AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

    _setupAnimations();
  }

  void _setupAnimations() {
    _readerModeAnimation = CurvedAnimation(
      parent: _readerModeController,
      curve: Curves.easeInOutCubicEmphasized,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutExpo,
    );

    _backgroundAnimation = ColorTween(
      begin: _backgroundColor,
      end: const Color(0xFF1C1C1E),
    ).animate(_backgroundController);

    _readingStatsAnimation = CurvedAnimation(
      parent: _readingStatsController,
      curve: Curves.elasticOut,
    );

    _pageTransitionAnimation = CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeInOutCubic,
    );

    _textFadeAnimation = CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.easeInOut,
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(_textAnimationController);
  }

  void _calculateStoryStats() {
    final words = widget.continut.replaceAll(RegExp(r'<[^>]*>'), '').split(' ');
    _totalWordsInStory = words.where((w) => w.trim().isNotEmpty).length;
    _totalPages = (_totalWordsInStory / 250).ceil();
    _estimatedTimeLeft =
        Duration(minutes: (_totalWordsInStory / _readingSpeed).round());
  }

  void _startReadingSession() {
    _sessionStartTime = DateTime.now();
    _textAnimationController.forward();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    if (maxScroll > 0) {
      final newProgress = (currentScroll / maxScroll * 100).clamp(0.0, 100.0);
      setState(() {
        _currentProgress = newProgress;
        _wordsRead = (_totalWordsInStory * newProgress / 100).round();
        _currentPage =
            (newProgress / 100 * _totalPages).ceil().clamp(1, _totalPages);
      });
      _progressController.animateTo(newProgress / 100);
    }

    if (currentScroll > 150 && !_showProgress) {
      setState(() => _showProgress = true);
    } else if (currentScroll <= 150 && _showProgress) {
      setState(() => _showProgress = false);
    }

    _timeSpent = DateTime.now().difference(_sessionStartTime).inSeconds;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _readerModeController.dispose();
    _progressController.dispose();
    _backgroundController.dispose();
    _readingStatsController.dispose();
    _pageTransitionController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  void _toggleTheme(String theme) {
    setState(() {
      _isDarkMode = false;
      _isSepia = false;
      _isNightMode = false;

      switch (theme) {
        case 'light':
          _backgroundColor = const Color(0xFFFFFBF7);
          _textColor = const Color(0xFF2C2C2E);
          _accentColor = const Color(0xFF007AFF);
          break;
        case 'dark':
          _isDarkMode = true;
          _backgroundColor = const Color(0xFF1C1C1E);
          _textColor = const Color(0xFFE5E5E7);
          _accentColor = const Color(0xFF0A84FF);
          break;
        case 'sepia':
          _isSepia = true;
          _backgroundColor = const Color(0xFFF7F3E9);
          _textColor = const Color(0xFF5D4E37);
          _accentColor = const Color(0xFF8B4513);
          break;
        case 'night':
          _isNightMode = true;
          _backgroundColor = const Color(0xFF000000);
          _textColor = const Color(0xFF48484A);
          _accentColor = const Color(0xFF32D74B);
          break;
      }
    });

    _backgroundController.forward().then((_) => _backgroundController.reset());
  }

  void _toggleReaderMode() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isReaderMode = !_isReaderMode;
      if (_isReaderMode) {
        _readerModeController.forward();
      } else {
        _readerModeController.reverse();
      }
    });
  }

  void _toggleReadingStats() {
    setState(() {
      _showReadingStats = !_showReadingStats;
      if (_showReadingStats) {
        _readingStatsController.forward();
      } else {
        _readingStatsController.reverse();
      }
    });
  }

  Widget _buildPremiumContent() {
    return AnimatedBuilder(
      animation: _textFadeAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _textSlideAnimation,
          child: FadeTransition(
            opacity: _textFadeAnimation,
            child: Html(
              data: widget.continut,
              style: {
                'body': Style(
                  fontSize: FontSize(_fontSize),
                  lineHeight: LineHeight(_lineHeight),
                  color: _textColor,
                  fontFamily: _fontFamily,
                  backgroundColor: _backgroundColor,
                  letterSpacing: _letterSpacing,
                  wordSpacing: _wordSpacing,
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
                'p': Style(
                  margin: Margins.only(bottom: _paragraphSpacing),
                  textAlign: TextAlign.justify,
                ),
                'h1, h2, h3': Style(
                  fontWeight: FontWeight.w700,
                  margin: Margins.only(top: 24, bottom: 16),
                ),
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingProgress() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _showProgress ? 0 : 100),
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: _backgroundColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: _textColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Pagina \$_currentPage din \$_totalPages',
                      style: GoogleFonts.sfProText(
                        color: _textColor.withOpacity(0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\${_currentProgress.toStringAsFixed(0)}%',
                      style: GoogleFonts.sfProText(
                        color: _accentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: _textColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: _progressAnimation.value,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_accentColor, _accentColor.withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\${_wordsRead} cuvinte citite',
                      style: GoogleFonts.sfProText(
                        color: _textColor.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '~\${(_estimatedTimeLeft.inMinutes * (1 - _currentProgress / 100)).round()} min rămas',
                      style: GoogleFonts.sfProText(
                        color: _textColor.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReadingStats() {
    return AnimatedBuilder(
      animation: _readingStatsAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _readingStatsAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Statistici citire',
                  style: GoogleFonts.sfProDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Timp citit',
                      '\${(_timeSpent / 60).floor()}m \${_timeSpent % 60}s',
                      Icons.access_time_rounded,
                    ),
                    _buildStatItem(
                      'Cuvinte/min',
                      '\${(_wordsRead / math.max(_timeSpent / 60, 0.1)).round()}',
                      Icons.speed_rounded,
                    ),
                    _buildStatItem(
                      'Progres',
                      '\${_currentProgress.toStringAsFixed(0)}%',
                      Icons.trending_up_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _accentColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.sfProDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.sfProText(
            fontSize: 12,
            color: _textColor.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      color: _backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: _isReaderMode ? null : _buildPremiumAppBar(),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _backgroundColor,
                    _backgroundColor.withOpacity(0.95),
                  ],
                ),
              ),
            ),
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                    top: _isReaderMode ? 60 : 100,
                    left: 24,
                    right: 24,
                    bottom: 100,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: _buildPremiumContent(),
                    ),
                  ),
                ),
              ],
            ),
            if (_showProgress && !_isReaderMode)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildFloatingProgress(),
              ),
            if (_showReadingStats)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(child: _buildReadingStats()),
                ),
              ),
            if (_isReaderMode)
              Positioned(
                top: 50,
                right: 20,
                child: _buildReaderModeControls(),
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildPremiumAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _backgroundColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _textColor.withOpacity(0.1)),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        widget.titlu,
        style: GoogleFonts.sfProDisplay(
          color: _textColor,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
      ),
      centerTitle: true,
      actions: [
        _buildAppBarButton(
          Icons.auto_graph_rounded,
          _toggleReadingStats,
        ),
        _buildAppBarButton(
          _isReaderMode ? Icons.chrome_reader_mode : Icons.chrome_reader_mode_outlined,
          _toggleReaderMode,
        ),
        _buildAppBarButton(
          Icons.tune_rounded,
          _showPremiumSettingsModal,
        ),
      ],
    );
  }

  Widget _buildAppBarButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: _backgroundColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _textColor.withOpacity(0.1)),
      ),
      child: IconButton(
        icon: Icon(icon, color: _textColor, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildReaderModeControls() {
    return AnimatedBuilder(
      animation: _readerModeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - _readerModeAnimation.value), 0),
          child: Opacity(
            opacity: _readerModeAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _backgroundColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: _textColor),
                    onPressed: _toggleReaderMode,
                  ),
                  IconButton(
                    icon: Icon(Icons.brightness_6_rounded, color: _textColor),
                    onPressed: _showPremiumSettingsModal,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPremiumSettingsModal() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: _buildPremiumSettings(scrollController),
        ),
      ),
    );
  }

  Widget _buildPremiumSettings(ScrollController scrollController) {
    return StatefulBuilder(
      builder: (context, setModalState) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _textColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Setări citire premium',
            style: GoogleFonts.sfProDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 30),
          _buildSettingSection('Temă', [
  _buildThemeGrid(setModalState),
  ]),
          _buildSettingSection('Tipografie', [
            _buildSliderSetting(
              'Dimensiune text',
              _fontSize,
              12,
              28,
              '\${_fontSize.round()}pt',
              (value) {
                setModalState(() => _fontSize = value);
                setState(() => _fontSize = value);
              },
            ),
            _buildSliderSetting(
              'Înălțime rânduri',
              _lineHeight,
              1.0,
              2.5,
              _lineHeight.toStringAsFixed(1),
              (value) {
                setModalState(() => _lineHeight = value);
                setState(() => _lineHeight = value);
              },
            ),
            _buildSliderSetting(
              'Spațiere litere',
              _letterSpacing,
              -0.5,
              2.0,
              _letterSpacing.toStringAsFixed(1),
              (value) {
                setModalState(() => _letterSpacing = value);
                setState(() => _letterSpacing = value);
              },
            ),
          ]),
          _buildSettingSection('Font', [
            _buildFontSelector(setModalState),
          ]),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSettingSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.sfProDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildThemeGrid(StateSetter setModalState) {
    final themes = [
      {
        'name': 'Lumină',
        'key': 'light',
        'bg': const Color(0xFFFFFBF7),
        'text': const Color(0xFF2C2C2E)
      },
      {
        'name': 'Întuneric',
        'key': 'dark',
        'bg': const Color(0xFF1C1C1E),
        'text': const Color(0xFFE5E5E7)
      },
      {
        'name': 'Sepia',
        'key': 'sepia',
        'bg': const Color(0xFFF7F3E9),
        'text': const Color(0xFF5D4E37)
      },
      {
        'name': 'Noapte',
        'key': 'night',
        'bg': const Color(0xFF000000),
        'text': const Color(0xFF48484A)
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        final isSelected = (_isDarkMode && theme['key'] == 'dark') ||
            (_isSepia && theme['key'] == 'sepia') ||
            (_isNightMode && theme['key'] == 'night') ||
            (!_isDarkMode && !_isSepia && !_isNightMode && theme['key'] == 'light');

        return GestureDetector(
          onTap: () {
            setModalState(() {});
            _toggleTheme(theme['key'] as String);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: theme['bg'] as Color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? _accentColor : _textColor.withOpacity(0.2),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _accentColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: _accentColor,
                    size: 24,
                  )
                else
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme['text'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  theme['name'] as String,
                  style: GoogleFonts.sfProText(
                    color: _textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliderSetting(
    String label,
    double value,
    double min,
    double max,
    String displayValue,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.sfProText(
                color: _textColor.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                displayValue,
                style: GoogleFonts.sfProText(
                  color: _accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          onChanged: onChanged,
          min: min,
          max: max,
          activeColor: _accentColor,
          inactiveColor: _accentColor.withOpacity(0.2),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFontSelector(StateSetter setModalState) {
    final fonts = [
      {'name': 'Literata', 'font': GoogleFonts.literata().fontFamily},
      {'name': 'Open Sans', 'font': GoogleFonts.openSans().fontFamily},
      {'name': 'Roboto', 'font': GoogleFonts.roboto().fontFamily},
      {'name': 'Montserrat', 'font': GoogleFonts.montserrat().fontFamily},
    ];

    return Wrap(
      spacing: 12,
      children: fonts.map((font) {
        final selected = _fontFamily == font['font'];
        return ChoiceChip(
          label: Text(
            font['name'] as String,
            style: GoogleFonts.getFont(font['name'] as String,
                color: selected ? _accentColor : _textColor),
          ),
          selected: selected,
          onSelected: (_) {
            setModalState(() => _fontFamily = font['font'] as String? ?? '');
            setState(() => _fontFamily = font['font'] as String? ?? '');
          },
          selectedColor: _accentColor.withOpacity(0.1),
        );
      }).toList(),
    );
  }

