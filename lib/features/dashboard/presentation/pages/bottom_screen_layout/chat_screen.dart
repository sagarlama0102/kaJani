import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xff0F0F0F),
      body: Center(
        child: Text(
          'Your Chats',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}