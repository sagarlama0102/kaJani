import 'package:flutter/material.dart';
import 'package:kajani/features/onbording/presentation/pages/onbording_page.dart';

class OnbordingContent extends StatelessWidget {
  final OnboardingPageData item;

  const OnbordingContent({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, //
      child: Column(
        children: [
          // ─── Image Section ────────────────────────────────────
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  item.imagePath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),

          // ─── Content Section ──────────────────────────────────
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ─── Circular Icon ──────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white, 
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: Colors.black, size: 36),
                  ),

                  const SizedBox(height: 12),

                  // ─── Title ──────────────────────────────────
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, 
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ─── Description ────────────────────────────
                  Text(
                    item.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6), 
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Bottom spacing for button overlap ───────────────
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
