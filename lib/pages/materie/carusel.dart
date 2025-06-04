import 'package:flutter/material.dart';
import 'dart:async';

class Carusel extends StatefulWidget {
  const Carusel({Key? key}) : super(key: key);

  @override
  _CaruselState createState() => _CaruselState();
}

class _CaruselState extends State<Carusel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  final List<String> _images = [
    'assets/carusel/1.png',
    'assets/carusel/2.png',
    'assets/carusel/3.png',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const carouselHeight = 400.0;
    const aspectRatio = 1000 / 938; // Based on 1000x938 PNGs

    return SizedBox(
      height: carouselHeight,
      child: Stack(
        children: [
          // PageView for carousel images
          PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return Image.asset(
                _images[index],
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
                height: carouselHeight,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, size: 50),
                ),
              );
            },
          ),
          // Dots indicator
          Positioned(
            bottom: 16.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_images.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: _currentPage == index ? 10.0 : 6.0,
                  height: _currentPage == index ? 10.0 : 6.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}