import 'package:flutter/material.dart';
import 'package:roya/core/theme/app_colors.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;

  const BackgroundWrapper({
    super.key, 
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: Stack(
        children: [
          // Moving the image up and decreasing its size
          Positioned(
            top: 30,     // Moves it 80 pixels up (negative value pulls it higher)
            left: 0,     // Pushes it inwards from the left by 20 pixels
            right: 60,    // Pushes it inwards from the right by 20 pixels
            bottom: 30,   // Brings the bottom edge up by 80 pixels (decreasing height)
            child: Image.asset(
              'assets/images/logo_bg.png',
              fit: BoxFit.contain, // Keeps the logo fully visible without cropping inside the new size
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              }
            ),
          ),
          Positioned.fill(
            child: child,
          ),
        ],
      ),
    );
  }
}
