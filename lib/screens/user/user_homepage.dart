import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_list_asset.dart';
import 'user_my_request.dart';
import 'user_asset_inuse.dart';
import 'user_return_asset.dart';
import 'user_history.dart';
import 'package:wetrack/screens/logout.dart';
import 'user_notification.dart';
import 'package:wetrack/services/chat_list_page.dart';
import 'user_profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? currentUserId;
  int unreadCount = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _fetchUnreadCount();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchUnreadCount();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      int count = 0;
      final chatsSnap =
          await FirebaseFirestore.instance.collection('chats').get();
      for (var chatDoc in chatsSnap.docs) {
        final lastMsgSnap = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatDoc.id)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
        if (lastMsgSnap.docs.isNotEmpty) {
          final lastMsg = lastMsgSnap.docs.first.data();
          // Only count as unread if the last message wasn't sent by current user
          if (currentUserId != null && lastMsg['senderId'] != currentUserId) {
            count += 1;
          }
        }
      }
      if (mounted) {
        setState(() {
          unreadCount = count;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF9F9),
      body: Stack(
        children: [
          // 🔵
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Container(
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0xFF00A7A7),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50.0),
                  bottomRight: Radius.circular(50.0),
                ),
              ),
            ),
          ),

          // 🔹 Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AppBar Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "WeTrack.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          // Message icon with unread badge
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.message,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatListPage(),
                                    ),
                                  );
                                  setState(() {
                                    unreadCount = 0;
                                  });
                                },
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        unreadCount > 99
                                            ? '99+'
                                            : unreadCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.notifications,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const UserNotificationPage(),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.person, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const UserProfilePage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 🔹 Rounded Icons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRoundIcon(
                        context,
                        Icons.access_time,
                        "Activity",
                        const UserMyRequestsPage(),
                      ),
                      _buildRoundIcon(
                        context,
                        Icons.devices_other,
                        "Asset",
                        const ListAssetPage(),
                      ),
                      _buildRoundIcon(
                        context,
                        Icons.assignment_return,
                        "Return",
                        const UserReturnAssetPage(),
                      ),
                      _buildRoundIcon(
                        context,
                        Icons.history,
                        "History",
                        const UserHistoryPage(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // 🔹 Curved Gradient 2x2 Boxes
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildCard(
                        context,
                        "My Requests",
                        Icons.list_alt,
                        "2 Current Requests",
                        const UserMyRequestsPage(),
                      ),
                      _buildCard(
                        context,
                        "Assets In Use",
                        Icons.devices_other,
                        "2 Borrowed",
                        const UserAssetInUsePage(),
                      ),
                      _buildCard(
                        context,
                        "Returned Assets",
                        Icons.assignment_turned_in,
                        "2 All-Time",
                        const UserReturnAssetPage(),
                      ),
                      _buildCard(
                        context,
                        "Pending Assets",
                        Icons.pending_actions,
                        "3 Due Soon",
                        const UserHistoryPage(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // ⚪ Curved bottom background with navigation bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 90,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                backgroundColor: const Color.fromARGB(0, 237, 233, 233),
                elevation: 0,
                currentIndex: 0,
                selectedItemColor: const Color.fromARGB(255, 0, 255, 132),
                unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.qr_code_scanner),
                    label: "Scan",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.logout),
                    label: "Logout",
                  ),
                ],
                onTap: (index) {
                  if (index == 1) {
                    Navigator.pushNamed(context, '/scanqr');
                  } else if (index == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LogoutPage()),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🟢 Rounded Icon Button Builder
  Widget _buildRoundIcon(
    BuildContext context,
    IconData icon,
    String label,
    Widget page,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  // 🟩 Curved Gradient Card Builder
  Widget _buildCard(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(0, 0, 0, 0),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // top curved gradient part
              Container(
                height: 110,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00A7A7), Color(0xFF69D9D9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.elliptical(200, 100),
                    topRight: Radius.elliptical(200, 100),
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 38),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // bottom white part
              Expanded(
                child: Container(
                  color: const Color.fromARGB(255, 224, 255, 252),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: _styledSubtitleVertical(subtitle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to style the number in the subtitle vertically (number centered, words below)
  Widget _styledSubtitleVertical(String subtitle) {
    final numberMatch = RegExp(r'(\d+)').firstMatch(subtitle);
    if (numberMatch == null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          subtitle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF004C5C),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      );
    }
    final number = numberMatch.group(0)!;
    final before = subtitle.substring(0, numberMatch.start).trim();
    final after = subtitle.substring(numberMatch.end).trim();
    // Combine before and after as the label below the number
    final label = [before, after].where((s) => s.isNotEmpty).join(' ');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            number,
            style: const TextStyle(
              color: Color(0xFFFFD700), // Gold
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          if (label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF004C5C),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
