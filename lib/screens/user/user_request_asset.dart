import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/asset_model.dart';
import 'package:wetrack/services/firestore_service.dart';
import 'package:wetrack/screens/user/user_homepage.dart';
import 'package:wetrack/screens/user/user_notification.dart';
import 'package:wetrack/screens/user/user_profile_page.dart';
import 'package:wetrack/services/chat_list_page.dart';

class UserRequestAssetPage extends StatefulWidget {
  final Asset asset; // Asset object already contains all details

  const UserRequestAssetPage({super.key, required this.asset});

  @override
  State<UserRequestAssetPage> createState() => _UserRequestAssetPageState();
}

class _UserRequestAssetPageState extends State<UserRequestAssetPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;

  final List<String> _times = [
    "8:00 AM",
    "9:00 AM",
    "10:00 AM",
    "01:00 PM",
    "2:00 PM",
    "03:00 PM"
  ];

  // ✅ 1. Define the Image Map locally to ensure specific matching works
  final Map<String, String> _assetImageMap = {
    // Specific items first
    'laptop charger': 'assets/images/laptop_charger.png',
    'tv mount bracket': 'assets/images/tv mount bracket.jpg',
    'cordless blower': 'assets/images/cordless blower.jpg',
    'portable voice amplifier': 'assets/images/portable voice amplifier.jpg',
    'ugreen adapter': 'assets/images/ugreen adapter.jpg',
    'microphone stand': 'assets/images/mic stand.png',
    'raspberry pi': 'assets/images/RASPBERRY PI 4B.jpg',

    // Brand names / Generic items second
    'laminator': 'assets/images/laminator.png',
    'apacer': 'assets/images/apacer.png',
    'maxell': 'assets/images/maxell.jpg',
    'acer': 'assets/images/acer.png',
    'sandisk': 'assets/images/sandisk.jpg',
    'keelat': 'assets/images/keelat.jpg',
    'hyperx': 'assets/images/hyperx.jpg',
    'dell': 'assets/images/dell.jpg',
    'laptop': 'assets/images/dell.jpg', // Generic laptop fallback

    // Cables and accessories
    'hdmi': 'assets/images/hdmi.jpg',
    'vga': 'assets/images/VGA.jpg',
    'rca': 'assets/images/rca.png',
    'usb': 'assets/images/usb.png',
    'pendrive': 'assets/images/usb.png',
    'extension': 'assets/images/extension.png',
    'cable': 'assets/images/cable.png',
  };

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(DateTime.now())
          ? DateTime.now().add(const Duration(days: 1))
          : _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00A7A7),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  DateTime _combineDateTime() {
    if (_selectedTime == null) {
      return _selectedDate;
    }

    final timeFormat = DateFormat('hh:mm a');
    final timeParsed = timeFormat.parse(_selectedTime!);

    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      timeParsed.hour,
      timeParsed.minute,
    );
  }

  Future<void> _submitRequest() async {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a required time slot')),
      );
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    final requiredDateTime = _combineDateTime();

    setState(() => _isLoading = true);

    try {
      await _firestoreService.requestAsset(
        assetId: widget.asset.docId,
        assetName: widget.asset.name,
        requiredDate: requiredDateTime,
        userId: user.uid,
        userName: user.displayName ?? user.email ?? 'Unknown User',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit request: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- NEW WIDGET FOR DETAIL ROWS ---
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF004C5C), size: 18),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF004C5C),
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  // -------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Request Asset',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.message, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChatListPage()),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const UserNotificationPage()),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const UserProfilePage()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Asset Image and Name Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // ✅ CHANGED: Background is now White
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00A7A7), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              // ✅ FIXED: Using the local _assetImage helper
              child: _buildAssetImage(),
            ),
            const SizedBox(height: 16),
            Text(
              widget.asset.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            // --- NEW DETAIL DISPLAY SECTION ---
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F8FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF69D9D9), width: 1),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.vpn_key, 'Asset ID', widget.asset.id),
                  _buildDetailRow(
                      Icons.qr_code, 'Serial No.', widget.asset.serialNumber),
                  _buildDetailRow(
                      Icons.business_center, 'Brand', widget.asset.brand),
                  _buildDetailRow(
                      Icons.category, 'Category', widget.asset.category),
                  _buildDetailRow(
                      Icons.location_on, 'Location', widget.asset.location),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // -------------------------------------

            // 🔹 Date Picker Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select Date",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: const Color(0xFF004C5C),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00A7A7)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEE, dd MMM yyyy').format(_selectedDate),
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const Icon(Icons.calendar_today, color: Color(0xFF00A7A7)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 🔹 Time Slots Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select Time Slot",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: const Color(0xFF004C5C),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _times.map((time) {
                final isSelected = _selectedTime == time;
                return ChoiceChip(
                  label: Text(time),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedTime = time),
                  selectedColor: const Color(0xFF00A7A7),
                  backgroundColor: const Color(0xFFEFF9F9),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF004C5C),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 25),

            // 🔹 Reason Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Reason for request (Optional)',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: const Color(0xFF004C5C),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tell us why you need this asset...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFEFF9F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF00A7A7),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 🔹 Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_isLoading || _selectedTime == null)
                    ? null
                    : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A7A7),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'SUBMIT REQUEST',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ 2. Logic to Find the Best Image
  Widget _buildAssetImage() {
    final name = widget.asset.name.toLowerCase();
    String? imagePath;

    // Check Map first (Loop and Break logic)
    for (var entry in _assetImageMap.entries) {
      if (name.contains(entry.key.toLowerCase())) {
        imagePath = entry.value;
        break; // Match found, stop searching
      }
    }

    // Fallback to asset property
    if (imagePath == null || imagePath.isEmpty) {
      imagePath = widget.asset.imageUrl;
    }

    // If still empty, show Icon
    if (imagePath.isEmpty) {
      return Icon(
        _getCategoryIcon(widget.asset.category),
        color: const Color(0xFF004C5C),
        size: 50,
      );
    }

    bool isNetworkImage = imagePath.startsWith('http');

    return ClipOval(
      child: isNetworkImage
          ? Image.network(
              imagePath,
              width: 90,
              height: 90,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                _getCategoryIcon(widget.asset.category),
                color: const Color(0xFF004C5C),
                size: 50,
              ),
            )
          : Image.asset(
              imagePath,
              width: 90,
              height: 90,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                _getCategoryIcon(widget.asset.category),
                color: const Color(0xFF004C5C),
                size: 50,
              ),
            ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'laptop':
        return Icons.laptop_mac;
      case 'monitor':
        return Icons.desktop_windows;
      case 'tool':
        return Icons.construction;
      case 'furniture':
        return Icons.chair;
      case 'desktop':
        return Icons.computer;
      default:
        return Icons.devices_other;
    }
  }
}
