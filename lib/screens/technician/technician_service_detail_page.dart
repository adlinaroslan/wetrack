import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // <-- For formatting date

class TechnicianServiceDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const TechnicianServiceDetailPage({super.key, required this.item});

  @override
  State<TechnicianServiceDetailPage> createState() =>
      _TechnicianServiceDetailPageState();
}

class _TechnicianServiceDetailPageState
    extends State<TechnicianServiceDetailPage> {

  Future<void> _markAsFixed(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Update service request
      await firestore
          .collection('service_requests')
          .doc(widget.item['serviceId'])
          .update({
        'status': 'Fixed',
        'fixedAt': FieldValue.serverTimestamp(),
      });

      // Update asset status
      String? assetDocId = (widget.item['assetDocId'] ?? '').toString();

      if (assetDocId.isEmpty) {
        final assetId = (widget.item['assetId'] ?? '').toString();
        if (assetId.isNotEmpty) {
          final q = await firestore
              .collection('assets')
              .where('id', isEqualTo: assetId)
              .limit(1)
              .get();
          if (q.docs.isNotEmpty) assetDocId = q.docs.first.id;
        }
      }

      if (assetDocId.isNotEmpty) {
        await firestore.collection('assets').doc(assetDocId).update({
          'status': 'In Stock',
          'location': 'Storage',
        });
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Service marked as Fixed successfully."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Return to service list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating service: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFixed = widget.item['status'] == 'Fixed';

    // Format fixedAt timestamp if exists
    String fixedAtFormatted = '-';
    if (widget.item['fixedAt'] != null) {
      Timestamp ts = widget.item['fixedAt'] as Timestamp;
      fixedAtFormatted = DateFormat('yyyy-MM-dd HH:mm').format(ts.toDate());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Service Detail",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
            // Asset Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Asset Information",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _infoRow("Asset ID", widget.item['assetId']),
                    _infoRow("Name", widget.item['assetName']),
                    _infoRow("Serial Number", widget.item['serialNumber']),
                    _infoRow("Brand", widget.item['brand']),
                    _infoRow("Category", widget.item['category']),
                    _infoRow("Location", widget.item['location']),
                    _infoRow("Status", widget.item['status']),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Service Request Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Service Request Information",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _infoRow("Service ID", widget.item['serviceId']),
                    _infoRow("Issue / Damage", widget.item['damage']),
                    _infoRow("Status", widget.item['status']),
                    _infoRow("Fixed At", fixedAtFormatted),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Show Mark as Fixed button only if not fixed
            if (!isFixed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _markAsFixed(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      constraints: const BoxConstraints(minHeight: 48),
                      child: const Text(
                        "Mark as Fixed",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
