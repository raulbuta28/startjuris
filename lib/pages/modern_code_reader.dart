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
  List<dynamic>? _sections;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final baseUrl = const String.fromEnvironment(
      'API_URL',
      defaultValue: 'http://localhost:8080',
    );

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/code-text-json/${widget.codeId}'));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          setState(() => _sections = decoded);
          return;
        }
      } else if (res.statusCode == 404) {
        // try loading parsed code as fallback
        final parsed = await http
            .get(Uri.parse('$baseUrl/api/parsed-code/${widget.codeId}'));
        if (parsed.statusCode == 200) {
          final decoded = jsonDecode(parsed.body);
          if (decoded is Map<String, dynamic>) {
            setState(() => _sections = _fromParsedCode(decoded));
            return;
          }
        } else if (parsed.statusCode == 404) {
          setState(() => _error = 'Code not found');
          return;
        }
      }

      setState(() => _error = 'Failed to load code');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
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
              : _sections == null
                  ? const SizedBox()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: _buildSectionWidgets(_sections!, 0),
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
          padding: EdgeInsets.only(left: 16.0 * level, bottom: 8),
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
          padding: EdgeInsets.only(left: 16.0 * level, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Art. ${item['number'] ?? ''} ${item['title'] ?? ''}',
                style: GoogleFonts.merriweather(fontWeight: FontWeight.w600),
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
          padding: EdgeInsets.only(left: 16.0 * level),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              '${item['type']} $name',
              style: GoogleFonts.merriweather(fontWeight: FontWeight.w600),
            ),
            children: _buildSectionWidgets(content, level + 1),
          ),
        );
      }
      return const SizedBox.shrink();
    }).toList();
  }
}

