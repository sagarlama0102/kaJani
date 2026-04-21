import 'package:flutter/material.dart';
import 'package:kajani/features/onbording/presentation/pages/onbording_page.dart';

class OnbordingContent extends StatelessWidget {
  final OnboardingPageData item;

  const OnbordingContent({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(item.imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [],
        ),
      ),
    );
  }
}
