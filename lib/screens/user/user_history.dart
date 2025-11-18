import 'package:flutter/material.dart';
import 'package:wetrack/services/chat_list_page.dart';
import 'package:wetrack/screens/logout.dart';
import 'user_notification.dart';
import 'user_profile_page.dart';

// Define your main gradient as a constant for easy reuse
const LinearGradient mainGradient = LinearGradient(
  colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Helper function to determine the color based on asset status
Color _getStatusColor(String status) {
  switch (status) {
    case "Returned":
      return Colors.green;
    case "Ongoing":
      return Colors.orangeAccent;
    case "Declined":
      return Colors.red;
    default:
      return Colors.grey;
  }
}

class UserHistoryPage extends StatefulWidget {
  const UserHistoryPage({super.key});

  @override
  State<UserHistoryPage> createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  // --- Sample Data ---
  final ongoingAssets = const [
    {
      "name": "HDMI – Type C",
      "date": "25 Jan 2025 - 30 Jan 2025",
      "status": "Ongoing",
      "icon": "assets/images/hdmi.png",
    },
    // Add more ongoing items here...
  ];

  final returnedAssets = const [
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

  final declinedAssets = const [
    {
      "name": "Extension Cable",
      "date": "15 Jan 2025 - 20 Jan 2025",
      "status": "Declined",
      "icon": "assets/images/extension.png",
    },
  ];

  // --- Widget Builders ---

  Widget _buildAssetList(
      BuildContext context, List<Map<String, String>> assets) {
    if (assets.isEmpty) {
      return const Center(
        child: Text(
          "No records available",
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      );
    }

    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        return _AssetListItem(asset: assets[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
            130), // Increased height to accommodate the large TabBar
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
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
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
                      // Navigation Buttons
                      _buildAppBarIcon(context, Icons.message, ChatListPage()),
                      _buildAppBarIcon(context, Icons.notifications,
                          const UserNotificationPage()),
                      _buildAppBarIcon(
                          context, Icons.person, const UserProfilePage()),
                    ],
                  ),
                ),
              ),
              // TabBar embedded under the header
              Container(
                margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor:
                      Colors.transparent, // Fix to remove vertical line/divider
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  indicatorPadding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 4.0,
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
          _buildAssetList(context, ongoingAssets),
          _buildAssetList(context, returnedAssets),
          _buildAssetList(context, declinedAssets),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }
}

// Extracted widget for a single asset list item
class _AssetListItem extends StatelessWidget {
  final Map<String, String> asset;

  const _AssetListItem({required this.asset});

  @override
  Widget build(BuildContext context) {
    final status = asset["status"]!;
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      // Increased vertical padding for better spacing
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        gradient: mainGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(64),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Asset icon
          CircleAvatar(
            radius: 30, // Slightly reduced radius for better fit
            backgroundColor: const Color(0xFFEFF9F9),
            backgroundImage: AssetImage(asset["icon"]!),
          ),
          const SizedBox(width: 20), // Adjusted horizontal spacing

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
              color: Colors.white, // Use solid white for contrast
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
  }
}

// Extracted AppBar icon builder
Widget _buildAppBarIcon(
    BuildContext context, IconData icon, Widget destination) {
  return IconButton(
    icon: Icon(icon, color: Colors.white),
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => destination),
    ),
  );
}

// Extracted Bottom Navigation Bar
Widget _buildBottomNavBar(BuildContext context) {
  return Container(
    decoration: const BoxDecoration(
      gradient: mainGradient,
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: 0,
        selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
        unselectedItemColor: Colors.white70,
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
            Navigator.pop(context); // Assumes 'Home' is the previous screen
          } else if (index == 1) {
            // Placeholder: Assuming '/scanqr' is a defined route
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
  );
}
