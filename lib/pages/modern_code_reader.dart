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
      final res = await http.get(Uri.parse('$baseUrl/api/code-text-json/${widget.codeId}'));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          setState(() {
            _sections = decoded.map((e) => CodeTextSection.fromJson(e as Map<String, dynamic>)).toList();
          });
        } else {
          setState(() { _error = 'Invalid data format'; });
        }
      } else {
        setState(() { _error = 'Failed to load code'; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.codeTitle)),
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
          ...article.content.map((l) => Text(l)),
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
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(note.type, style: const TextStyle(fontStyle: FontStyle.italic)),
          ...note.content.map((l) => Text(l, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
