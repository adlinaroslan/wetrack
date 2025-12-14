import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wetrack/models/chat_model.dart';
import 'package:wetrack/screens/user/logout_page.dart';
import 'package:wetrack/screens/user/user_profile_page.dart';
import 'package:wetrack/screens/user/user_notification.dart';
import 'package:wetrack/services/chat_detail_page.dart';

class ChatListPage extends StatefulWidget {
  final String? currentUserId;

  const ChatListPage({super.key, this.currentUserId});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late String _currentUserId;
  late Future<String?> _userRoleFuture;

  @override
  void initState() {
    super.initState();
    _currentUserId =
        widget.currentUserId ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    _userRoleFuture = _fetchUserRole(_currentUserId);
  }

  Future<String?> _fetchUserRole(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return doc.data()?['role'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Generate a deterministic chat ID from two user IDs
  String _getChatId(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<void> _startOrOpenChat(
      String recipientId, String recipientName) async {
    // Ensure user is authenticated
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null || _currentUserId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('You must be signed in to start a chat.')));
      return;
    }

    final chatId = _getChatId(_currentUserId, recipientId);

    try {
      // Ensure the chat document exists (merge so we don't overwrite existing)
      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'participantIds': [_currentUserId, recipientId],
        'participantNames': {
          _currentUserId: (await _fetchCurrentUserName()) ?? 'User',
          recipientId: recipientName
        },
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailPage(
            chatId: chatId,
            currentUserId: _currentUserId,
            receiverId: recipientId,
            recipientName: recipientName,
          ),
        ),
      );
    } on FirebaseException catch (fe) {
      // Handle explicit permission denied with a user-friendly message
      if (!mounted) return;
      if (fe.code == 'permission-denied') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Insufficient permissions to create or open this chat.')));
        return;
      }
      rethrow;
    }
  }

  Future<String?> _fetchCurrentUserName() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .get();
      return doc.data()?['displayName'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF9F9),
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
      body: FutureBuilder<String?>(
        future: _userRoleFuture,
        builder: (context, roleSnapshot) {
          if (roleSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userRole = roleSnapshot.data ?? 'User';

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                // 🔹 Tabs: Recent & Available Contacts
                Container(
                  color: Colors.white,
                  child: TabBar(
                    labelColor: const Color(0xFF00A7A7),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF00A7A7),
                    tabs: const [
                      Tab(text: 'Recent'),
                      Tab(text: 'Contacts'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // 🔹 Recent Chats
                      _buildRecentChats(),
                      // 🔹 Available Contacts (based on role)
                      _buildAvailableContacts(userRole),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentChats() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participantIds', arrayContains: _currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final chats = snapshot.data!.docs;

        if (chats.isEmpty) {
          return const Center(child: Text("No recent chats."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chatDoc = chats[index];
            final chatData = chatDoc.data() as Map<String, dynamic>;
            final participantIds =
                (chatData['participantIds'] as List).cast<String>();
            final recipientId =
                participantIds.firstWhere((id) => id != _currentUserId);
            final participantNames =
                chatData['participantNames'] as Map<String, dynamic>? ?? {};
            final recipientName = participantNames[recipientId] ?? 'User';
            final lastMessage = chatData['lastMessage'] ?? 'No messages yet';

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF00A7A7).withAlpha(26),
                  child: const Icon(Icons.person,
                      color: Color(0xFF00A7A7), size: 30),
                ),
                title: Text(recipientName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(lastMessage,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailPage(
                        chatId: chatDoc.id,
                        currentUserId: _currentUserId,
                        receiverId: recipientId,
                        recipientName: recipientName,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAvailableContacts(String userRole) {
    // Determine which roles this user can chat with
    List<String> targetRoles = [];
    if (userRole == 'User') {
      targetRoles = ['Administrator', 'Technician'];
    } else if (userRole == 'Administrator') {
      targetRoles = ['User', 'Technician'];
    } else if (userRole == 'Technician') {
      targetRoles = ['User', 'Administrator'];
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', whereIn: targetRoles)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;
        // exclude current user from contacts
        final contacts = users.where((d) => d.id != _currentUserId).toList();

        if (contacts.isEmpty) {
          return const Center(child: Text("No available contacts."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final userDoc = contacts[index];
            final userId = userDoc.id;
            final displayName = userDoc['displayName'] ?? 'User';
            final role = userDoc['role'] ?? 'User';

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF00A7A7).withAlpha(26),
                  child: const Icon(Icons.person,
                      color: Color(0xFF00A7A7), size: 30),
                ),
                title: Text(displayName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(role,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () async {
                  try {
                    await _startOrOpenChat(userId, displayName);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open chat: $e')),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
