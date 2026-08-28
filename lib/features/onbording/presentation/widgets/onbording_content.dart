import 'package:flutter/material.dart';
import 'package:kajani/app/theme/app_colors.dart';
import 'package:kajani/features/onbording/presentation/pages/onbording_page.dart';

class OnbordingContent extends StatelessWidget {
  final OnboardingPageData item;

  const OnbordingContent({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, //
      child: Column(
        children: [
          // ─── Image Section ────────────────────────────────────
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

              child: Center(
                child: Image.asset(item.imagePath, fit: BoxFit.contain),
              ),
            ),
          ),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 25,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
