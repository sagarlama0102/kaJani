import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final int itemCount;
  final int currentPage;
  final Color activeColor;

  const PageIndicator({
    super.key,
    required this.itemCount,
    required this.currentPage,
    this.activeColor = const Color(0xFF3F61D2),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          height: 7,

          width: currentPage == index ? 24 : 7,
          decoration: BoxDecoration(
            color: currentPage == index ? activeColor : Color(0xFFE1E4EA),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
