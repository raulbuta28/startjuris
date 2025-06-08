import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/code_text.dart';
import 'backend/providers/auth_provider.dart';
import 'backend/services/api_service.dart';

class ModernCodeReader extends StatefulWidget {
  final String codeId;
  final String codeTitle;
  const ModernCodeReader({Key? key, required this.codeId, required this.codeTitle}) : super(key: key);

  @override
  State<ModernCodeReader> createState() => _ModernCodeReaderState();
}

class _ModernCodeReaderState extends State<ModernCodeReader> {
  List<Widget> _contentWidgets = [];
  List<CodeTextSection> _sections = [];
  bool _loading = true;
  String? _error;
  double _fontSize = 12.0;
  bool _isDarkMode = false;
  final Set<String> _favoriteArticles = {};
  final Set<String> _highlightedArticles = {};
  final Set<String> _savedArticles = {};

  final List<_ArticleRef> _allArticles = [];
  int _selectedTab = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<_SearchResult> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _load();
    _loadPreferences();
  }

  Future<void> _load() async {
    final baseUrl = ApiService.baseUrl.replaceFirst('/api', '');
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/code-text-json/${widget.codeId}'));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          if (mounted) {
            setState(() {
              _sections = decoded.map((e) => CodeTextSection.fromJson(e as Map<String, dynamic>)).toList();
              _contentWidgets = _buildContentWidgets(_sections);
            });
          }
        } else {
          if (mounted) setState(() { _error = 'Invalid data format'; });
        }
      } else if (res.statusCode == 404) {
        final txtRes = await http.get(Uri.parse('$baseUrl/api/code-text/${widget.codeId}'));
        if (!mounted) return;
        if (txtRes.statusCode == 200) {
          final filtered = _filterCodeText(txtRes.body);
          final parsed = _parseText(filtered);
          if (mounted) setState(() {
            _sections = parsed;
            _contentWidgets = _buildContentWidgets(parsed);
          });
        } else {
          if (mounted) setState(() { _error = 'Failed to load code'; });
        }
      } else {
        if (mounted) setState(() { _error = 'Failed to load code'; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
      _buildArticleIndex();
    }
  }

  Future<void> _togglePreference(String kind, String articleId, Set<String> set) async {
    setState(() {
      if (set.contains(articleId)) {
        set.remove(articleId);
      } else {
        set.add(articleId);
      }
    });

    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated && auth.token != null) {
      final api = ApiService(token: auth.token);
      try {
        await api.post('/$kind', data: {'id': articleId});
      } catch (_) {}
    }
  }

  Future<void> _loadPreferences() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated || auth.token == null) return;
    final api = ApiService(token: auth.token);
    try {
      final likesRes = await api.get('/likes');
      if (likesRes.statusCode == 200 && likesRes.data is Map) {
        final data = likesRes.data as Map;
        setState(() {
          _favoriteArticles.clear();
          _favoriteArticles.addAll(List<String>.from(data['likes'] ?? []));
        });
      }
      final favRes = await api.get('/favorites');
      if (favRes.statusCode == 200 && favRes.data is Map) {
        final data = favRes.data as Map;
        setState(() {
          _highlightedArticles.clear();
          _highlightedArticles.addAll(List<String>.from(data['favorites'] ?? []));
        });
      }
      final savedRes = await api.get('/saved');
      if (savedRes.statusCode == 200 && savedRes.data is Map) {
        final data = savedRes.data as Map;
        setState(() {
          _savedArticles.clear();
          _savedArticles.addAll(List<String>.from(data['saved'] ?? []));
        });
      }
    } catch (_) {}
  }

  List<Widget> _buildContentWidgets(List<CodeTextSection> sections) {
    final widgets = <Widget>[];
    for (var section in sections) {
      widgets.add(_buildSection(section));
      for (var content in section.content) {
        if (content is CodeTextSection) {
          widgets.addAll(_buildContentWidgets([content]));
        } else if (content is CodeTextArticle) {
          widgets.add(_buildArticle(content));
        } else if (content is CodeTextNote) {
          widgets.add(_buildNote(content));
        }
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor: _isDarkMode ? Colors.black : Colors.white,
        appBar: AppBar(
          title: Text(
            widget.codeTitle,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search,
                  color: _isDarkMode ? Colors.white : Colors.black87, size: 24),
              onPressed: _onSearch,
            ),
            IconButton(
              icon: Icon(Icons.settings, color: _isDarkMode ? Colors.white : Colors.black87, size: 24),
              onPressed: _showSettings,
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _isSearching
                    ? _buildSearchView()
                    : _selectedTab == 0
                        ? ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                            physics: const ClampingScrollPhysics(),
                            children: _contentWidgets,
                          )
                        : PlaceholderPage(
                            tabIndex: _selectedTab,
                            favoriteArticles: _favoriteArticles,
                            highlightedArticles: _highlightedArticles,
                            savedArticles: _savedArticles,
                            allArticles: _allArticles,
                            articleBuilder: _buildArticle,
                          ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTab,
          onTap: (i) {
            setState(() => _selectedTab = i);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(color: Colors.black54),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.article),
              label: 'Coduri',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: 'Evidențiate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark),
              label: 'Salvate',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(CodeTextSection section) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Container(
        constraints: BoxConstraints.tightFor(
          width: MediaQuery.of(context).size.width - 8,
        ),
        child: Text(
          '${section.type} ${section.name}',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: _fontSize + 2,
            color: _isDarkMode ? Colors.white : Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildArticle(CodeTextArticle article) {
    final articleId = '${article.number}-${article.title}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        constraints: BoxConstraints.tightFor(
          width: MediaQuery.of(context).size.width - 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.number.isNotEmpty || article.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Art. ${article.number} ${article.title}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: _fontSize + 4,
                          color: _isDarkMode ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        _favoriteArticles.contains(articleId) ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => _togglePreference('likes', articleId, _favoriteArticles),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        _highlightedArticles.contains(articleId) ? Icons.star : Icons.star_border,
                        color: Colors.yellow[700],
                        size: 20,
                      ),
                      onPressed: () => _togglePreference('favorites', articleId, _highlightedArticles),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        _savedArticles.contains(articleId) ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.blue,
                        size: 20,
                      ),
                      onPressed: () => _togglePreference('saved', articleId, _savedArticles),
                    ),
                  ],
                ),
              ),
            ...article.content.map(
              (l) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                child: Text(
                  l,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: _isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ),
            if (article.amendments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: article.amendments
                      .map((a) => Text(
                            a,
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: _fontSize - 2,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: _isDarkMode ? Colors.white54 : Colors.black54,
                            ),
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNote(CodeTextNote note) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        constraints: BoxConstraints.tightFor(
          width: MediaQuery.of(context).size.width - 8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.yellow.shade100,
              Colors.blue.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: note.content.map(
            (l) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              child: Text(
                l,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: _fontSize - 2,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: _isDarkMode ? Colors.black87 : Colors.black87,
                ),
              ),
            ),
          ).toList(),
        ),
      ),
    );
  }

  String _filterCodeText(String text) {
    final lines = text.split(RegExp(r'\r?\n'));
    final startIndex = lines.indexWhere((line) =>
        RegExp(r'^(titlul|partea|cartea|capitolul|articolul)', caseSensitive: false).hasMatch(line.trim()));
    final sliced = startIndex >= 0 ? lines.sublist(startIndex) : lines;
    return sliced.join('\n').trim();
  }

  List<CodeTextSection> _parseText(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final List<CodeTextSection> structure = [];
    List<CodeTextSection> currentHierarchy = [];
    CodeTextArticle? currentArticle;
    CodeTextNote? currentNote;
    List<String> currentAmendments = [];
    bool expectArticleTitle = false;

    final amendmentRegex = RegExp(r'^\(la \d{2}-\d{2}-\d{4},.*\)$');
    final sectionRegex = RegExp(
        r'^(Cartea|Titlul|Capitolul|Sec[tțţ]iunea|Subsec[tțţ]iunea)\s+(.+)$',
        caseSensitive: false);
    final articleRegex = RegExp(r'^Articolul\s+(\d+)\s*(?:-\s*(.+))?$');
    final noteRegex = RegExp(r'^Notă$');
    final decisionRegex = RegExp(r'^Decizie de admitere:');

    void addToParent(dynamic item) {
      if (currentHierarchy.isNotEmpty) {
        currentHierarchy.last.content.add(item);
      } else {
        if (structure.isEmpty) {
          final sec = CodeTextSection(
              type: 'Miscellaneous',
              name: 'Introductory Notes',
              content: [item]);
          structure.add(sec);
          currentHierarchy.add(sec);
        } else {
          structure.last.content.add(item);
        }
      }
    }

    for (final line in lines) {
      if (expectArticleTitle) {
        if (!(sectionRegex.hasMatch(line) ||
            articleRegex.hasMatch(line) ||
            noteRegex.hasMatch(line) ||
            decisionRegex.hasMatch(line) ||
            amendmentRegex.hasMatch(line))) {
          if (currentArticle != null) {
            currentArticle.title = line;
          }
          expectArticleTitle = false;
          continue;
        }
        expectArticleTitle = false;
      }

      if (amendmentRegex.hasMatch(line)) {
        if (currentArticle != null) {
          currentAmendments.add(line);
        }
        continue;
      }

      if (noteRegex.hasMatch(line) || decisionRegex.hasMatch(line)) {
        if (currentArticle != null) {
          currentArticle.amendments = List.from(currentAmendments);
          currentAmendments.clear();
          addToParent(currentArticle);
          currentArticle = null;
        }
        if (currentNote != null) {
          addToParent(currentNote);
        }
        currentNote = CodeTextNote(
            type: noteRegex.hasMatch(line) ? 'Note' : 'Decision',
            content: [line]);
        continue;
      }

      final sm = sectionRegex.firstMatch(line);
      if (sm != null) {
        if (currentArticle != null) {
          currentArticle.amendments = List.from(currentAmendments);
          currentAmendments.clear();
          addToParent(currentArticle);
          currentArticle = null;
        }
        if (currentNote != null) {
          addToParent(currentNote);
          currentNote = null;
        }
        final type = sm.group(1) ?? '';
        final name = sm.group(2)?.replaceAll('**)', '').trim() ?? '';
        final sec = CodeTextSection(type: type, name: name, content: []);
        if (type.toLowerCase() == 'cartea') {
          structure.add(sec);
          currentHierarchy = [sec];
        } else {
          if (currentHierarchy.isEmpty) {
            structure.add(sec);
          } else {
            currentHierarchy.last.content.add(sec);
          }
          currentHierarchy.add(sec);
        }
        continue;
      }

      final am = articleRegex.firstMatch(line);
      if (am != null) {
        if (currentArticle != null) {
          currentArticle.amendments = List.from(currentAmendments);
          currentAmendments.clear();
          addToParent(currentArticle);
        }
        if (currentNote != null) {
          addToParent(currentNote);
          currentNote = null;
        }
        final num = am.group(1) ?? '';
        final title = am.group(2) ?? '';
        currentArticle =
            CodeTextArticle(number: num, title: title, content: [], amendments: []);
        expectArticleTitle = title.isEmpty;
        continue;
      }

      if (currentNote != null) {
        currentNote.content.add(line);
      } else if (currentArticle != null) {
        currentArticle.content.add(line);
      } else if (currentHierarchy.isNotEmpty) {
        final parent = currentHierarchy.last;
        if (parent.content.isEmpty ||
            parent.content.last is CodeTextSection ||
            parent.content.last is CodeTextNote) {
          parent.content.add(CodeTextArticle(
              number: '', title: '', content: [line], amendments: []));
        } else {
          (parent.content.last as CodeTextArticle).content.add(line);
        }
      } else {
        final sec = CodeTextSection(
            type: 'Miscellaneous',
            name: 'Introductory Notes',
            content: [
              CodeTextArticle(
                  number: '', title: '', content: [line], amendments: [])
            ]);
        structure.add(sec);
        currentHierarchy.add(sec);
      }
    }

    if (currentArticle != null) {
      currentArticle.amendments = List.from(currentAmendments);
      addToParent(currentArticle);
    }
    if (currentNote != null) {
      addToParent(currentNote);
    }

    void clean(List<dynamic> items) {
      for (final item in items) {
        if (item is CodeTextSection) {
          if (item.type != 'Note' && item.type != 'Decision') {
            clean(item.content);
          }
        } else if (item is CodeTextArticle) {
          if (item.title.isNotEmpty &&
              item.content.isNotEmpty &&
              item.content.first.trim().toLowerCase() ==
                  item.title.trim().toLowerCase()) {
            item.content.removeAt(0);
          }
        }
      }
    }

    clean(structure);
    return structure;
  }

  void _buildArticleIndex() {
    _allArticles.clear();
    void traverse(List<dynamic> items, List<String> path, String parentId) {
      for (final item in items) {
        if (item is CodeTextSection) {
          traverse(item.content, [...path, '${item.type} ${item.name}'], parentId);
        } else if (item is CodeTextArticle) {
          final articleId = '${item.number}-${item.title}';
          _allArticles.add(_ArticleRef(item, [...path], articleId));
        }
      }
    }

    for (final section in _sections) {
      traverse([section], ['${section.type} ${section.name}'], '');
    }
  }

  void _onSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchResults.clear();
      }
    });
  }

  void _updateSearchResults(String query) {
    final q = query.toLowerCase();
    setState(() {
      _searchResults = _allArticles.where((r) {
        if (r.article.number.toLowerCase().contains(q) ||
            r.article.title.toLowerCase().contains(q)) return true;
        return r.article.content.any((l) => l.toLowerCase().contains(q));
      }).map((r) {
        String snippet = r.article.content.firstWhere(
            (l) => l.toLowerCase().contains(q),
            orElse: () => r.article.content.isNotEmpty ? r.article.content.first : '');
        return _SearchResult(r.article, r.path, snippet);
      }).toList();
    });
  }

  void _showArticleDialog(CodeTextArticle a) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Art. ${a.number} ${a.title}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: a.content
                .map((l) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        l,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Închide',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Caută în cod...',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _updateSearchResults,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final r = _searchResults[index];
              return ListTile(
                title: Text(
                  'Art. ${r.article.number} ${r.article.title}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(r.snippet),
                onTap: () => _showArticleDialog(r.article),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) {
        double tempFontSize = _fontSize;
        bool tempDarkMode = _isDarkMode;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade100.withOpacity(0.8),
                  Colors.purple.shade100.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Setări',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.black87,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mărime text',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Slider(
                            min: 10,
                            max: 20,
                            divisions: 10,
                            value: tempFontSize,
                            label: tempFontSize.round().toString(),
                            activeColor: Colors.blueAccent,
                            inactiveColor: Colors.grey[300],
                            onChanged: (v) {
                              setState(() => tempFontSize = v);
                              this.setState(() => _fontSize = v);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mod întunecat',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Switch(
                            value: tempDarkMode,
                            activeColor: Colors.blueAccent,
                            onChanged: (v) {
                              setState(() => tempDarkMode = v);
                              this.setState(() => _isDarkMode = v);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Anulează',
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _fontSize = tempFontSize;
                              _isDarkMode = tempDarkMode;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text(
                            'OK',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

}

class PlaceholderPage extends StatelessWidget {
  final int tabIndex;
  final Set<String> favoriteArticles;
  final Set<String> highlightedArticles;
  final Set<String> savedArticles;
  final List<_ArticleRef> allArticles;
  final Widget Function(CodeTextArticle) articleBuilder;

  const PlaceholderPage({
    Key? key,
    required this.tabIndex,
    required this.favoriteArticles,
    required this.highlightedArticles,
    required this.savedArticles,
    required this.allArticles,
    required this.articleBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final articles = tabIndex == 1
        ? favoriteArticles
        : tabIndex == 2
            ? highlightedArticles
            : savedArticles;
    final message = tabIndex == 1
        ? 'Nu ai încă articole favorite.'
        : tabIndex == 2
            ? 'Nu ai încă articole evidențiate.'
            : 'Nu ai încă articole salvate.';

    if (articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tabIndex == 1
                  ? Icons.favorite_border
                  : tabIndex == 2
                      ? Icons.star_border
                      : Icons.bookmark_border,
              size: 64,
              color: isDarkMode ? Colors.white54 : Colors.black54,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final filteredArticles = allArticles.where((ref) => articles.contains(ref.articleId)).toList();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      itemCount: filteredArticles.length,
      separatorBuilder: (context, index) => Divider(
        color: isDarkMode ? Colors.white24 : Colors.black12,
        thickness: 1,
      ),
      itemBuilder: (context, index) {
        final article = filteredArticles[index].article;
        return articleBuilder(article);
      },
    );
  }
}

class _ArticleRef {
  final CodeTextArticle article;
  final List<String> path;
  final String articleId;

  _ArticleRef(this.article, this.path, this.articleId);
}

class _SearchResult {
  final CodeTextArticle article;
  final List<String> path;
  final String snippet;

  _SearchResult(this.article, this.path, this.snippet);
}

class ModernCodeSearchDelegate extends SearchDelegate<void> {
  final List<_ArticleRef> articles;

  ModernCodeSearchDelegate(this.articles);

  List<_SearchResult> _filter(String query) {
    final q = query.toLowerCase();
    return articles.where((r) {
      if (r.article.number.toLowerCase().contains(q) ||
          r.article.title.toLowerCase().contains(q)) return true;
      return r.article.content.any((l) => l.toLowerCase().contains(q));
    }).map((r) {
      String snippet = r.article.content.firstWhere(
          (l) => l.toLowerCase().contains(q),
          orElse: () => r.article.content.isNotEmpty ? r.article.content.first : '');
      return _SearchResult(r.article, r.path, snippet);
    }).toList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Caută în cod...',
                  hintStyle: TextStyle(color: Theme.of(context).hintColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[100],
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).hintColor),
                ),
                onSubmitted: (value) {
                  query = value;
                  showResults(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _filter(query);
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final r = results[index];
          return ListTile(
            title: Text(
              'Art. ${r.article.number} ${r.article.title}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
            subtitle: Text(
              r.snippet,
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
            ),
            onTap: () => _showArticle(context, r.article),
          );
        },
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  void _showArticle(BuildContext context, CodeTextArticle a) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Art. ${a.number} ${a.title}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: a.content
                .map((l) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        l,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Închide',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }
}
