import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Assuming these imports lead to your project files:
import '../../models/asset_model.dart';
import '../../services/firestore_service.dart';
import 'package:wetrack/services/asset_image_helper.dart';
import 'package:wetrack/services/chat_list_page.dart';
import 'package:wetrack/screens/user/logout_page.dart';
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
    case "RETURNED":
    case "Returned":
      return Colors.green.shade600;
    case "Ongoing":
    case "In Use":
    case "Overdue":
    case "BORROWED":
      return Colors.orangeAccent.shade700;
    case "DECLINED":
    case "Declined":
      return Colors.red.shade600;
    default:
      return Colors.grey.shade600;
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

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

  // --- Widget Builders ---

  // ... inside _UserHistoryPageState

  Widget _buildAssetList(BuildContext context, String statusFilter) {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text("Please log in to view history."));
    }

    Stream<List<Asset>> assetStream;

    if (statusFilter == 'Ongoing') {
      // Ongoing stays the same (looking at currently borrowed assets)
      assetStream = _firestoreService.getBorrowedAssets(userId);
    } else {
      // 🌟 UPDATED: Use the new history stream for 'RETURNED' and 'DECLINED'
      assetStream = _firestoreService.getAssetHistory(userId, statusFilter);
    }

    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    return StreamBuilder<List<Asset>>(
      stream: assetStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final assets = snapshot.data ?? [];

        if (assets.isEmpty) {
          return Center(
            child: Text(
              "No $statusFilter records found.",
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
          itemCount: assets.length,
          itemBuilder: (context, index) {
            return _AssetListItem(asset: assets[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
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
                  dividerColor: Colors.transparent,
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
          _buildAssetList(context, 'Ongoing'),
          _buildAssetList(context, 'RETURNED'),
          _buildAssetList(context, 'DECLINED'),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }
}

// Extracted widget for a single asset list item - USES ASSET MODEL
class _AssetListItem extends StatelessWidget {
  final Asset asset;

  const _AssetListItem({required this.asset});

  // Helper to format the date range
  String _formatDateRange(Asset asset) {
    if (asset.status == 'Ongoing' || asset.status == 'BORROWED') {
      final start = asset.borrowDate != null
          ? DateFormat('dd MMM yyyy').format(asset.borrowDate!)
          : 'N/A';
      final due = asset.dueDateTime != null
          ? DateFormat('dd MMM yyyy').format(asset.dueDateTime!)
          : 'N/A';
      return 'Borrowed: $start - Due: $due';
    } else if (asset.status == 'RETURNED' || asset.status == 'Returned') {
      final start = asset.borrowDate != null
          ? DateFormat('dd MMM yyyy').format(asset.borrowDate!)
          : 'N/A';
      final returned = asset.returnDate != null
          ? DateFormat('dd MMM yyyy').format(asset.returnDate!)
          : 'N/A';
      return 'Used: $start - Returned: $returned';
    } else if (asset.status == 'DECLINED' || asset.status == 'Declined') {
      // For declined, show the date requested
      final requested = asset.borrowDate != null
          ? DateFormat('dd MMM yyyy').format(asset.borrowDate!)
          : 'N/A';
      return 'Requested: $requested';
    }
    return 'Date N/A';
  }

  // Helper to determine image path (Placeholder/Simple Logic)
  String _getImagePath(String assetName) {
    final path = getAssetImagePath(assetName);
    return path.isNotEmpty ? path : '';
  }

  @override
  Widget build(BuildContext context) {
    // Convert 'BORROWED' status from database to 'Ongoing' for UI display
    final displayStatus = asset.status == 'BORROWED' ? 'Ongoing' : asset.status;
    final statusColor = _getStatusColor(displayStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            radius: 30,
            backgroundColor: const Color(0xFFEFF9F9),
            child: ClipOval(
              child: Image.asset(
                _getImagePath(asset.name),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.devices_other,
                  color: Color(0xFF00A7A7),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Asset info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateRange(asset),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              displayStatus,
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

// Extracted AppBar icon builder (No change)
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

// Extracted Bottom Navigation Bar (No change)
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
        unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
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
  );
}
