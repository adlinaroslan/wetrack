import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/asset_model.dart';
import '../../services/firestore_service.dart';
import 'package:wetrack/services/chat_list_page.dart';
import 'package:wetrack/screens/user/logout_page.dart';
import 'user_notification.dart';
import 'user_profile_page.dart';
import 'user_return_asset_details.dart';

class UserAssetInUsePage extends StatefulWidget {
  const UserAssetInUsePage({super.key});

  @override
  State<UserAssetInUsePage> createState() => _UserAssetInUsePageState();
}

class _UserAssetInUsePageState extends State<UserAssetInUsePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Define the constant gradient used in the Return Page
  static const LinearGradient mainGradient = LinearGradient(
    colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // lib/screens/user/user_asset_in_use_page.dart

  bool _isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;

    // 🟢 FIX: Convert both the stored dueDate and the current time to UTC
    // for a reliable comparison.
    final DateTime nowUtc = DateTime.now().toUtc();
    final DateTime dueDateUtc = dueDate.toUtc();

    // Check if the UTC Due Date is before the UTC Current Time.
    return dueDateUtc.isBefore(nowUtc);
  }

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Assets In Use')),
        body: const Center(child: Text('Please sign in to view your assets')),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(gradient: mainGradient),
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
                      'Assets In Use',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
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
                    icon: const Icon(Icons.notifications, color: Colors.white),
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
        ),
      ),
      body: StreamBuilder<List<Asset>>(
        stream: _firestoreService.getBorrowedAssets(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final assets = snapshot.data ?? [];

          if (assets.isEmpty) {
            return const Center(
              child: Text(
                'No assets currently borrowed',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];
              final isOverdue = _isOverdue(asset.dueDateTime);

              return _assetCard(
                context,
                asset: asset,
                isOverdue: isOverdue,
              );
            },
          );
        },
      ),
      // 🔹 Added Bottom Navigation Bar here
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
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
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: 0, // Highlight Home
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.qr_code_scanner), label: "Scan"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.logout), label: "Logout"),
              ],
              onTap: (index) {
                if (index == 0) {
                  Navigator.pop(context); // Go back to Home
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

  Widget _assetCard(
    BuildContext context, {
    required Asset asset,
    required bool isOverdue,
  }) {
    final dueStr = asset.dueDateTime != null
        ? DateFormat('dd MMM yyyy').format(asset.dueDateTime!)
        : 'N/A';

    String statusText = isOverdue ? "Overdue" : "In Use";
    Color statusColor =
        isOverdue ? Colors.red.shade600 : Colors.orange.shade600;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        gradient: mainGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserReturnAssetDetailsPage(
                  assetName: asset.name,
                  assetId: asset.docId,
                  category: asset.category,
                  location: asset.location,
                  status: asset.status,
                  imagePath: _getImagePath(asset.name),
                ),
              ),
            );
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFEFFBFA),
                  radius: 30,
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
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Due: $dueStr',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getImagePath(String assetName) {
    final name = assetName.toLowerCase();
    if (name.contains('hdmi')) return 'assets/images/hdmi.jpg';
    if (name.contains('usb') || name.contains('pendrive'))
      return 'assets/images/usb.png';
    if (name.contains('projector')) return 'assets/images/projector.png';
    if (name.contains('laptop')) return 'assets/images/dell.jpg';
    if (name.contains('extension') || name.contains('charger'))
      return 'assets/images/extension.png';
    return 'assets/images/default.png';
  }
}
