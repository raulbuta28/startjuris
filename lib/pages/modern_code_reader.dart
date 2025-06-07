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
    final baseUrl = const String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080');
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
          });
        } else {
          setState(() {
            _error = 'Invalid data format';
          });
        }
      } else if (res.statusCode == 404) {
        setState(() {
          _error = 'Code not found';
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

