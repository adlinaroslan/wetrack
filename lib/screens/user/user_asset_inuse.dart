import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/asset_model.dart';
import '../../services/firestore_service.dart';
import 'package:wetrack/services/chat_list_page.dart';
import 'user_notification.dart';
import 'user_profile_page.dart';
import 'user_return_asset_details.dart';
import 'package:intl/intl.dart';

class UserAssetInUsePage extends StatefulWidget {
  const UserAssetInUsePage({super.key});

  @override
  State<UserAssetInUsePage> createState() => _UserAssetInUsePageState();
}

class _UserAssetInUsePageState extends State<UserAssetInUsePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    return dueDate.isBefore(DateTime.now());
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
      backgroundColor: const Color(0xFFEFF9F9),
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: _assetImage(asset.name),
        title: Text(
          asset.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Due: $dueStr',
              style: TextStyle(
                color: isOverdue ? Colors.red : Colors.grey,
                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isOverdue)
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  'OVERDUE',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.assignment_return, color: Color(0xFF00A7A7)),
          tooltip: 'Return Asset',
          onPressed: () {
            // 👉 Navigate to UserReturnAssetDetailsPage instead of calling confirmReturn directly
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
        ),
      ),
    );
  }

  Widget _assetImage(String assetName) {
    final path = _getImagePath(assetName);
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        color: Color(0xFFEFF9F9),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          path,
          width: 40,
          height: 40,
          errorBuilder: (_, __, ___) {
            return const Icon(
              Icons.devices_other,
              size: 24,
              color: Color(0xFF00A7A7),
            );
          },
        ),
      ),
    );
  }

  String _getImagePath(String assetName) {
    final name = assetName.toLowerCase();

    if (name.contains('hdmi')) {
      return 'assets/images/hdmi.png';
    } else if (name.contains('usb') || name.contains('pendrive')) {
      return 'assets/images/usb.png';
    } else if (name.contains('projector')) {
      return 'assets/images/projector.png';
    } else if (name.contains('laptop')) {
      return 'assets/images/laptop.png';
    } else if (name.contains('extension') || name.contains('charger')) {
      return 'assets/images/extension.png';
    }

    return 'assets/images/default.png';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
