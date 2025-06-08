import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/code_text.dart';
import 'backend/services/api_service.dart';

class ModernCodeReader extends StatefulWidget {
  final String codeId;
  final String codeTitle;
  const ModernCodeReader({Key? key, required this.codeId, required this.codeTitle}) : super(key: key);

  @override
  State<ModernCodeReader> createState() => _ModernCodeReaderState();
}

class _ModernCodeReaderState extends State<ModernCodeReader> {
  List<CodeTextSection> _sections = [];
  bool _loading = true;
  String? _error;
  double _fontSize = 12.0;
  bool _isDarkMode = false;

  final List<_ArticleRef> _allArticles = [];
  final Set<CodeTextArticle> _favoriteArticles = {};
  final Set<CodeTextArticle> _savedArticles = {};
  int _selectedTab = 0;
  int _articlesPerDay = 5;

  @override
  void initState() {
    super.initState();
    _load();
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
          if (mounted) setState(() { _sections = parsed; });
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
          backgroundColor: _isDarkMode ? Colors.black : Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: _isDarkMode ? Colors.white : Colors.black87, size: 24),
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
                : _buildBody(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTab,
          onTap: (i) {
            setState(() => _selectedTab = i);
            if (i == 3) _showPlanDialog();
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(color: Colors.black54),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite, size: 28, shadows: [
                Shadow(blurRadius: 2, color: Colors.black26, offset: Offset(1, 1)),
              ]),
              label: 'Favorite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star, size: 28, shadows: [
                Shadow(blurRadius: 2, color: Colors.black26, offset: Offset(1, 1)),
              ]),
              label: 'Evidențiate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark, size: 28, shadows: [
                Shadow(blurRadius: 2, color: Colors.black26, offset: Offset(1, 1)),
              ]),
              label: 'Salvate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today, size: 28, shadows: [
                Shadow(blurRadius: 2, color: Colors.black26, offset: Offset(1, 1)),
              ]),
              label: 'Plan de citit',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(CodeTextSection section) {
    final children = section.content.map((e) {
      if (e is CodeTextSection) return _buildSection(e);
      if (e is CodeTextArticle) return _buildArticle(e);
      if (e is CodeTextNote) return _buildNote(e);
      return const SizedBox();
    }).toList();

    return ExpansionTile(
      title: Text(
        '${section.type} ${section.name}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: _fontSize + 4,
          color: _isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      initiallyExpanded: true,
      tilePadding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 3, vertical: 12),
      iconColor: Colors.blueAccent,
      collapsedIconColor: Colors.grey,
      children: children,
    );
  }

  Widget _buildArticle(CodeTextArticle article) {
    final isFav = _favoriteArticles.contains(article);
    final isSaved = _savedArticles.contains(article);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.number.isNotEmpty || article.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Art. ${article.number} ${article.title}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: _fontSize + 2,
                        color: _isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isFav) {
                          _favoriteArticles.remove(article);
                        } else {
                          _favoriteArticles.add(article);
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isSaved) {
                          _savedArticles.remove(article);
                        } else {
                          _savedArticles.add(article);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ...article.content.map(
            (l) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
              child: Text(
                l,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: _fontSize,
                  color: _isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          ),
          if (article.amendments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 3, right: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: article.amendments
                    .map((a) => Text(
                          a,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: _fontSize - 2,
                            color: _isDarkMode ? Colors.white54 : Colors.black54,
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNote(CodeTextNote note) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.type == 'Decision' ? 'Decizie' : note.type,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black87,
              fontSize: _fontSize,
            ),
          ),
          ...note.content.map(
            (l) => Text(
              l,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: _fontSize - 2,
                color: _isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _filterCodeText(String text) {
    final lines = text.split(RegExp(r'\r?\n'));
    final startIndex = lines.indexWhere((line) =>
        RegExp(r'^(titlul|partea|cartea|capitolul|articolul)', caseSensitive: false)
            .hasMatch(line.trim()));
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
    void traverse(List<dynamic> items, List<String> path) {
      for (final item in items) {
        if (item is CodeTextSection) {
          traverse(item.content, [...path, '${item.type} ${item.name}']);
        } else if (item is CodeTextArticle) {
          _allArticles.add(_ArticleRef(item, path));
        }
      }
    }

    for (final sec in _sections) {
      traverse(sec.content, ['${sec.type} ${sec.name}']);
    }
  }

  Widget _buildBody() {
    if (_selectedTab == 0) {
      return _buildArticleList(_favoriteArticles.toList());
    } else if (_selectedTab == 2) {
      return _buildArticleList(_savedArticles.toList());
    }
    return _buildSectionsList();
  }

  Widget _buildSectionsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 12),
      itemCount: _sections.length,
      itemBuilder: (context, index) => _buildSection(_sections[index]),
    );
  }

  Widget _buildArticleList(List<CodeTextArticle> articles) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 12),
      itemCount: articles.length,
      itemBuilder: (context, index) => _buildArticle(articles[index]),
    );
  }

  void _onSearch() {
    showSearch(context: context, delegate: ModernCodeSearchDelegate(_allArticles));
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) {
        double tempFontSize = _fontSize;
        bool tempDarkMode = _isDarkMode;
        return AlertDialog(
          backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Setări',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Mărime text',
                    style: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.black87),
                  ),
                  Slider(
                    min: 10,
                    max: 20,
                    divisions: 10,
                    value: tempFontSize,
                    label: tempFontSize.round().toString(),
                    activeColor: Colors.blueAccent,
                    onChanged: (v) => setState(() => tempFontSize = v),
                  ),
                  ListTile(
                    title: Text(
                      'Mod întunecat',
                      style: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.black87),
                    ),
                    trailing: Switch(
                      value: tempDarkMode,
                      activeColor: Colors.blueAccent,
                      onChanged: (v) => setState(() => tempDarkMode = v),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Anulează',
                style: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.black87),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _fontSize = tempFontSize;
                  _isDarkMode = tempDarkMode;
                });
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPlanDialog() {
    int temp = _articlesPerDay;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(16),
          title: Text(
            'Plan de citit',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Articole pe zi',
                    style: TextStyle(
                      fontSize: 16,
                      color: _isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  Slider(
                    min: 1,
                    max: 20,
                    divisions: 19,
                    value: temp.toDouble(),
                    label: '$temp',
                    activeColor: Colors.blueAccent,
                    onChanged: (v) => setState(() => temp = v.round()),
                  ),
                  Text(
                    '$temp articole pe zi',
                    style: TextStyle(
                      fontSize: 14,
                      color: _isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Anulează',
                style: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.black87),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _articlesPerDay = temp);
                Navigator.pop(context);
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ArticleRef {
  final CodeTextArticle article;
  final List<String> path;
  _ArticleRef(this.article, this.path);
}

class ModernCodeSearchDelegate extends SearchDelegate<void> {
  final List<_ArticleRef> articles;

  ModernCodeSearchDelegate(this.articles);

  List<_ArticleRef> _filter(String query) {
    final q = query.toLowerCase();
    return articles.where((r) {
      if (r.article.number.toLowerCase().contains(q) ||
          r.article.title.toLowerCase().contains(q)) return true;
      return r.article.content.any((l) => l.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = query.isEmpty ? <_ArticleRef>[] : _filter(query);
    return Container(
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
            onChanged: (value) => query = value,
          ),
          if (results.isNotEmpty) ...[
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final r = results[index];
                  final path = r.path.join(' > ');
                  return ListTile(
                    title: Text(
                      'Art. ${r.article.number} ${r.article.title}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    subtitle: Text(
                      path,
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
                    ),
                    onTap: () => _showArticle(context, r.article),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

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
