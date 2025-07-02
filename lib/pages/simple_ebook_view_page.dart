import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:internet_file/internet_file.dart';

class SimpleEbookViewPage extends StatefulWidget {
  final String title;
  final String url;
  const SimpleEbookViewPage({super.key, required this.title, required this.url});

  @override
  State<SimpleEbookViewPage> createState() => _SimpleEbookViewPageState();
}

class _SimpleEbookViewPageState extends State<SimpleEbookViewPage> {
  late final EpubController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EpubController(
      document: EpubDocument.openData(InternetFile.get(widget.url)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: EpubView(
        controller: _controller,
      ),
    );
  }
}
