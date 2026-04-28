import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final int itemCount;
  final int currentPage;
  final Color activeColor;

  const PageIndicator({
    super.key,
    required this.itemCount,
    required this.currentPage,
    this.activeColor = const Color(0xff142725), // Your project's dark green
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          height: 12,
          // If active, it's wider (24), else it's a circle (12)
          width: currentPage == index ? 24 : 12, 
          decoration: BoxDecoration(
            color: currentPage == index ? activeColor : Colors.grey[400],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}