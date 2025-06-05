import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';

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

class _PovesteRePageState extends State<PovesterePage> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _readerModeController;
  late Animation<double> _readerModeAnimation;
  bool _showProgress = false;
  bool _isReaderMode = false;
  
  // Local state management
  double _fontSize = 16.0;
  double _lineHeight = 1.5;
  bool _isDarkMode = false;
  Color _backgroundColor = Colors.white;
  Color _textColor = Colors.black87;
  String _fontFamily = 'Roboto';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _readerModeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _readerModeAnimation = CurvedAnimation(
      parent: _readerModeController,
      curve: Curves.easeInOutCubic,
    );
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_showProgress) {
      setState(() => _showProgress = true);
    } else if (_scrollController.offset <= 100 && _showProgress) {
      setState(() => _showProgress = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _readerModeController.dispose();
    super.dispose();
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      if (_isDarkMode) {
        _backgroundColor = const Color(0xFF121212);
        _textColor = Colors.white;
      } else {
        _backgroundColor = Colors.white;
        _textColor = Colors.black87;
      }
    });
  }

  void _updateFontSize(double value) {
    setState(() {
      _fontSize = value;
    });
  }

  void _updateLineHeight(double value) {
    setState(() {
      _lineHeight = value;
    });
  }

  Widget _buildContent() {
    return Html(
      data: widget.continut,
      style: {
        "body": Style(
          fontSize: FontSize(_fontSize),
          lineHeight: LineHeight(_lineHeight),
          color: _textColor,
          fontFamily: _fontFamily,
          backgroundColor: _backgroundColor,
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _isReaderMode ? null : AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: _textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.titlu,
          style: GoogleFonts.roboto(
            color: _textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isReaderMode ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
              color: _textColor,
            ),
            onPressed: () {
              setState(() {
                _isReaderMode = !_isReaderMode;
                if (_isReaderMode) {
                  _readerModeController.forward();
                } else {
                  _readerModeController.reverse();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: _textColor),
            onPressed: _showSettingsModal,
          ),
        ],
      ),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              if (!_isReaderMode)
                SliverToBoxAdapter(
                  child: Hero(
                    tag: widget.imagine,
                    child: Image.asset(
                      widget.imagine,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(
                    horizontal: _isReaderMode ? 40 : 20,
                    vertical: _isReaderMode ? 40 : 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_isReaderMode) ...[
                        const SizedBox(height: 20),
                        Text(
                          widget.titlu,
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      _buildContent(),
                    ],
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
              child: Container(
                padding: const EdgeInsets.all(16),
                color: _backgroundColor,
                child: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: widget.progress / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${widget.progress.toStringAsFixed(0)}%',
                      style: GoogleFonts.roboto(
                        color: _textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Setări citire',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Dimensiune text',
                style: GoogleFonts.roboto(color: _textColor),
              ),
              Slider(
                value: _fontSize,
                min: 12,
                max: 24,
                divisions: 12,
                label: _fontSize.round().toString(),
                onChanged: (value) {
                  setModalState(() {});
                  _updateFontSize(value);
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Înălțime rânduri',
                style: GoogleFonts.roboto(color: _textColor),
              ),
              Slider(
                value: _lineHeight,
                min: 1.0,
                max: 2.0,
                divisions: 10,
                label: _lineHeight.toStringAsFixed(1),
                onChanged: (value) {
                  setModalState(() {});
                  _updateLineHeight(value);
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Mod citire',
                style: GoogleFonts.roboto(color: _textColor),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildThemeOption(
                    'Lumină',
                    Colors.white,
                    Colors.black87,
                    !_isDarkMode,
                    () {
                      setModalState(() {});
                      _toggleDarkMode();
                    },
                  ),
                  _buildThemeOption(
                    'Întuneric',
                    const Color(0xFF121212),
                    Colors.white,
                    _isDarkMode,
                    () {
                      setModalState(() {});
                      _toggleDarkMode();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    String label,
    Color bgColor,
    Color textColor,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: isSelected
                ? Icon(Icons.check, color: textColor)
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.roboto(color: _textColor),
          ),
        ],
      ),
    );
  }
} 