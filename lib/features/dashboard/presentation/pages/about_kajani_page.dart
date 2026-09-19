import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/theme_extensions.dart';

class AboutKajaniPage extends StatelessWidget {
  const AboutKajaniPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_2, color: context.textPrimary),
          onPressed: () => AppRoutes.pop(context),
        ),
        title: Text('About KaJani', style: TextStyle(color: context.textPrimary)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // App logo / icon
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Iconsax.people, color: context.primary, size: 44),
              ),
              const SizedBox(height: 16),

              Text(
                'KaJani',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version 1.0.0', //  match your pubspec version
                style: TextStyle(color: context.textTertiary, fontSize: 13),
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.borderColor),
                ),
                child: Text(
                  'KaJani is a social-activity events app that helps you discover '
                  'and join events happening around the Kathmandu Valley, and meet '
                  'people who share your interests.\n\n'
                  'Find something to do, join, and show up — connecting over shared '
                  'activities has never been easier.',
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Made in Nepal 🇳🇵',
                style: TextStyle(color: context.textTertiary, fontSize: 13),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}