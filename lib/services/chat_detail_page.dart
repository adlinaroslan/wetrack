import 'package:flutter/material.dart';

class ChatDetailPage extends StatelessWidget {
  final String chatId;
  final String currentUserId;
  final String receiverId;

  const ChatDetailPage({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.receiverId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $receiverId'),
        backgroundColor: const Color(0xFF00A7A7),
      ),
      body: Center(
        child: Text(
          'This is the conversation view for Chat ID: $chatId.',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
