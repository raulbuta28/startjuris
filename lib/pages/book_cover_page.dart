import 'package:flutter/material.dart';

class BookCoverPage extends StatefulWidget {
  final String image;
  final Widget nextPage;
  const BookCoverPage({super.key, required this.image, required this.nextPage});

  @override
  State<BookCoverPage> createState() => _BookCoverPageState();
}

class _BookCoverPageState extends State<BookCoverPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => widget.nextPage),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imgProvider = widget.image.startsWith('http')
        ? NetworkImage(widget.image)
        : AssetImage(widget.image) as ImageProvider;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Image(
            image: imgProvider,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
