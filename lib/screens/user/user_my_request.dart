import 'package:flutter/material.dart';
import 'user_notification.dart';
import 'user_profile_page.dart';
import 'package:wetrack/services/chat_list_page.dart';
import 'package:wetrack/screens/logout.dart';
import '../../services/firestore_service.dart';
import '../../models/request_model.dart';
import 'user_request_edit.dart';

class UserMyRequestsPage extends StatefulWidget {
  final String? userId;

  const UserMyRequestsPage({super.key, this.userId});

  @override
  State<UserMyRequestsPage> createState() => _UserMyRequestsPageState();
}

class _UserMyRequestsPageState extends State<UserMyRequestsPage> {
  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    final uid = widget.userId;

    final sampleRequests = [
      {
        "name": "HDMI – cable",
        "date": "23 Jan 2025 - 25 Jan 2025",
        "icon": "assets/images/hdmi.png",
      },
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
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
                  const SizedBox(width: 8),
                  const Text(
                    'My Requests',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.message, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChatListPage()),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UserNotificationPage()),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UserProfilePage()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 251, 252, 252),
              Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: uid == null
            ? ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: sampleRequests.length,
                itemBuilder: (context, index) {
                  final req = sampleRequests[index];
                  return _buildRequestTile(
                    context,
                    req["name"]!,
                    req["date"]!,
                    req["icon"]!,
                    isMounted: mounted,
                  );
                },
              )
            : StreamBuilder<List<AssetRequest>>(
                stream: fs.getRequestsForUser(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final data = snapshot.data ?? [];

                  if (data.isEmpty) {
                    return const Center(child: Text('No requests found'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final r = data[index];
                      return _buildRequestTile(
                        context,
                        r.assetName,
                        r.requiredDate.toIso8601String().split('T').first,
                        null,
                        requestObj: r,
                        isMounted: mounted,
                      );
                    },
                  );
                },
              ),
      ),
      bottomNavigationBar: Container(
        height: 70,
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
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
          child: BottomNavigationBar(
            backgroundColor: const Color.fromARGB(0, 255, 255, 255),
            elevation: 0,
            currentIndex: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.logout), label: 'Logout'),
            ],
            onTap: (index) {
              if (index == 0) Navigator.pop(context);
              if (index == 1) Navigator.pushNamed(context, '/scanqr');
              if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LogoutPage()),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TILE BUILDER (WITH FIXED ASYNC CONTEXT HANDLING)
// ---------------------------------------------------------------------------

Widget _buildRequestTile(
  BuildContext context,
  String name,
  String date,
  String? icon, {
  AssetRequest? requestObj,
  required bool isMounted,
}) {
  return GestureDetector(
    onTap: () async {
      if (requestObj != null) {
        final updated = await Navigator.push<bool?>(
          context,
          MaterialPageRoute(
            builder: (_) => EditRequestPage(request: requestObj),
          ),
        );

        // IMPORTANT: Prevent using context after async gap
        if (!isMounted) return;

        if (updated == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request updated')),
          );
        }
      }
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(0, 247, 72, 72).withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFEFF9F9),
            backgroundImage: icon != null ? AssetImage(icon) : null,
            child: icon == null
                ? const Icon(Icons.insert_drive_file,
                    size: 32, color: Color(0xFF00A7A7))
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color.fromARGB(255, 251, 249, 249),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 253, 253, 253),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 18,
          ),
        ],
      ),
    ),
  );
}
