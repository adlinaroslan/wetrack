import 'package:flutter/material.dart';
import '../../models/asset_model.dart';
import 'package:wetrack/services/firestore_service.dart';
import 'package:wetrack/services/chat_list_page.dart';
import 'user_notification.dart';
import 'user_profile_page.dart';
import 'user_request_asset.dart';

class ListAssetPage extends StatefulWidget {
  const ListAssetPage({super.key});
  @override
  State<ListAssetPage> createState() => _ListAssetPageState();
}

class _ListAssetPageState extends State<ListAssetPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';

  final List<String> assetCategories = [
    "Monitor",
    "Desktop",
    "Machine",
    "Tools",
    "IT-Accessories",
    "Facilities",
  ];

  // FIXED: Ordered by Specificity (Longer/Specific names first)
  // Removed duplicates and ensured consistent lowercase keys for matching logic
  final Map<String, String> assetImageMap = {
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

  List<String> get _categories => ["All", ...assetCategories];

  List<Asset> _filterAssets(List<Asset> assets) {
    final query = _searchController.text.trim().toLowerCase();
    final selectedCategory = _selectedCategory.toLowerCase();

    return assets.where((asset) {
      final assetName = asset.name.toLowerCase();
      final assetId = asset.id.toLowerCase();
      final assetCategory = asset.category.toLowerCase();

      if (selectedCategory != 'all') {
        if (assetCategory != selectedCategory) return false;
      }

      if (query.isNotEmpty) {
        final searchMatched =
            assetName.contains(query) || assetId.contains(query);
        if (!searchMatched) return false;
      }

      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Assets',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
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
                        builder: (_) => const UserNotificationPage(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserProfilePage(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF00A7A7)),
                    hintText: 'Search Asset Name or ID',
                    hintStyle: const TextStyle(color: Colors.black45),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 12.0,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    padding: const EdgeInsets.only(left: 4),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final selected = cat == _selectedCategory;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        selectedColor: const Color(0xFF00A7A7),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Asset>>(
              stream: _firestoreService.getAvailableAssets(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final assets = snapshot.data ?? [];
                final filteredAssets = _filterAssets(assets);

                if (filteredAssets.isEmpty) {
                  return const Center(child: Text('No assets available'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: filteredAssets.length,
                  itemBuilder: (context, index) {
                    final asset = filteredAssets[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserRequestAssetPage(asset: asset),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _assetImage(asset),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                asset.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              asset.id,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // UPDATED: This widget now ensures BoxFit.contain is used correctly
  Widget _assetImage(Asset asset) {
    final name = asset.name.toLowerCase();
    String? imagePath;

    // 1. Iterate through map entries (Specific -> Generic).
    for (var entry in assetImageMap.entries) {
      if (name.contains(entry.key.toLowerCase())) {
        imagePath = entry.value;
        break; // STOP searching once we find a match
      }
    }

    // Fallback to asset.imageUrl if no local match
    if (imagePath == null || imagePath.isEmpty) {
      imagePath = asset.imageUrl;
    }

    // If still no image, show placeholder icon
    if (imagePath == null || imagePath.isEmpty) {
      return _buildImagePlaceholder();
    }

    bool isNetworkImage = imagePath.startsWith('http');

    // **CORE UPDATE: Container/ClipOval setup for perfect circular fit**
    return Container(
      width: 80,
      height: 80,
      // Light teal background for the circle
      decoration: const BoxDecoration(
        color: Color(0xFFEFF9F9),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(5), // Add some padding inside the circle
      child: ClipOval(
        child: isNetworkImage
            ? Image.network(
                imagePath,
                fit: BoxFit.contain, // ✅ Ensures the whole image is visible
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF00A7A7)),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => _buildErrorIcon(),
              )
            : Image.asset(
                imagePath,
                fit: BoxFit.contain, // ✅ Ensures the whole image is visible
                errorBuilder: (_, __, ___) => _buildErrorIcon(),
              ),
      ),
    );
  }

  // Fixed Placeholder: It was showing an image_not_supported icon with a white color on a white circle, making it invisible.
  // Now it uses the generic device icon with the primary teal color.
  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFEFF9F9), // Use the light teal background
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.devices_other,
        color: Color(0xFF00A7A7),
        size: 40,
      ),
    );
  }

  // Icon used for error/fallback in _assetImage
  Widget _buildErrorIcon() {
    return const Icon(
      Icons.devices_other,
      color: Color(0xFF00A7A7),
      size: 40,
    );
  }
}
