import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/asset_model.dart';
import '../../services/firestore_service.dart';

class AssetDetailPage extends StatelessWidget {
  final Asset asset;

  const AssetDetailPage({required this.asset, super.key});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text("Internal Unit Info (IUI)"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder(
          future:
              user != null ? fs.getUserProfile(user.uid) : Future.value(null),
          builder: (context, snapshot) {
            final profile = snapshot.data;
            final isAdmin = profile != null &&
                (profile.role.toLowerCase() == 'administrator' ||
                    profile.role.toLowerCase() == 'admin');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Asset Information",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                if (isAdmin)
                  _buildInfoCard(asset)
                else
                  _buildLimitedCard(asset),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLimitedCard(Asset asset) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow("Asset ID", asset.id),
          _infoRow("Asset Name", asset.name),
          _infoRow("Asset Status", asset.status),
          const SizedBox(height: 12),
          Text('Full details are restricted to administrators.',
              style: TextStyle(color: Colors.red[700])),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Asset asset) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow("Asset ID", asset.id),
          _infoRow("Asset Brand", asset.brand),
          _infoRow("Asset Name", asset.name),
          _infoRow("Register Date", asset.registerDate),
          _infoRow("Asset Status", asset.status),
          const SizedBox(height: 12),
          Row(
            children: [
              Image.asset(asset.imagePath, height: 60),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(asset.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("Register Date: ${asset.registerDate ?? 'N/A'}",
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value ?? 'N/A',
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
