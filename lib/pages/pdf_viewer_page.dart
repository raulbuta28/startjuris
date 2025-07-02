import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:internet_file/internet_file.dart';

class PdfViewerPage extends StatefulWidget {
  final String title;
  final String url;
  const PdfViewerPage({super.key, required this.title, required this.url});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  PdfControllerPinch? _controller;
  int _pages = 0;
  int _current = 1;
  bool _dark = false;
  bool _settings = false;

  @override
  void initState() {
    super.initState();
    if (widget.url.isNotEmpty) {
      _loadDocument();
    }
  }

  Future<PdfDocument> _createDocument() {
    Future<PdfDocument> documentFuture;
    if (widget.url.startsWith('http://') ||
        widget.url.startsWith('https://')) {
      documentFuture = InternetFile.get(widget.url)
          .then((data) => PdfDocument.openData(data));
    } else if (widget.url.startsWith('file://') ||
        widget.url.startsWith('/')) {
      final path = widget.url.startsWith('file://')
          ? widget.url.replaceFirst('file://', '')
          : widget.url;
      documentFuture = PdfDocument.openFile(path);
    } else {
      documentFuture = PdfDocument.openAsset(widget.url);
    }
    return documentFuture;
  }

  Future<void> _loadDocument() async {
    final document = await _createDocument();
    if (!mounted) return;
    setState(() {
      _controller = PdfControllerPinch(document: document);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _openSettings() {
    setState(() => _settings = !_settings);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Fișier indisponibil')),
      );
    }
    if (_controller == null) {
      final bg = _dark ? Colors.black : Colors.white;
      return Scaffold(
        backgroundColor: bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final bg = _dark ? Colors.black : Colors.white;
    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          PdfViewPinch(
            controller: _controller!,
            scrollDirection: Axis.horizontal,
            backgroundDecoration: BoxDecoration(color: bg),
            onDocumentLoaded: (doc) => setState(() => _pages = doc.pagesCount),
            onPageChanged: (page) => setState(() => _current = page),
          ),
          Positioned(
            left: 16,
            right: 80,
            bottom: 24,
            child: LinearProgressIndicator(
              value: _pages == 0 ? 0 : _current / _pages,
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: _openSettings,
              child: const Icon(Icons.settings),
            ),
          ),
          if (_settings)
            Positioned(
              bottom: 80,
              right: 16,
              left: 16,
              child: _SettingsPanel(
                dark: _dark,
                onToggleDark: (v) => setState(() => _dark = v),
                onClose: _openSettings,
              ),
            ),
        ],
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  final bool dark;
  final ValueChanged<bool> onToggleDark;
  final VoidCallback onClose;

  const _SettingsPanel({required this.dark, required this.onToggleDark, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('Dark mode'),
                const Spacer(),
                Switch(value: dark, onChanged: onToggleDark),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: onClose, child: const Text('Close')),
            )
          ],
        ),
      ),
    );
  }
}
