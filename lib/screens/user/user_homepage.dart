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

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchUnreadCount(),
    );
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
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF9F9),
      bottomNavigationBar: _buildBottomNav(context),
      body: Stack(
        children: [
          _buildTopBackground(),
          SafeArea(
            // Added padding bottom to avoid overlap with the floating nav bar
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(context),
                  const SizedBox(height: 20),
                  _buildIconRow(context),
                  const SizedBox(height: 20), // Reduced gap slightly

                  // Expanded forces the Grid to take ONLY the remaining space
                  // preventing the page from needing to scroll.
                  Expanded(
                    child: _buildGridCards(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔵 TOP BACKGROUND
  Widget _buildTopBackground() {
    return Positioned(
      top: -20,
      left: 0,
      right: 0,
      child: Container(
        height: 150,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
        ),
      ),
    );
  }

  // 🟣 APP BAR
  Widget _buildAppBar(BuildContext context) {
    return Row(
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.message, color: Colors.white),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChatListPage()),
                    );
                    setState(() => unreadCount = 0);
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
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
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const UserNotificationPage()));
              },
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const UserProfilePage()));
              },
            ),
          ],
        ),
      ],
    );
  }

  // 🔘 ICON ROW
  Widget _buildIconRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildRoundIcon(
            context, Icons.access_time, "Activity", const UserMyRequestsPage()),
        _buildRoundIcon(
            context, Icons.devices_other, "Asset", const ListAssetPage()),
        _buildRoundIcon(context, Icons.assignment_return, "Return",
            const UserReturnAssetPage()),
        _buildRoundIcon(
            context, Icons.history, "History", const UserHistoryPage()),
      ],
    );
  }

  // 🟢 ROUND ICON BUILDER
  Widget _buildRoundIcon(
      BuildContext context, IconData icon, String label, Widget page) {
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

  // 🟩 GRID CARDS (Adjusted for fixed page)
  Widget _buildGridCards(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      // Allows the grid to scroll internally IF the phone is very small,
      // but keeps the main page static.
      physics: const ClampingScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,

      childAspectRatio: 0.85,

      children: [
        _buildCard(context, "My Requests", Icons.list_alt, "2 Current Requests",
            const UserMyRequestsPage()),
        _buildCard(context, "Assets In Use", Icons.devices_other, "2 Borrowed",
            const UserAssetInUsePage()),
        _buildCard(context, "Returned Assets", Icons.assignment_turned_in,
            "2 All-Time", const UserReturnAssetPage()),
        _buildCard(context, "Pending Assets", Icons.pending_actions,
            "3 Due Soon", const UserHistoryPage()),
      ],
    );
  }

  // 🟦 CARD BUILDER (SMOOTH CURVE VERSION)
  Widget _buildCard(BuildContext context, String title, IconData icon,
      String subtitle, Widget page) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        // Shadow and Border Radius for the whole card
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 4))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // LAYER 1: Background Color (Light Blue)
              // This fills the entire card behind everything
              Container(color: const Color.fromARGB(255, 224, 255, 252)),

              // LAYER 2: The Curved Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 100, // Fixed height for the curve area
                child: ClipPath(
                  clipper: CurveClipper(), // <--- USES THE NEW CLASS
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),

              // LAYER 3: The Content (Icon & Text)
              // We use a Column with Expanded to arrange items safely
              Column(
                children: [
                  // Top Half (Over the gradient)
                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: Colors.white, size: 32),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Half (Over the light blue)
                  Expanded(
                    flex: 6,
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                          top: 10), // Push text down slightly
                      child: _styledSubtitleVertical(subtitle),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🟧 SUBTITLE (VERTICAL NUMBER)
  Widget _styledSubtitleVertical(String subtitle) {
    final numberMatch = RegExp(r'(\d+)').firstMatch(subtitle);

    if (numberMatch == null) {
      return Text(subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Color(0xFF004C5C),
              fontWeight: FontWeight.w600,
              fontSize: 13));
    }

    final number = numberMatch.group(0)!;
    final before = subtitle.substring(0, numberMatch.start).trim();
    final after = subtitle.substring(numberMatch.end).trim();
    final label = [before, after].where((x) => x.isNotEmpty).join(' ');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(number,
            style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 36,
                fontWeight: FontWeight.bold)),
        if (label.isNotEmpty)
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF004C5C),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ⚪ BOTTOM NAVIGATION BAR (FIXED)
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 80,
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
              color: Colors.black26, blurRadius: 10, offset: Offset(0, -3)),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: 0,
        selectedItemColor: const Color(0xFF00FF84),
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner), label: "Scan"),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Logout"),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/scanqr');
          } else if (index == 2) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const LogoutPage()));
          }
        },
      ),
    );
  }
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // 1. Start at top-left
    path.lineTo(0, size.height - 30);

    // 2. Draw the curve (Control Point, End Point)
    // The control point pulls the line downwards to create the curve
    var controlPoint = Offset(size.width / 2, size.height + 20);
    var endPoint = Offset(size.width, size.height - 30);

    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);

    // 3. Finish the path
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
