import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../services/asset_image_helper.dart';
import '../../models/asset_model.dart';
import 'package:wetrack/services/firestore_service.dart';

class AssetBorrowedPage extends StatefulWidget {
  final Asset asset;
  const AssetBorrowedPage({super.key, required this.asset});

  @override
  State<AssetBorrowedPage> createState() => _AssetBorrowedPageState();
}

class _AssetBorrowedPageState extends State<AssetBorrowedPage>
    with SingleTickerProviderStateMixin {
  String? borrowerName;

  // Modernized Teal Palette
  static const Color primaryTeal = Color(0xFF00A7A7);
  static const Color deepTeal = Color(0xFF004C5C);
  static const Color accentWarning =
      Color(0xFFFF6B6B); // Soft Red for 'Borrowed'
  static const Color surfaceWhite = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadBorrowerName();
  }

  Future<void> _loadBorrowerName() async {
    final uid = widget.asset.borrowedByUserId;
    if (uid != null && uid.isNotEmpty) {
      final name = await FirestoreService().getBorrowerName(uid);
      if (!mounted) return;
      setState(() => borrowerName = name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final due = widget.asset.dueDateTime;
    final formattedDue =
        due != null ? DateFormat("MMMM dd, yyyy").format(due) : "Unknown date";

    // Calculate days remaining (if due date exists)
    final daysRemaining =
        due != null ? due.difference(DateTime.now()).inDays : 0;

    return Scaffold(
      extendBodyBehindAppBar: true, // Makes the gradient go behind the app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Asset Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryTeal, deepTeal],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 600),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double val, child) {
                return Opacity(
                  opacity: val,
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - val)),
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 🌟 Hero Image Section
                  _buildHeroImage(),

                  const SizedBox(height: 30),

                  // 🌟 Main Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: surfaceWhite,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: accentWarning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.lock_clock,
                                  color: accentWarning, size: 18),
                              SizedBox(width: 8),
                              Text(
                                "CURRENTLY UNAVAILABLE",
                                style: TextStyle(
                                  color: accentWarning,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Asset Name
                        Text(
                          widget.asset.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: deepTeal,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "This item is currently out on loan.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: 30),
                        const Divider(height: 1),
                        const SizedBox(height: 30),

                        // Info Rows
                        _buildInfoRow(
                          icon: Icons.person_outline,
                          label: "Borrowed By",
                          value: borrowerName ?? "Loading...",
                          isBold: true,
                        ),
                        const SizedBox(height: 20),
                        _buildInfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: "Expected Return",
                          value: formattedDue,
                          subValue: daysRemaining < 0
                              ? "Overdue by ${daysRemaining.abs()} days"
                              : "$daysRemaining days remaining",
                          subValueColor:
                              daysRemaining < 0 ? Colors.red : primaryTeal,
                        ),
                      ],
                    ),
                  ),

                  // Optional: Action Button
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () {
                      // Add notification logic here if needed
                    },
                    icon: const Icon(Icons.notifications_none,
                        color: Colors.white70),
                    label: const Text(
                      "Notify me when available",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    // Use your helper function to see if we have a local image for this asset name
    final localPath = getAssetImagePath(widget.asset.name);

    // Decide which Image provider to use
    final ImageProvider imageProvider;
    if (localPath.isNotEmpty) {
      imageProvider = AssetImage(localPath);
    } else if (widget.asset.imageUrl.isNotEmpty &&
        widget.asset.imageUrl.startsWith('http')) {
      imageProvider = NetworkImage(widget.asset.imageUrl);
    } else {
      // Fallback if no image is found
      imageProvider = const AssetImage('assets/images/placeholder.png');
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 70,
        backgroundColor: Colors.white,
        // We use backgroundImage here for better circular fitting
        backgroundImage: imageProvider,
        // Error handling for CircleAvatar
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint("Error loading image: $exception");
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    String? subValue,
    Color? subValueColor,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: deepTeal, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(), // Applied uppercase to string
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (subValue != null) ...[
                const SizedBox(height: 4),
                Text(
                  subValue,
                  style: TextStyle(
                    fontSize: 12,
                    color: subValueColor ?? Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}
