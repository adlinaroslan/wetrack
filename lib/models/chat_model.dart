// Minimal data model for a single message
class Message {
  final String senderId;
  final String text;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.text,
    required this.timestamp,
  });
}

// Minimal data model for a chat conversation
class Chat {
  final String chatId;
  final String participantName;
  final List<Message> messages;

  Chat({
    required this.chatId,
    required this.participantName,
    required this.messages,
  });
}
