import 'package:flutter/material.dart';
import '../../models/asset_model.dart';

class IUI extends StatelessWidget {
  final Asset asset;

  const IUI({required this.asset, super.key});

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Asset Information",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildInfoCard(asset),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(Asset asset) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow("Asset ID", asset.id),
          _infoRow("Serial Number", asset.serialNumber), // Added Serial Number
          _infoRow("Asset Name", asset.name),
          _infoRow("Brand", asset.brand),
          _infoRow("Category", asset.category),
          _infoRow("Status", asset.status),
          _infoRow("Location", asset.location),
          _infoRow("Register Date", asset.registerDate),
          _infoRow("Borrowed By", asset.borrowedByUserId),
          _infoRow(
            "Due Date",
            asset.dueDateTime != null
                ? asset.dueDateTime!.toLocal().toString().split(' ')[0]
                : '-',
          ),
          const SizedBox(height: 12),
          if (asset.imageUrl.isNotEmpty)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  asset.imageUrl,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
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
          Text(value ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
