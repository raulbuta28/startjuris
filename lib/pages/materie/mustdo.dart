import 'package:flutter/material.dart';
import 'obiective.dart';

class MustDo extends StatelessWidget {
  const MustDo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Obiective(),
        const SizedBox(height: 16),
        _buildMustDoContent(),
      ],
    );
  }

  Widget _buildMustDoContent() {
    const largeGifWidth = 150.0; // Width for mustdo.gif
    const largeGifHeight = largeGifWidth * (500 / 300); // 250px, 300x500 aspect ratio
    const smallGifWidth = 85.0; // Width for grid GIFs, for full image visibility
    const smallGifHeight = smallGifWidth * (500 / 300); // ~141.67px, 300x500 aspect ratio
    const containerPadding = 8.0;
    const borderRadius = 4.0;
    const gridSpacing = 12.0; // Spacing for uncrowded look
    const gifBorderRadius = 8.0; // Border radius for all GIFs

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center, // Center-align vertically
        children: [
          // mustdo.gif on the left
          SizedBox(
            width: largeGifWidth,
            height: largeGifHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(gifBorderRadius),
              child: Image.asset(
                'assets/videos/mustdo.gif',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, size: 30),
                ),
              ),
            ),
          ),
          // 2x2 Grid of GIFs on the right
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(containerPadding),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSmallGif('7', smallGifWidth, smallGifHeight, gifBorderRadius),
                      _buildSmallGif('8', smallGifWidth, smallGifHeight, gifBorderRadius),
                    ],
                  ),
                  const SizedBox(height: gridSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSmallGif('9', smallGifWidth, smallGifHeight, gifBorderRadius),
                      _buildSmallGif('10', smallGifWidth, smallGifHeight, gifBorderRadius),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallGif(String index, double width, double height, double borderRadius) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'assets/videos/$index.gif',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, size: 20),
          ),
        ),
      ),
    );
  }
}