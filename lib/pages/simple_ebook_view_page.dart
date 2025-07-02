import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class SimpleEbookViewPage extends StatefulWidget {
  final String title;
  final String url;
  const SimpleEbookViewPage({super.key, required this.title, required this.url});

  @override
  State<SimpleEbookViewPage> createState() => _SimpleEbookViewPageState();
}

class _SimpleEbookViewPageState extends State<SimpleEbookViewPage> {
  EpubController? _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    final bytes = await _loadEpub();
    _controller = EpubController(
      document: EpubDocument.openData(bytes),
    );
    if (mounted) setState(() => _loading = false);
  }

  Future<Uint8List> _loadEpub() async {
    final response = await http.get(Uri.parse(widget.url));
    if (response.statusCode == 200) return response.bodyBytes;
    throw Exception('Failed to load ebook');
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : EpubView(
              controller: _controller!,
            ),
    );
  }
}
