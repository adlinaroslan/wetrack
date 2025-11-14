import 'package:flutter/material.dart';
import 'user_asset_request.dart';

class AssetDetailsPage extends StatelessWidget {
  final String assetName;
  final String assetId;

  const AssetDetailsPage({
    super.key,
    required this.assetName,
    required this.assetId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A7A7),
        title: const Text(
          "Asset Details",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.cable, size: 100, color: Color(0xFF00A7A7)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                children: [
                  _buildDetail("Asset Name", assetName),
                  _buildDetail("Asset ID", assetId),
                  _buildDetail("Category", "Cable"),
                  _buildDetail("Condition", "Good"),
                  _buildDetail("Location", "Technician Room"),
                  _buildDetail(
                    "Availability",
                    "Available",
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB74D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RequestAssetPage(
                        assetName: assetName,
                        assetId: assetId,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "REQUEST",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(
    String label,
    String value, {
    Color color = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
