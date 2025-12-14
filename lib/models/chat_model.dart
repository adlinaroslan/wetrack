import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String text;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  // Convert Firestore doc → Message
  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestampData = data['timestamp'];
    final timestamp = timestampData is Timestamp
        ? timestampData.toDate()
        : (timestampData != null ? timestampData as DateTime : DateTime.now());
    return Message(
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      timestamp: timestamp,
    );
  }

  // Convert Message → Map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
    };
  }
}

class Chat {
  final String chatId;
  final String participantName;
  final List<Message> messages;

  Chat({
    required this.chatId,
    required this.participantName,
    required this.messages,
  });

  // Convert Firestore doc → Chat
  factory Chat.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chat(
      chatId: doc.id,
      participantName: data['participantName'] ?? '',
      messages: [], // messages are usually loaded separately
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantName': participantName,
      // messages are stored in a subcollection, not inline
    };
  }
}
