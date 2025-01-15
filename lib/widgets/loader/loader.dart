import 'package:flutter/material.dart';

final Color loaderColor = Colors.red[900]!;

class LoaderOverlay extends StatefulWidget {
  const LoaderOverlay({super.key});

  @override
  State<LoaderOverlay> createState() => _LoaderOverlayState();
}

class _LoaderOverlayState extends State<LoaderOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int currentDot = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addListener(() {
        setState(() {
          currentDot = (_controller.value * 5).floor();
        });
      });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600 || size.height > 600;
    
    // Calculate responsive dimensions
    final dotWidth = isLargeScreen ? 12.0 : 8.0;
    final dotHeight = isLargeScreen ? 12.0 : 8.0;
    final expandedHeight = isLargeScreen ? 42.0 : 24.0;
    const dotSpacing = 4.0;

    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: dotSpacing),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: dotWidth,
                height: currentDot == index ? expandedHeight : dotHeight,
                decoration: BoxDecoration(
                  color: loaderColor,
                  borderRadius: BorderRadius.circular(dotWidth / 2),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}