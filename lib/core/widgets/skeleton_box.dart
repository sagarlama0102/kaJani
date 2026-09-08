import 'package:flutter/material.dart';
import 'package:kajani/app/theme/theme_extensions.dart';
import 'package:shimmer/shimmer.dart';

/// A single placeholder block used to build skeleton screens.
/// Wrap groups of these in [SkeletonShimmer] so they animate together.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // Shimmer paints its gradient over this, so the exact colour only
        // matters as an opaque base — but using the themed value keeps it
        // correct if the shimmer is ever disabled or fails to render.
        color: context.skeletonBaseColor, //  was hardcoded Colors.white
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Wraps skeleton content in a shimmer animation, themed for light/dark mode.
class SkeletonShimmer extends StatelessWidget {
  final Widget child;

  const SkeletonShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.skeletonBaseColor,           // 👈 was hardcoded hex
      highlightColor: context.skeletonHighlightColor, // 👈 was hardcoded hex
      child: child,
    );
  }
}