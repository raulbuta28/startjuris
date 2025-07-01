import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

import '../utils/epub_utils.dart';

class EbookReaderPage extends StatefulWidget {
  final String title;
  final String url;
  const EbookReaderPage({super.key, required this.title, required this.url});

  @override
  State<EbookReaderPage> createState() => _EbookReaderPageState();
}

class _EbookReaderPageState extends State<EbookReaderPage> {
  PageController? _pageController;
  List<Paragraph> _paragraphs = [];
  bool _loading = true;
  bool _showButton = false;
  bool _darkMode = false;
  double _fontSize = 16;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await http.get(Uri.parse(widget.url));
      if (res.statusCode == 200) {
        final book = await EpubDocument.openData(res.bodyBytes);
        final chapters = parseChapters(book);
        final parsed = parseParagraphs(chapters);
        _paragraphs = parsed.flatParagraphs;
        _pageController = PageController();
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        double tempFont = _fontSize;
        bool tempDark = _darkMode;
        final searchCtrl = TextEditingController();
        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('Mărime text'),
                    Expanded(
                      child: Slider(
                        min: 12,
                        max: 30,
                        value: tempFont,
                        onChanged: (v) => setModalState(() => tempFont = v),
                      ),
                    ),
                  ],
                ),
                SwitchListTile(
                  title: const Text('Mod întunecat'),
                  value: tempDark,
                  onChanged: (v) => setModalState(() => tempDark = v),
                ),
                TextField(
                  controller: searchCtrl,
                  decoration: const InputDecoration(labelText: 'Cautați'),
                  onSubmitted: (val) {
                    _performSearch(val);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _fontSize = tempFont;
                      _darkMode = tempDark;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Aplică'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _performSearch(String query) {
    final idx = _paragraphs.indexWhere(
      (p) => p.element.text.toLowerCase().contains(query.toLowerCase()),
    );
    if (idx >= 0) {
      _pageController?.jumpToPage(idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _darkMode ? ThemeData.dark() : ThemeData.light();
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => setState(() => _showButton = !_showButton),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: _paragraphs.length,
                        itemBuilder: (context, index) {
                          final html = _paragraphs[index].element.outerHtml;
                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Html(
                              data: html,
                              style: {
                                'html': Style.fromTextStyle(
                                  TextStyle(fontSize: _fontSize, height: 1.4),
                                ),
                              },
                            ),
                          );
                        },
                      ),
              ),
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (_showButton)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _openSettings,
                    child: const Icon(Icons.settings),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
