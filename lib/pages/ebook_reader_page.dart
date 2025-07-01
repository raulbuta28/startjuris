import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:http/http.dart' as http;

class EbookReaderPage extends StatefulWidget {
  final String title;
  final String url;
  const EbookReaderPage({super.key, required this.title, required this.url});

  @override
  State<EbookReaderPage> createState() => _EbookReaderPageState();
}

class _EbookReaderPageState extends State<EbookReaderPage> {
  EpubController? _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await http.get(Uri.parse(widget.url));
      if (res.statusCode == 200) {
        _controller = EpubController(document: EpubDocument.openData(res.bodyBytes));
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _loading || _controller == null
          ? const Center(child: CircularProgressIndicator())
          : EpubView(controller: _controller!),
    );
  }
}
