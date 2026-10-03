import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:kajani/app/routes/app_routes.dart';
import 'package:kajani/app/theme/theme_extensions.dart';
import 'package:kajani/core/widgets/circle_icon_button.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  // Edit these to match how your app actually works
  static const List<Map<String, String>> _faqs = [
    {
      'q': 'How do I join an event?',
      'a': 'Open any event from the Explore or Home screen, review the details, '
          'and tap "Attend Event". You\'ll be added to the event right away.',
    },
    {
      'q': 'Can I leave an event after joining?',
      'a': 'Yes. Open the event you joined and tap "Leave Event". You can leave '
          'at any time before the event.',
    },
    {
      'q': 'Who creates the events?',
      'a': 'For now, events on KaJani are curated and posted by our team so you '
          'always find quality activities happening around the Kathmandu Valley.',
    },
    {
      'q': 'How do I change my username or photo?',
      'a': 'Go to your Profile, tap "Edit Profile", and update your username or '
          'profile picture from there.',
    },
    {
      'q': 'How do I save an event for later?',
      'a': 'Tap the heart icon on any event to save it. You can find all your '
          'saved events from the "Saved" count on your Profile.',
    },
    {
      'q': 'How do I delete my account?',
      'a': 'Go to your Profile, scroll to the bottom, and tap "Delete Account". '
          'This permanently removes your account and cannot be undone.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leadingWidth: 55,
        leading: Padding(
          padding: const EdgeInsets.only(left: 13),
          child: CircleIconButton(
                  icon: Iconsax.arrow_left_2,
                  onTap: () => AppRoutes.pop(context)
                ),
        ),
        title: Text('Help & Support', style: TextStyle(color: context.textPrimary)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            Text(
              'Frequently asked questions',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ..._faqs.map((faq) => _buildFaqTile(context, faq['q']!, faq['a']!)),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile(BuildContext context, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
      ),
      child: Theme(
        // removes the default ExpansionTile divider lines
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: context.primary,
          collapsedIconColor: context.textTertiary,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            question,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}