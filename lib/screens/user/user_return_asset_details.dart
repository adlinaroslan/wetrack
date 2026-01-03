import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wetrack/services/firestore_service.dart';
import 'user_return_asset.dart';
import 'user_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserReturnAssetDetailsPage extends StatefulWidget {
  final String assetName;
  final String assetId;
  final String category;
  final String location;
  final String status;
  final String imagePath;
  final String serialNumber; // Kept Serial Number
  final DateTime? dueDateTime;

  const UserReturnAssetDetailsPage({
    super.key,
    required this.assetName,
    required this.assetId,
    required this.category,
    required this.location,
    required this.status,
    required this.imagePath,
    required this.serialNumber,
    this.dueDateTime,
  });

  @override
  State<UserReturnAssetDetailsPage> createState() =>
      _UserReturnAssetDetailsPageState();
}

class _UserReturnAssetDetailsPageState
    extends State<UserReturnAssetDetailsPage> {
  String? selectedCondition;
  final TextEditingController commentController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isProcessing = false;

  final List<String> conditions = ["Good", "Minor Damage", "Major Damage"];

  static const Color primaryTeal = Color(0xFF00A7A7);
  static const Color darkTeal = Color(0xFF008080);
  static const Color headerFooterTeal = Color(0xFF004C5C);

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkTeal,
        elevation: 8,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Return Asset",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryTeal, headerFooterTeal],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildAssetHeader(),
              const SizedBox(height: 20),
              _buildDetailsCard(),
              const SizedBox(height: 24),
              _buildConditionForm(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: headerFooterTeal,
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        child: _buildReturnButton(context),
      ),
    );
  }

  Widget _buildAssetHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              widget.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.devices, size: 50, color: primaryTeal),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.assetName,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDetailsCard() {
    final String dueStr = widget.dueDateTime != null
        ? DateFormat('dd MMM yyyy').format(widget.dueDateTime!)
        : 'Not Specified';

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _infoRow("Asset ID", widget.assetId),
            _infoRow("Serial No.", widget.serialNumber),
            _infoRow("Category", widget.category),
            _infoRow("Due Date", dueStr),
            const Divider(height: 20),
            _infoRowWithStatus("Current Status", widget.status),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionForm() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Asset Return Condition:",
                style: TextStyle(
                    color: headerFooterTeal,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: conditions.map((c) => _conditionButton(c)).toList(),
            ),

            // 🌟 DISTINCTIVE DAMAGE SECTION 🌟
            if (selectedCondition != null && selectedCondition != "Good") ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Text("Action Required",
                            style: TextStyle(
                                color: Colors.red.shade900,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _damageBtn("REPAIR", Icons.build),
                        const SizedBox(width: 8),
                        _damageBtn("REPLACE", Icons.cached),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            TextField(
              controller: commentController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Add specific damage details...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _conditionButton(String label) {
    bool isSelected = selectedCondition == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedCondition = label),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primaryTeal : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isSelected ? headerFooterTeal : Colors.grey.shade300),
          ),
          child: Text(label.split(' ').first,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _damageBtn(String label, IconData icon) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () =>
            _showSnackbar(context, "$label requested", Colors.redAccent),
        icon: Icon(icon, size: 16, color: Colors.white),
        label: Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.white)),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600, elevation: 0),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _infoRowWithStatus(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Text(value.toUpperCase(),
              style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildReturnButton(BuildContext context) {
    bool canSubmit = selectedCondition != null && !_isProcessing;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: canSubmit ? primaryTeal : Colors.grey,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: canSubmit ? () => _submitReturn(context) : null,
      child: _isProcessing
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("CONFIRM RETURN",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _submitReturn(BuildContext context) async {
    setState(() => _isProcessing = true);
    try {
      await _firestoreService.confirmReturn(
        assetId: widget.assetId,
        condition: selectedCondition!,
        comments: commentController.text,
      );
      if (selectedCondition == "Minor Damage" ||
          selectedCondition == "Major Damage") {
        final docRef = await FirebaseFirestore.instance
            .collection('service_requests')
            .add({
          'assetDocId': widget.assetId,
          'assetId': widget.assetId,
          'assetName': widget.assetName,
          'serialNumber': widget.serialNumber,
          'category': widget.category,
          'location': widget.location,
          'damage': commentController.text.isNotEmpty
              ? commentController.text
              : selectedCondition,
          'status': 'In Progress',
          'createdAt': Timestamp.now(),
          'userId': currentUser?.uid,
          'userName': currentUser?.displayName ?? 'Unknown User',
        });

        // 🔔 Notify Technicians
        await FirestoreService().sendRoleNotification(
          role: 'Technician',
          title: "Asset Returned with Damage ⚠️",
          message:
              "Asset **${widget.assetName}** was returned with condition: $selectedCondition.",
          type: 'asset_damage',
          relatedId: docRef.id,
        );
      }

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const UserReturnAssetPage()),
          (r) => r.isFirst);
    } catch (e) {
      _showSnackbar(context, e.toString(), Colors.red);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSnackbar(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}
