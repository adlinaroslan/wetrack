import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/asset_model.dart';
import 'edit_asset_page.dart';
import 'qr_viewer_page.dart';

class AssetDetailPage extends StatelessWidget {
  final Asset asset;

  const AssetDetailPage({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text("Asset Details"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditAssetPage(asset: asset),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDispose(context),
          ),
        ],
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('assets')
            .doc(asset.docId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Asset not found."));
          }

          final updatedAsset = Asset.fromFirestore(snapshot.data!);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: _buildInfoCard(updatedAsset),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(Asset asset) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Asset Name: ${asset.name}"),
        Text("Asset ID: ${asset.id}"),
        Text("Status: ${asset.status}"),
        Text("Location: ${asset.location}"),
      ],
    );
  }

  void _confirmDispose(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Dispose Asset"),
        content: Text("Dispose '${asset.name}' permanently?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Dispose"),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('assets')
                  .doc(asset.docId)
                  .update({
                "status": "DISPOSED",
                "location": "Disposed",
                "disposedAt": FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${asset.name} disposed")),
              );
            },
          ),
        ],
      ),
    );
  }
}
