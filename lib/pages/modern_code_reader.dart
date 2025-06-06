import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ModernCodeReader extends StatefulWidget {
  final String codeId;
  final String codeTitle;
  const ModernCodeReader({Key? key, required this.codeId, required this.codeTitle}) : super(key: key);

  @override
  State<ModernCodeReader> createState() => _ModernCodeReaderState();
}

class _ModernCodeReaderState extends State<ModernCodeReader> {
  Map<String, dynamic>? _code;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final baseUrl = const String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080');
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res =
          await http.get(Uri.parse('$baseUrl/api/parsed-code/${widget.codeId}'));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          setState(() {
            _code = decoded;
          });
        } else {
          setState(() {
            _error = 'Invalid data format';
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load code';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.codeTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _code == null
                  ? const SizedBox()
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: _buildBooks(
                          _code!['books'] is List ? _code!['books'] as List : []),
                    ),
    );
  }

  List<Widget> _buildBooks(List<dynamic> books) {
    return books.map((b) {
      final titles = b is Map && b['titles'] is List ? b['titles'] as List : [];
      return ExpansionTile(
        title: Text('${b is Map ? b['title'] ?? '' : ''}'),
        children: _buildTitles(titles),
      );
    }).toList();
  }

  List<Widget> _buildTitles(List<dynamic> titles) {
    return titles.map((t) {
      final chapters = t is Map && t['chapters'] is List ? t['chapters'] as List : [];
      return ExpansionTile(
        title: Text('${t is Map ? t['title'] ?? '' : ''}'),
        children: _buildChapters(chapters),
      );
    }).toList();
  }

  List<Widget> _buildChapters(List<dynamic> chapters) {
    return chapters.map((c) {
      final secs = c is Map && c['sections'] is List ? c['sections'] as List : [];
      return ExpansionTile(
        title: Text('${c is Map ? c['title'] ?? '' : ''}'),
        children: _buildSections(secs),
      );
    }).toList();
  }

  List<Widget> _buildSections(List<dynamic> sections) {
    return sections.map((s) {
      final arts = s is Map && s['articles'] is List ? s['articles'] as List : [];
      final subs = s is Map && s['subsections'] is List ? s['subsections'] as List : [];
      return ExpansionTile(
        title: Text('${s is Map ? s['title'] ?? '' : ''}'),
        children: [
          ..._buildArticles(arts),
          ..._buildSubsections(subs),
        ],
      );
    }).toList();
  }

  List<Widget> _buildSubsections(List<dynamic> subs) {
    return subs.map((s) {
      final arts = s is Map && s['articles'] is List ? s['articles'] as List : [];
      return ExpansionTile(
        title: Text('${s is Map ? s['title'] ?? '' : ''}'),
        children: _buildArticles(arts),
      );
    }).toList();
  }

  List<Widget> _buildArticles(List<dynamic> arts) {
    return arts.map((a) {
      final refs = a is Map && a['references'] is List ? a['references'] as List : [];
      return ListTile(
        title: Text('Art. ${a is Map ? a['number'] ?? '' : ''} ${a is Map ? a['title'] ?? '' : ''}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a is Map ? (a['content'] ?? '') : ''),
            if (refs.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  refs.join('\n'),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
          ],
        ),
      );
    }).toList();
  }
}
