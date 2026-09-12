import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:kajani/app/theme/theme_extensions.dart';

/// A reusable empty-state block: illustration, headline, and supporting text.
/// Used wherever a list has no content to show.
class EmptyState extends StatelessWidget {
  final String imagePath;
  final String title;
  final String message;
  final double imageHeight;

  const EmptyState({
    super.key,
    required this.imagePath,
    required this.title,
    required this.message,
    this.imageHeight = 140,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // add this explicitly
    mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            height: imageHeight,
            fit: BoxFit.contain,
            // If the asset is missing or fails to decode, fall back to an icon
            // rather than showing a broken-image box to the user.
            errorBuilder: (_, __, ___) => Icon(
              Iconsax.image,
              size: imageHeight * 0.5,
              color: context.textTertiary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}