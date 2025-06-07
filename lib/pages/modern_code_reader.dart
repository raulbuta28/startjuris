import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/code_text.dart';

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

  final List<_ArticleRef> _allArticles = [];
  int _selectedTab = 0;
  int _articlesPerDay = 5;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final baseUrl = const String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080');
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.codeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _onSearch,
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: _sections.map((s) => _buildSection(s)).toList(),
                  ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (i) {
          setState(() => _selectedTab = i);
          if (i == 3) _showPlanDialog();
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorite'),
          BottomNavigationBarItem(
              icon: Icon(Icons.highlight), label: 'Evidențiate'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark), label: 'Salvate'),
          BottomNavigationBarItem(
              icon: Icon(Icons.schedule), label: 'Plan de citit'),
        ],
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
      title: Text('${section.type} ${section.name}'),
      initiallyExpanded: true,
      children: children,
    );
  }

  Widget _buildArticle(CodeTextArticle article) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.number.isNotEmpty || article.title.isNotEmpty)
            Text(
              'Art. ${article.number} ${article.title}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ...article.content.map((l) => Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.yellow.shade100, Colors.yellow.shade50],
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                child: Text(
                  l,
                  textAlign: TextAlign.justify,
                ),
              )),
          if (article.amendments.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: article.amendments
                    .map((a) => Text(a, style: const TextStyle(fontSize: 12)))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNote(CodeTextNote note) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.yellow.shade100, Colors.yellow.shade50],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.type == 'Decision' ? 'Decizie' : note.type,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
          ...note.content.map(
            (l) => Text(
              l,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.justify,
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

  void _onSearch() {
    showSearch(context: context, delegate: CodeSearchDelegate(_allArticles));
  }

  void _showPlanDialog() {
    int temp = _articlesPerDay;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Setează articole/zi'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    min: 1,
                    max: 20,
                    divisions: 19,
                    value: temp.toDouble(),
                    label: '$temp',
                    onChanged: (v) => setState(() => temp = v.round()),
                  ),
                  Text('$temp articole pe zi'),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulează'),
            ),
            TextButton(
              onPressed: () {
                setState(() => _articlesPerDay = temp);
                Navigator.pop(context);
              },
              child: const Text('OK'),
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

class CodeSearchDelegate extends SearchDelegate<void> {
  final List<_ArticleRef> articles;
  CodeSearchDelegate(this.articles);

  List<_ArticleRef> _filter(String query) {
    final q = query.toLowerCase();
    return articles.where((r) {
      if (r.article.number.toLowerCase().contains(q) ||
          r.article.title.toLowerCase().contains(q)) return true;
      return r.article.content
          .any((l) => l.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = _filter(query);
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final r = results[index];
        final path = r.path.join(' > ');
        return ListTile(
          title: Text('Art. ${r.article.number} ${r.article.title}'),
          subtitle: Text(path),
          onTap: () => _showArticle(context, r.article),
        );
      },
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
      )
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
        title: Text('Art. ${a.number} ${a.title}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: a.content
                .map((l) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(l, textAlign: TextAlign.justify),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Închide'),
          ),
        ],
      ),
    );
  }
}
