import 'package:flutter/material.dart';

class TechnicianAssetDetailPage extends StatelessWidget {
  final Map<String, String> asset;
  const TechnicianAssetDetailPage({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Asset Info"),
        backgroundColor: const Color(0xFF00A7A7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Asset Tracking",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Asset Info Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Asset Info",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    infoRow("Asset ID", asset['assetId']),
                    infoRow("Asset Name", asset['assetName']),
                    infoRow("Asset Type", "Electronics"),
                    infoRow("User", asset['user']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tracking Info
            const Text(
              "Tracking Info",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            infoRow("Asset ID", asset['assetId']),
            infoRow("Asset Status", "Active", valueColor: Colors.green),
            infoRow("Date Issued", "10 April 2025"),
            infoRow("Return Date", "15 April 2025"),
            infoRow("Condition", "Damaged", valueColor: Colors.red),
            infoRow("Location", "Lab 4.0 B"),
            const SizedBox(height: 16),

            // Manifest Info
            const Text(
              "Manifest Info",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Item Descriptions"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRow(String label, String? value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label :",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? '-',
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
