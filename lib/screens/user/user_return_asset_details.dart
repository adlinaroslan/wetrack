import 'package:flutter/material.dart';
import 'package:wetrack/services/firestore_service.dart';
import 'user_return_asset.dart';
import 'user_notification.dart';

class UserReturnAssetDetailsPage extends StatefulWidget {
  final String assetName;
  final String assetId;
  final String category;
  final String location;
  final String status;
  final String imagePath;

  const UserReturnAssetDetailsPage({
    super.key,
    required this.assetName,
    required this.assetId,
    required this.category,
    required this.location,
    required this.status,
    required this.imagePath,
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

  // Define the colors for the gradient and contrasting bars
  static const Color primaryTeal = Color(0xFF00A7A7); // Light part of gradient
  static const Color darkTeal = Color(0xFF008080); // Dark part of gradient
  // New color for Header and Footer
  static const Color headerFooterTeal = Color(0xFF004C5C);

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🌟 HEADER (AppBar) with darker color 🌟
      appBar: AppBar(
        backgroundColor: darkTeal, // Use the new dark color
        elevation: 8, // Add a slight shadow for depth
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Return Asset",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              // Navigate to notifications page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserNotificationPage()),
              );
            },
          ),
        ],
      ),

      // 🌟 MAIN BODY with Gradient 🌟
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
            // Removed SizedBox for top padding since the AppBar is no longer transparent
            children: [
              const SizedBox(height: 20), // Initial spacing below AppBar
              // 🔹 Asset Icon and Name Block
              _buildAssetHeader(),
              const SizedBox(height: 20),

              // 🔹 Asset Details Card
              _buildDetailsCard(),
              const SizedBox(height: 24),

              // 🔹 Return Condition Selection and Form
              _buildConditionForm(),
              const SizedBox(height: 40), // More space before the footer bar
            ],
          ),
        ),
      ),

      // 🌟 FOOTER (BottomNavigationBar) with darker color 🌟
      bottomNavigationBar: Container(
        color: headerFooterTeal, // Use the new dark color for the bar
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        child: _buildReturnButton(context),
      ),
    );
  }

  // Widget to display asset image and name
  Widget _buildAssetHeader() {
    return Column(
      children: [
        // 🌟 UPDATED IMAGE CONTAINER 🌟
        Container(
          width: 130, // Defined width for consistency
          height: 130, // Defined height
          padding: const EdgeInsets.all(
              15), // Padding ensures image doesn't touch edges
          decoration: BoxDecoration(
            color: Colors.white, // Solid white background
            shape: BoxShape.circle, // Circular shape
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: widget.imagePath.isNotEmpty
                ? Image.asset(
                    widget.imagePath,
                    fit: BoxFit
                        .contain, // ✅ Ensures the image suits the container
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.devices_other,
                      color: primaryTeal,
                      size: 50,
                    ),
                  )
                : const Icon(
                    Icons.devices_other,
                    color: primaryTeal,
                    size: 50,
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.assetName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.assetId,
          style: const TextStyle(
              color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Card to display static asset information
  Widget _buildDetailsCard() {
    return Card(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow("Category", widget.category),
            _infoRow("Location", widget.location),
            _infoRowWithStatus("Status", widget.status),
          ],
        ),
      ),
    );
  }

  // Widget to handle condition selection and damage actions
  Widget _buildConditionForm() {
    return Card(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Asset Return Condition:",
              style: TextStyle(
                color: headerFooterTeal,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // Segmented Button Control for Condition
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: conditions.map((condition) {
                final isSelected = condition == selectedCondition;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSelected ? primaryTeal : Colors.grey.shade100,
                        foregroundColor:
                            isSelected ? Colors.white : Colors.black87,
                        elevation: isSelected ? 4 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? headerFooterTeal
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedCondition = condition;
                        });
                      },
                      child: Text(
                        condition
                            .split(' ')
                            .first, // Show "Good", "Minor", "Major"
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // Damage Actions (REPAIR / REPLACE)
            if (selectedCondition == "Minor Damage" ||
                selectedCondition == "Major Damage") ...[
              const SizedBox(height: 20),
              const Text(
                "Damage Reported: Please choose action.",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _damageActionButton(
                    context,
                    label: "REQUEST REPAIR",
                    icon: Icons.build,
                    onPressed: () {
                      _showSnackbar(
                        context,
                        "Repair request submitted!",
                        Colors.redAccent,
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  _damageActionButton(
                    context,
                    label: "REQUEST REPLACE",
                    icon: Icons.monetization_on,
                    onPressed: () {
                      _showSnackbar(
                        context,
                        "Replacement penalty requested!",
                        Colors.redAccent,
                      );
                    },
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),
            // Comments Field
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: "Add Comments / Damage Details (optional)",
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for standard information rows in the details card
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$title:",
            style: const TextStyle(
              color: headerFooterTeal,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.black87, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Helper widget for status row with a badge
  Widget _infoRowWithStatus(String title, String value) {
    final upperValue = value.toUpperCase();

    // Determine status color: Red for BORROWED or OVERDUE, Green for others (like AVAILABLE)
    final statusColor = (upperValue == 'BORROWED' || upperValue == 'OVERDUE')
        ? Colors.redAccent
        : Colors.green;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$title:",
            style: const TextStyle(
              color: headerFooterTeal,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for the damage action buttons
  Widget _damageActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white, size: 18),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: onPressed,
      ),
    );
  }

  // Main action button at the bottom
  Widget _buildReturnButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedCondition != null && !_isProcessing
              ? primaryTeal
              : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
        ),
        onPressed: (selectedCondition != null && !_isProcessing)
            ? () => _submitReturn(context)
            : null,
        child: _isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                "CONFIRM RETURN",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _submitReturn(BuildContext context) async {
    setState(() => _isProcessing = true);

    try {
      await _firestoreService.confirmReturn(
        assetId: widget.assetId,
        condition: selectedCondition!,
        comments:
            commentController.text.isNotEmpty ? commentController.text : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asset return confirmed successfully!'),
          backgroundColor: Color.fromARGB(255, 76, 175, 80),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate back after a successful action
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const UserReturnAssetPage(),
        ),
        (route) => route.isFirst, // Go back to the root of this stack
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // Helper for displaying snackbars instead of alerts
  void _showSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
