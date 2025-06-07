import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class _CodeSearchDelegate extends SearchDelegate<void> {
  final List<Map<String, dynamic>> articles;

  _CodeSearchDelegate(this.articles);

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        )
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    final results = articles
        .where((a) =>
            a['text'].toString().toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView(
      children: results
          .map(
            (a) => ListTile(
              title: Text('Art. ${a['number']} ${a['title']}'),
              subtitle: Text(a['text']),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);
}

class ModernCodeReader extends StatefulWidget {
  final String codeId;
  final String codeTitle;
  const ModernCodeReader({Key? key, required this.codeId, required this.codeTitle}) : super(key: key);

  @override
  State<ModernCodeReader> createState() => _ModernCodeReaderState();
}

class _ModernCodeReaderState extends State<ModernCodeReader>
    with SingleTickerProviderStateMixin {
  static const String _baseUrl =
      String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080');
  WebSocketChannel? _updatesWs;
  List<dynamic>? _sections;
  bool _loading = true;
  String? _error;
  late TabController _tabController;
  bool _darkMode = false;
  double _textScale = 1.0;
  final Set<String> _saved = {};
  final Set<String> _favorites = {};
  final List<Map<String, dynamic>> _flatArticles = [];
  int _articlesPerDay = 5;
  DateTime _planStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadPrefs();
    _load();
    _connectUpdates();
  }

  @override
  void dispose() {
    _updatesWs?.sink.close();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('readerDark') ?? false;
      _textScale = prefs.getDouble('readerScale') ?? 1.0;
      _articlesPerDay = prefs.getInt('planPerDay') ?? 5;
      final start = prefs.getString('planStart');
      if (start != null) {
        _planStart = DateTime.tryParse(start) ?? DateTime.now();
      }
      _saved.addAll(prefs.getStringList('savedArticles') ?? []);
      _favorites.addAll(prefs.getStringList('favArticles') ?? []);
    });
  }

  Future<void> _load() async {
    final baseUrl = _baseUrl;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res =
          await http.get(Uri.parse('$baseUrl/api/code-text-json/${widget.codeId}'));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          setState(() {
            _sections = decoded;
            _flatArticles.clear();
            _extractArticles(decoded);
          });
          return;
        }
      }

      // fallback to parsed code if anything went wrong
      final parsed =
          await http.get(Uri.parse('$baseUrl/api/parsed-code/${widget.codeId}'));
      if (parsed.statusCode == 200) {
        final decoded = jsonDecode(parsed.body);
        if (decoded is Map<String, dynamic>) {
          final sections = _fromParsedCode(decoded);
          setState(() {
            _sections = sections;
            _flatArticles.clear();
            _extractArticles(sections);
          });
          return;
        }
      } else if (parsed.statusCode == 404) {
        setState(() => _error = 'Code not found');
        return;
      }

      setState(() => _error = 'Failed to load code');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _connectUpdates() {
    final wsUrl = (_baseUrl.startsWith('https')
            ? _baseUrl.replaceFirst('https', 'wss')
            : _baseUrl.replaceFirst('http', 'ws')) +
        '/api/code-updates';
    try {
      _updatesWs = WebSocketChannel.connect(Uri.parse(wsUrl));
      _updatesWs!.stream.listen((message) {
        try {
          final data = jsonDecode(message);
          if (data is Map &&
              data['type'] == 'code_update' &&
              data['id'] == widget.codeId) {
            _load();
          }
        } catch (_) {}
      });
    } catch (_) {}
  }

  List<dynamic> _fromParsedCode(Map<String, dynamic> data) {
    Map<String, dynamic> _sectionFromUnit(
      String type,
      String name,
      Map unit,
    ) {
      final content = <dynamic>[];

      if (unit['titles'] is List) {
        content.addAll(
          (unit['titles'] as List)
              .map((t) => _sectionFromUnit('Titlul', t['title'] ?? '', t)),
        );
      }
      if (unit['chapters'] is List) {
        content.addAll(
          (unit['chapters'] as List)
              .map((c) => _sectionFromUnit('Capitolul', c['title'] ?? '', c)),
        );
      }
      if (unit['sections'] is List) {
        content.addAll(
          (unit['sections'] as List)
              .map((s) => _sectionFromUnit('Secțiunea', s['title'] ?? '', s)),
        );
      }
      if (unit['subsections'] is List) {
        content.addAll(
          (unit['subsections'] as List)
              .map((s) => _sectionFromUnit('Subsecțiunea', s['title'] ?? '', s)),
        );
      }
      if (unit['articles'] is List) {
        content.addAll((unit['articles'] as List).map((a) => {
              'number': a['number'] ?? '',
              'title': a['title'] ?? '',
              'content': (a['content'] ?? '').toString().split('\n'),
              'amendments': List<String>.from(a['notes'] ?? []),
            }));
      }

      return {
        'type': type,
        'name': name,
        'content': content,
      };
    }

    final books = data['books'] as List? ?? [];
    return books
        .map((b) => _sectionFromUnit('Cartea', b['title'] ?? '', b))
        .toList();
  }

  void _extractArticles(List<dynamic> items) {
    for (final item in items) {
      if (item is Map && item.containsKey('number')) {
        final lines = item['content'] is List
            ? List<String>.from(item['content'])
            : <String>[];
        _flatArticles.add({
          'id': 'art_${item['number']}',
          'number': item['number'],
          'title': item['title'],
          'text': lines.join(' '),
        });
      } else if (item is Map && item.containsKey('content')) {
        _extractArticles(item['content'] as List);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      brightness: _darkMode ? Brightness.dark : Brightness.light,
    );
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: _textScale),
      child: Theme(
        data: theme,
        child: DefaultTabController(
        length: 5,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              widget.codeTitle,
              style: GoogleFonts.merriweather(fontWeight: FontWeight.w600),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  if (_flatArticles.isNotEmpty) {
                    showSearch(
                      context: context,
                      delegate: _CodeSearchDelegate(_flatArticles),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _openSettings,
              ),
            ],
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(icon: Icon(Icons.article), text: 'Articole'),
                Tab(icon: Icon(Icons.bookmark), text: 'Salvate'),
                Tab(icon: Icon(Icons.highlight), text: 'Evidențiate'),
                Tab(icon: Icon(Icons.calendar_today), text: 'Plan'),
                Tab(icon: Icon(Icons.favorite), text: 'Favorite'),
              ],
            ),
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!))
                  : _sections == null
                      ? const SizedBox()
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            RefreshIndicator(
                              onRefresh: _load,
                              child: ListView(
                                padding: const EdgeInsets.all(16),
                                children: _buildSectionWidgets(_sections!, 0),
                              ),
                            ),
                            _buildSavedView(),
                            _buildHighlightedView(),
                            _buildPlanView(),
                            _buildFavoriteView(),
                          ],
                        ),
          ),
        ),
      ),
    );

  }

  List<Widget> _buildSectionWidgets(List<dynamic> items, int level) {
    return items.map((item) {
      if (item is Map &&
          (item['type'] == 'Note' || item['type'] == 'Decision')) {
        final lines = item['content'] is List ? List<String>.from(item['content']) : <String>[];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['type'] == 'Decision' ? 'Decizie' : 'Notă',
                  style: GoogleFonts.merriweather(fontWeight: FontWeight.w600),
                ),
                ...lines.map((l) => Text(l, style: GoogleFonts.merriweather())),
              ],
            ),
          ),
        );
      }
      if (item is Map && item.containsKey('number')) {
        final lines = item['content'] is List ? List<String>.from(item['content']) : <String>[];
        final amendments = item['amendments'] is List ? List<String>.from(item['amendments']) : <String>[];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Art. ${item['number'] ?? ''} ${item['title'] ?? ''}',
                      style: GoogleFonts.merriweather(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _saved.contains('art_${item['number']}')
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                    ),
                    onPressed: () => _toggleSave('art_${item['number']}'),
                  ),
                  IconButton(
                    icon: Icon(
                      _favorites.contains('art_${item['number']}')
                          ? Icons.favorite
                          : Icons.favorite_border,
                    ),
                    onPressed: () => _toggleFavorite('art_${item['number']}'),
                  ),
                ],
              ),
              ...lines.map((l) => Text(l, style: GoogleFonts.merriweather())),
              if (amendments.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: amendments
                        .map((a) => Text(a,
                            style: GoogleFonts.merriweather(fontSize: 12, color: Colors.grey[700])))
                        .toList(),
                  ),
                ),
            ],
          ),
        );
      }
      if (item is Map && item.containsKey('type')) {
        final name = item['name'] ?? '';
        final content = item['content'] is List ? item['content'] as List : [];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item['type']} $name',
                style: GoogleFonts.merriweather(fontWeight: FontWeight.w600),
              ),
              ..._buildSectionWidgets(content, level + 1),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }).toList();
  }

  void _toggleSave(String id) async {
    setState(() {
      if (_saved.contains(id)) {
        _saved.remove(id);
      } else {
        _saved.add(id);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('savedArticles', _saved.toList());
  }

  void _toggleFavorite(String id) async {
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favArticles', _favorites.toList());
  }

  Widget _buildSavedView() {
    final items = _flatArticles
        .where((a) => _saved.contains(a['id'] as String))
        .toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: items
          .map((a) => Text('Art. ${a['number']} ${a['title']}\n${a['text']}'))
          .toList(),
    );
  }

  Widget _buildFavoriteView() {
    final items = _flatArticles
        .where((a) => _favorites.contains(a['id'] as String))
        .toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: items
          .map((a) => Text('Art. ${a['number']} ${a['title']}\n${a['text']}'))
          .toList(),
    );
  }

  Widget _buildHighlightedView() {
    // Placeholder for future highlight functionality
    return const Center(child: Text('Nu exista elemente evidențiate'));
  }

  Widget _buildPlanView() {
    final dayIndex = DateTime.now().difference(_planStart).inDays;
    final start = dayIndex * _articlesPerDay;
    final items = _flatArticles.skip(start).take(_articlesPerDay).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Articole/zi:'),
              Expanded(
                child: Slider(
                  value: _articlesPerDay.toDouble(),
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: '$_articlesPerDay',
                  onChanged: (v) async {
                    setState(() => _articlesPerDay = v.round());
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setInt('planPerDay', _articlesPerDay);
                    prefs.setString('planStart', _planStart.toIso8601String());
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: items
                .map((a) => Text('Art. ${a['number']} ${a['title']}\n${a['text']}'))
                .toList(),
          ),
        ),
      ],
    );
  }

  void _openSettings() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Dark mode'),
                    Switch(
                      value: _darkMode,
                      onChanged: (v) async {
                        setModalState(() => _darkMode = v);
                        setState(() => _darkMode = v);
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setBool('readerDark', _darkMode);
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Dimensiune text'),
                    Expanded(
                      child: Slider(
                        value: _textScale,
                        min: 0.8,
                        max: 2,
                        divisions: 12,
                        label: _textScale.toStringAsFixed(1),
                        onChanged: (v) async {
                          setModalState(() => _textScale = v);
                          setState(() => _textScale = v);
                          final prefs =
                              await SharedPreferences.getInstance();
                          prefs.setDouble('readerScale', _textScale);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }
}

