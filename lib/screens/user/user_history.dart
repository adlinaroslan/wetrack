import 'package:flutter/material.dart';
import '../../chat_list_page.dart';
import '../../logout.dart';
import 'user_notification.dart';
import 'user_profile_page.dart';

class UserHistoryPage extends StatefulWidget {
  const UserHistoryPage({super.key});

  @override
  State<UserHistoryPage> createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Define your main gradient as a constant for easy reuse
  static const LinearGradient mainGradient = LinearGradient(
    colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Sample data (kept the same)
  final ongoingAssets = [
    {
      "name": "HDMI – Type C",
      "date": "25 Jan 2025 - 30 Jan 2025",
      "status": "Ongoing",
      "icon": "assets/images/hdmi.png",
    },
  ];

  final returnedAssets = [
    {
      "name": "Mouse",
      "date": "23 Jan 2025 - 25 Jan 2025",
      "status": "Returned",
      "icon": "assets/images/mouse.png",
    },
    {
      "name": "RCA Connector",
      "date": "23 Dec 2024 - 25 Dec 2024",
      "status": "Returned",
      "icon": "assets/images/rca.png",
    },
  ];

  final declinedAssets = [
    {
      "name": "Extension Cable",
      "date": "15 Jan 2025 - 20 Jan 2025",
      "status": "Declined",
      "icon": "assets/images/extension.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(gradient: mainGradient),
          child: Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          "History",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.message, color: Colors.white),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ChatListPage()),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserNotificationPage(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.person, color: Colors.white),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserProfilePage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // TabBar embedded under the header
              Container(
                margin: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: TabBar(
                  controller: _tabController,
                  // --- FIX: ADD dividerColor to remove the vertical line ---
                  dividerColor: Colors.transparent,

                  // If using Material 3, you may also need: dividerHeight: 0,
                  // --------------------------------------------------------
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  indicatorPadding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 6.0,
                  ),
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: const Color(0xFF00A7A7),
                  unselectedLabelColor: Colors.white,
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: const TextStyle(fontSize: 14),
                  tabs: const [
                    Tab(text: 'Ongoing'),
                    Tab(text: 'Returned'),
                    Tab(text: 'Declined'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAssetList(ongoingAssets),
          _buildAssetList(returnedAssets),
          _buildAssetList(declinedAssets),
        ],
      ),
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
              currentIndex: 0,
              selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
              unselectedItemColor: Colors.white,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
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
                if (index == 0) {
                  Navigator.pop(context);
                } else if (index == 1) {
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
        ],
      ),
    );
  }

  Widget _buildAssetList(List<Map<String, String>> assets) {
    if (assets.isEmpty) {
      return const Center(
        child: Text(
          "No records available",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        final status = asset["status"]!;
        Color statusColor;

        if (status == "Returned") {
          statusColor = Colors.green;
        } else if (status == "Ongoing") {
          statusColor = Colors.orangeAccent;
        } else {
          statusColor = Colors.red;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          // --- CHANGE: Increased vertical padding (top/bottom) from 14 to 20 ---
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
          decoration: BoxDecoration(
            gradient: mainGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Asset icon
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFFEFF9F9),
                backgroundImage: AssetImage(asset["icon"]!),
              ),
              // --- CHANGE: Increased horizontal space from 16 to 24 ---
              const SizedBox(width: 24),

              // Asset info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset["name"]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      asset["date"]!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
