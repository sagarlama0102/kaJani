import 'package:flutter/material.dart';
import 'package:kajani/app/theme/theme_extensions.dart';
import 'package:kajani/core/widgets/empty_state.dart';

class ChatComingSoonScreen extends StatelessWidget {
  const ChatComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Messages',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Spacer(),
            const SizedBox(
              width: double.infinity,
              child: EmptyState(
                imagePath: 'assets/images/chat_empty.png', //
                title: "Something's brewing",
                message: "Group chats for your events are almost here.",
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}