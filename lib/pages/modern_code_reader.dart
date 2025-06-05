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
        setState(() {
          _code = jsonDecode(res.body);
        });
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
                  ? const Center(child: Text('No data'))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children:
                          _buildBooks(_code?['books'] as List<dynamic>? ?? []),
                    ),
    );
  }

  List<Widget> _buildBooks(List<dynamic>? books) {
    if (books == null) return [];
    return books.map((b) {
      return ExpansionTile(
        title: Text(b['title']),
        children: _buildTitles(b['titles'] as List<dynamic>? ?? []),
      );
    }).toList();
  }

  List<Widget> _buildTitles(List<dynamic>? titles) {
    if (titles == null) return [];
    return titles.map((t) {
      return ExpansionTile(
        title: Text(t['title']),
        children: _buildChapters(t['chapters'] as List<dynamic>? ?? []),
      );
    }).toList();
  }

  List<Widget> _buildChapters(List<dynamic>? chapters) {
    if (chapters == null) return [];
    return chapters.map((c) {
      return ExpansionTile(
        title: Text(c['title']),
        children: _buildSections(c['sections'] as List<dynamic>? ?? []),
      );
    }).toList();
  }

  List<Widget> _buildSections(List<dynamic>? sections) {
    if (sections == null) return [];
    return sections.map((s) {
      return ExpansionTile(
        title: Text(s['title']),
        children: [
          ..._buildArticles(s['articles'] as List<dynamic>? ?? []),
          ..._buildSubsections(s['subsections'] as List<dynamic>? ?? []),
        ],
      );
    }).toList();
  }

  List<Widget> _buildSubsections(List<dynamic>? subs) {
    if (subs == null) return [];
    return subs.map((s) {
      return ExpansionTile(
        title: Text(s['title']),
        children: _buildArticles(s['articles'] as List<dynamic>? ?? []),
      );
    }).toList();
  }

  List<Widget> _buildArticles(List<dynamic>? arts) {
    if (arts == null) return [];
    return arts.map((a) {
      return ListTile(
        title: Text('Art. ${a['number']} ${a['title']}'),
        subtitle: Text(a['content'] ?? ''),
      );
    }).toList();
  }
}
