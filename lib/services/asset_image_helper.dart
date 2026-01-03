import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/asset_model.dart';
import 'package:wetrack/services/firestore_service.dart';

// --- IMAGE HELPER FUNCTION ---
// Keep this outside the class so other pages can use it too!
String getAssetImagePath(String assetName) {
  if (assetName.isEmpty) return '';
  final name = assetName.toLowerCase().trim();

  final Map<String, String> imageOptions = {
    'laminator': 'assets/images/laminator.png',
    'apacer': 'assets/images/apacer.png',
    'maxell': 'assets/images/maxell.jpg',
    'acer': 'assets/images/acer.png',
    'tv mount bracket': 'assets/images/tv mount bracket.jpg',
    'sandisk': 'assets/images/sandisk.jpg',
    'cable': 'assets/images/cable.png',
    'keelat': 'assets/images/keelat.jpg',
    'cordless blower': 'assets/images/cordless blower.jpg',
    'portable voice amplifier': 'assets/images/portable voice amplifier.jpg',
    'hdmi': 'assets/images/hdmi.jpg',
    'vga': 'assets/images/VGA.jpg',
    'ugreen adapter': 'assets/images/ugreen adapter.jpg',
    'microphone stand': 'assets/images/mic stand.png',
    'raspberry pi 4': 'assets/images/RASPBERRY PI 4B.jpg',
    'hyperx': 'assets/images/hyperx.jpg',
    'dell': 'assets/images/dell.jpg',
    'extension': 'assets/images/extension.png',
    'laptop': 'assets/images/dell.jpg',
    'laptop charger': 'assets/images/laptop_charger.png',
    'usb': 'assets/images/usb.png',
    'pendrive': 'assets/images/usb.png',
    'rca': 'assets/images/rca.png',
    'projector': 'assets/images/projector.png',
    'hdmic': 'assets/images/hdmic.jpeg',
    'mouse': 'assets/images/mouse.png',
  };

  if (imageOptions.containsKey(name)) {
    return imageOptions[name]!;
  }

  for (final entry in imageOptions.entries) {
    if (name.contains(entry.key)) return entry.value;
  }

  return '';
}

class AssetBorrowedPage extends StatefulWidget {
  final Asset asset;
  const AssetBorrowedPage({super.key, required this.asset});

  @override
  State<AssetBorrowedPage> createState() => _AssetBorrowedPageState();
}

class _AssetBorrowedPageState extends State<AssetBorrowedPage> {
  String? borrowerName;

  static const Color primaryTeal = Color(0xFF00A7A7);
  static const Color deepTeal = Color(0xFF004C5C);
  static const Color accentWarning = Color(0xFFFF6B6B);

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
    final daysRemaining =
        due != null ? due.difference(DateTime.now()).inDays : 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Asset Status",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryTeal, deepTeal],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 🌟 Hero Image using the helper function
              _buildHeroImage(),

              const SizedBox(height: 30),

              // 🌟 Info Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildStatusBadge(),
                        const SizedBox(height: 20),
                        Text(
                          widget.asset.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: deepTeal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        const Divider(),
                        const SizedBox(height: 30),
                        _buildInfoRow(
                          Icons.person,
                          "Borrowed By",
                          borrowerName ?? "Loading...",
                        ),
                        const SizedBox(height: 25),
                        _buildInfoRow(
                          Icons.event_available,
                          "Due Date",
                          formattedDue,
                          subText: daysRemaining < 0
                              ? "Overdue by ${daysRemaining.abs()} days"
                              : "$daysRemaining days remaining",
                          subTextColor:
                              daysRemaining < 0 ? Colors.red : primaryTeal,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    final String imagePath = getAssetImagePath(widget.asset.name);

    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 8))
        ],
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: ClipOval(
        child: imagePath.isNotEmpty
            ? Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.devices, size: 60, color: primaryTeal),
              )
            : const Icon(Icons.devices, size: 60, color: primaryTeal),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: accentWarning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "CURRENTLY BORROWED",
        style: TextStyle(
            color: accentWarning, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {String? subText, Color? subTextColor}) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: primaryTeal.withOpacity(0.1),
          child: Icon(icon, color: primaryTeal),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
              if (subText != null)
                Text(subText,
                    style: TextStyle(
                        fontSize: 13,
                        color: subTextColor,
                        fontWeight: FontWeight.w500)),
            ],
          ),
        )
      ],
    );
  }
}
