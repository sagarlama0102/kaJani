import 'package:flutter/material.dart';

import 'package:kajani/app/theme/theme_extensions.dart';
import 'package:kajani/features/onbording/presentation/pages/onbording_page.dart';

class OnbordingContent extends StatelessWidget {
  final OnboardingPageData item;

  const OnbordingContent({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        SizedBox(
        height: 570,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 35,
            vertical: 10,
          ),
          child: Image.asset(
            item.imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),

        // Small gap between image and title
        const SizedBox(height: 14),
        Text(
          item.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 25,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),

        const SizedBox(height: 10),

        // ─────────────────────────────────────────────
        // Description
        // ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            item.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}