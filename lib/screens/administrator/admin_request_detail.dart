import 'package:flutter/material.dart';

import '../../models/request_model.dart';
import '../../models/asset_model.dart';
import '../../services/firestore_service.dart';

class AdminRequestDetailPage extends StatefulWidget {
  final AssetRequest request;

  const AdminRequestDetailPage({
    Key? key,
    required this.request,
  }) : super(key: key);

  @override
  State<AdminRequestDetailPage> createState() =>
      _AdminRequestDetailPageState();
}

class _AdminRequestDetailPageState extends State<AdminRequestDetailPage> {
  final FirestoreService _fs = FirestoreService();

  Asset? asset;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAsset();
  }

  Future<void> _loadAsset() async {
    asset = await _fs.getAssetById(widget.request.assetId);
    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Detail"),
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
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ================= IMAGE =================
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _buildAssetImage(asset?.imageUrl),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= HEADER =================
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              req.id,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _statusBadge(req.status),
                        ],
                      ),

                      const Divider(height: 28),

                      _infoRow("Asset ID", req.assetId),
                      _infoRow("Asset Name", req.assetName),
                      _infoRow("User Name", req.userName),

                      const Divider(),

                      _infoRow(
                        "Requested At",
                        req.requestedDate
                            .toLocal()
                            .toString()
                            .split('.')
                            .first,
                      ),

                      _infoRow(
                        "Required Until",
                        req.requiredDate
                            .toLocal()
                            .toString()
                            .split('.')
                            .first,
                      ),

                      const SizedBox(height: 12),

                      // ================= DURATION =================
                      _durationBox(req),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ================= IMAGE =================
  Widget _buildAssetImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _defaultImage();
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        height: 160,
        width: 160,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _defaultImage(),
      );
    }

    return Image.asset(
      imageUrl,
      height: 160,
      width: 160,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _defaultImage(),
    );
  }

  Widget _defaultImage() {
    return Image.asset(
      'assets/images/default.png',
      height: 160,
      width: 160,
      fit: BoxFit.contain,
    );
  }

  // ================= STATUS =================
  Widget _statusBadge(String status) {
    Color bg;
    Color text;

    switch (status.toUpperCase()) {
      case "APPROVED":
        bg = Colors.green.shade100;
        text = Colors.green;
        break;
      case "DECLINED":
        bg = Colors.red.shade100;
        text = Colors.red;
        break;
      case "RETURNED":
        bg = Colors.blue.shade100;
        text = Colors.blue;
        break;
      default:
        bg = Colors.orange.shade100;
        text = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }

  // ================= INFO =================
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

  // ================= DURATION =================
  Widget _durationBox(AssetRequest req) {
    final days =
        req.requiredDate.difference(req.requestedDate).inDays;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Borrow Duration: $days day(s)",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }
}
