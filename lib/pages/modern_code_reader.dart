import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.codeTitle,
          style: GoogleFonts.merriweather(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _code == null
                  ? const SizedBox()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: _buildBooks(
                          _code!['books'] is List ? _code!['books'] as List : []),
                      ),
                    ),
    );
  }

  List<Widget> _buildBooks(List<dynamic> books) {
    return books.map((b) {
      final titles = b is Map && b['titles'] is List ? b['titles'] as List : [];
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            '${b is Map ? b['title'] ?? '' : ''}',
            style: GoogleFonts.merriweather(fontWeight: FontWeight.w600),
          ),
          children: _buildTitles(titles),
        ),
      );
    }).toList();
  }

  List<Widget> _buildTitles(List<dynamic> titles) {
    return titles.map((t) {
      final chapters = t is Map && t['chapters'] is List ? t['chapters'] as List : [];
      return Padding(
        padding: const EdgeInsets.only(left: 8),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            '${t is Map ? t['title'] ?? '' : ''}',
            style: GoogleFonts.merriweather(fontWeight: FontWeight.w500),
          ),
          children: _buildChapters(chapters),
        ),
      );
    }).toList();
  }

  List<Widget> _buildChapters(List<dynamic> chapters) {
    return chapters.map((c) {
      final secs = c is Map && c['sections'] is List ? c['sections'] as List : [];
      return Padding(
        padding: const EdgeInsets.only(left: 16),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            '${c is Map ? c['title'] ?? '' : ''}',
            style: GoogleFonts.merriweather(fontWeight: FontWeight.w500),
          ),
          children: _buildSections(secs),
        ),
      );
    }).toList();
  }

  List<Widget> _buildSections(List<dynamic> sections) {
    return sections.map((s) {
      final arts = s is Map && s['articles'] is List ? s['articles'] as List : [];
      final subs = s is Map && s['subsections'] is List ? s['subsections'] as List : [];
      return Padding(
        padding: const EdgeInsets.only(left: 24),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            '${s is Map ? s['title'] ?? '' : ''}',
            style: GoogleFonts.merriweather(fontWeight: FontWeight.w500),
          ),
          children: [
            ..._buildArticles(arts),
            ..._buildSubsections(subs),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildSubsections(List<dynamic> subs) {
    return subs.map((s) {
      final arts = s is Map && s['articles'] is List ? s['articles'] as List : [];
      return Padding(
        padding: const EdgeInsets.only(left: 32),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            '${s is Map ? s['title'] ?? '' : ''}',
            style: GoogleFonts.merriweather(fontWeight: FontWeight.w500),
          ),
          children: _buildArticles(arts),
        ),
      );
    }).toList();
  }

  List<Widget> _buildArticles(List<dynamic> arts) {
    return arts.map((a) {
      final refs = a is Map && a['references'] is List ? a['references'] as List : [];
      return Padding(
        padding: const EdgeInsets.only(left: 40, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Art. ${a is Map ? a['number'] ?? '' : ''} ${a is Map ? a['title'] ?? '' : ''}',
              style: GoogleFonts.merriweather(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              a is Map ? (a['content'] ?? '') : '',
              style: GoogleFonts.merriweather(),
            ),
            if (refs.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey.shade50,
                ),
                child: Text(
                  refs.join('\n'),
                  style: GoogleFonts.merriweather(fontSize: 12, color: Colors.grey[700]),
                ),
              ),
          ],
        ),
      );
    }).toList();
  }
}

