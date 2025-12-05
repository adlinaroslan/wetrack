import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wetrack/models/chat_model.dart';
import 'package:wetrack/screens/user/logout_page.dart';
import 'package:wetrack/screens/user/user_profile_page.dart';
import 'package:wetrack/screens/user/user_notification.dart';
import 'package:wetrack/services/chat_detail_page.dart';

class ChatListPage extends StatelessWidget {
  final String currentUserId;

  const ChatListPage(
      {super.key, this.currentUserId = "user_001"}); // placeholder

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF9F9),

      // 🔹 Gradient AppBar
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const UserNotificationPage()),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const UserProfilePage()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // 🔹 Chat list body
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chats').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs
              .map((doc) => Chat.fromFirestore(doc))
              .toList();

          if (chats.isEmpty) {
            return const Center(child: Text("No chats yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final lastMsg =
                  chat.messages.isNotEmpty ? chat.messages.last : null;

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF00A7A7).withAlpha(26),
                    child: const Icon(Icons.person,
                        color: Color(0xFF00A7A7), size: 30),
                  ),
                  title: Text(
                    chat.participantName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: lastMsg != null
                      ? Text(
                          lastMsg.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        )
                      : const Text("No messages yet"),
                  trailing: lastMsg != null
                      ? Text(
                          "${lastMsg.timestamp.hour}:${lastMsg.timestamp.minute.toString().padLeft(2, '0')}",
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      : null,
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
          );
        },
      ),

      // 🔹 Bottom Navigation
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50), topRight: Radius.circular(50)),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 10, offset: Offset(0, -3))
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
            BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
          ],
          onTap: (index) {
            if (index == 0) {
              Navigator.pop(context);
            } else if (index == 1) {
              Navigator.pushNamed(context, '/scanqr');
            } else if (index == 2) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LogoutPage()));
            }
          },
        ),
      ),
    );
  }
}
