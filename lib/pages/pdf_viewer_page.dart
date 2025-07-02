import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class PdfViewerPage extends StatefulWidget {
  final String title;
  final String url;
  const PdfViewerPage({super.key, required this.title, required this.url});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late PdfViewerController _controller;
  bool _darkMode = false;
  bool _loading = true;
  Uint8List? _data;

  @override
  void initState() {
    super.initState();
    _controller = PdfViewerController();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await http.get(Uri.parse(widget.url));
      if (res.statusCode == 200) {
        _data = res.bodyBytes;
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = _darkMode ? ThemeData.dark() : ThemeData.light();
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: Icon(_darkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: () => setState(() => _darkMode = !_darkMode),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _data != null
                ? SfPdfViewer.memory(_data!, controller: _controller)
                : const Center(child: Text('Failed to load PDF')),
        floatingActionButton: _loading
            ? null
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: 'zoom_in',
                    mini: true,
                    onPressed: () =>
                        _controller.zoomLevel = _controller.zoomLevel + 0.25,
                    child: const Icon(Icons.zoom_in),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: 'zoom_out',
                    mini: true,
                    onPressed: () {
                      final newLevel = _controller.zoomLevel - 0.25;
                      _controller.zoomLevel = newLevel.clamp(1.0, 5.0);
                    },
                    child: const Icon(Icons.zoom_out),
                  ),
                ],
              ),
      ),
    );
  }
}
