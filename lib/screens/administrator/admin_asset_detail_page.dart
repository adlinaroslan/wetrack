import 'package:flutter/material.dart';
import '../../models/asset_model.dart';
import '../../models/request_model.dart';
import 'qr_viewer_page.dart';

class AssetDetailPage extends StatelessWidget {
  final Asset asset;
  final AssetRequest? req;

  const AssetDetailPage({
    super.key,
    required this.asset,
    this.req,
  });

  @override
  Widget build(BuildContext context) {
    final bool isBorrowed = req != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Asset Tracking Details"),
        elevation: 0,
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Asset Information"),
            _infoCard([
              _infoRow("Asset ID", asset.id),
              _infoRow("Name", asset.name),
              _infoRow("Brand", asset.brand),
              _infoRow("Category", asset.category),
              _infoRow("Serial Number", asset.serialNumber),
            ]),

            const SizedBox(height: 16),

            _sectionTitle("Tracking Information"),
            _infoCard([
              _infoRow(
                "Status",
                isBorrowed ? "Borrowed" : "Available",
                valueColor: isBorrowed ? Colors.red : Colors.green,
              ),
              _infoRow("Current Location", asset.location),
              _infoRow(
                "User Name",
                isBorrowed ? req!.userName : "-",
              ),
            ]),

            const SizedBox(height: 24),

            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.qr_code),
                label: const Text("View QR Code"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A7A7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: children),
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight:
                    valueColor != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
