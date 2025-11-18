import 'package:flutter/material.dart';
// NOTE: Replaced previous relative imports with placeholders for demonstrability
// In a full project, replace the placeholder routes with your actual pages.

import 'package:wetrack/models/chat_model.dart';
import 'package:wetrack/services/chat_detail_page.dart';

// Placeholder Pages (for Navigation consistency)
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text('Placeholder for $title')),
      );
}

class ChatListPage extends StatelessWidget {
  final String currentUserId = "user_001"; // placeholder for logged-in user

  ChatListPage({super.key});

  // Mock data as provided
  final List<Chat> mockChats = [
    Chat(
      chatId: "chat1",
      participantName: "Technician Ali",
      messages: [
        Message(
          senderId: "user_001",
          text:
              "Hi Ali, I need help with my new laptop assignment. It won't connect to the local network.",
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        Message(
          senderId: "tech_001",
          text: "Sure! What's the issue?",
          timestamp: DateTime.now(),
        ),
      ],
    ),
    Chat(
      chatId: "chat2",
      participantName: "Admin Siti",
      messages: [
        Message(
          senderId: "admin_001",
          text:
              "Your request for the projector has been approved and is ready for pickup in the main office.",
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ],
    ),
    Chat(
      chatId: "chat3",
      participantName: "Support Team",
      messages: [
        Message(
          senderId: "support_team",
          text:
              "We are tracking the return of asset ID L99821. Please confirm the drop-off time.",
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF9F9),
      // --- CUSTOM GRADIENT APP BAR START ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Messages',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Current Page (Message icon highlighted)
                  IconButton(
                    icon: const Icon(
                      Icons.message,
                      color: Color(0xFFEFF9F9),
                    ), // Lighter color when selected
                    onPressed: () {}, // Already on this page
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PlaceholderPage('Notifications'),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PlaceholderPage('Profile'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // --- CUSTOM GRADIENT APP BAR END ---
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockChats.length,
        itemBuilder: (context, index) {
          final chat = mockChats[index];
          final lastMsg = chat.messages.last;
          final isUnread = index == 0; // Example: Mark first chat as unread

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF00A7A7).withAlpha(26),
                child: Icon(
                  Icons.person,
                  color: const Color(0xFF00A7A7),
                  size: 30,
                ),
              ),
              title: Text(
                chat.participantName,
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                  color: isUnread ? const Color(0xFF004C5C) : Colors.black87,
                  fontSize: 16,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  lastMsg.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        isUnread ? const Color(0xFF00A7A7) : Colors.grey[600],
                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${lastMsg.timestamp.hour}:${lastMsg.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isUnread ? const Color(0xFF00A7A7) : Colors.grey,
                    ),
                  ),
                  if (isUnread)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00A7A7),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: const Text(
                        '2', // Example unread count
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatDetailPage(
                      chatId: chat.chatId,
                      currentUserId: currentUserId,
                      receiverId: chat.participantName,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      // --- BOTTOM NAVIGATION BAR START ---
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: 0, // Assuming Home is the initial index
              selectedItemColor: Colors.white,
              unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_scanner),
                  label: 'Scan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.logout),
                  label: 'Logout',
                ),
              ],
              onTap: (index) {
                // Placeholder navigation
                if (index == 0) {
                  Navigator.pop(context); // Go back to Home
                } else if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PlaceholderPage('QR Scan'),
                    ),
                  );
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PlaceholderPage('Logout'),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      // --- BOTTOM NAVIGATION BAR END ---
    );
  }
}
