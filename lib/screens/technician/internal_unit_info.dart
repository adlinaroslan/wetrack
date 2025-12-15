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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
            onPressed: () => _confirmDispose(context, asset),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Asset Information",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildInfoCard(context, asset),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A7A7),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.qr_code),
                  label: const Text("View QR Code"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QRViewerPage(asset: asset),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================
  // INFO CARD
  // ===============================
  Widget _buildInfoCard(BuildContext context, Asset asset) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildAssetImage(asset.imageUrl),
              ),
            ),
          ),

          const SizedBox(height: 20),

          _infoRow("Asset ID", asset.id),
          _infoRow("Serial Number", asset.serialNumber),
          _infoRow("Asset Name", asset.name),
          _infoRow("Brand", asset.brand),
          _infoRow("Category", asset.category),
          _infoRow("Status", asset.status),
          _infoRow("Location", asset.location),
          _infoRow("Register Date", asset.registerDate ?? "-"),
          _infoRow("Borrowed By", asset.borrowedByUserId ?? "-"),
          _infoRow(
            "Due Date",
            asset.dueDateTime != null
                ? asset.dueDateTime!.toLocal().toString().split(' ')[0]
                : "-",
          ),
        ],
      ),
    );
  }

  // ===============================
  // IMAGE HANDLER (NO DEFAULT IMAGE)
  // ===============================
  Widget _buildAssetImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return _imagePlaceholder();
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        height: 160,
        width: 160,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }

    return Image.asset(
      imageUrl,
      height: 160,
      width: 160,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 160,
      width: 160,
      color: Colors.grey.shade100,
      child: const Icon(
        Icons.image_not_supported,
        size: 48,
        color: Colors.grey,
      ),
    );
  }

  // ===============================
  // INFO ROW
  // ===============================
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ===============================
  // DISPOSE
  // ===============================
  void _confirmDispose(BuildContext context, Asset asset) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Dispose Asset"),
        content: Text("Are you sure you want to dispose '${asset.name}'?"),
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
                  .collection("assets")
                  .doc(asset.id)
                  .update({
                "status": "DISPOSED",
                "location": "Disposed",
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${asset.name} disposed.")),
              );
            },
          ),
        ],
      ),
    );
  }
}
