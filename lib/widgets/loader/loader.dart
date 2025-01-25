import 'package:flutter/material.dart';
import 'dart:math';

final Color loaderColor = Colors.red[900]!;

class LoaderOverlay extends StatefulWidget {
  const LoaderOverlay({super.key});

  @override
  State<LoaderOverlay> createState() => _LoaderOverlayState();
}

class _LoaderOverlayState extends State<LoaderOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600 || size.height > 600;

    final dotWidth = 7.0;
    final dotHeight = 10.0;
    const dotSpacing = 4.0;

    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final wave =
                    sin((_controller.value * 2 * pi) + (index * pi / -8));
                final height = dotHeight + (wave * 20).abs();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: dotSpacing),
                  child: Container(
                    width: dotWidth,
                    height: height,
                    decoration: BoxDecoration(
                      color: loaderColor,
                      borderRadius: BorderRadius.circular(dotWidth / 2),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
