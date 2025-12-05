import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/asset_model.dart'; // Ensure correct path
import 'package:wetrack/services/firestore_service.dart'; // Ensure correct path
import 'package:wetrack/services/chat_list_page.dart'; // Ensure correct path
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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedCategory = 'All';
  // 🆕 Updated list to match categories used in the Admin's AddAssetPage
  // This ensures the user can filter the new assets correctly.
  List<String> get _categories => [
        'All',
        'Monitor',
        'Desktop',
        'Machine',
        'Tools',
        'IT-Accessories',
      ];

  // 🆕 Filter assets based on search query AND the asset's stored category
  List<Asset> _filterAssets(List<Asset> assets) {
    final query = _searchController.text.trim().toLowerCase();
    final selectedCategory = _selectedCategory.toLowerCase();

    return assets.where((asset) {
      final assetName = asset.name.toLowerCase();
      final assetId = asset.id.toLowerCase();
      final assetCategory =
          asset.category.toLowerCase(); // Use the actual category field

      // 1. Category filter
      if (selectedCategory != 'all') {
        // Only show asset if its category matches the selected filter
        if (assetCategory != selectedCategory) return false;
      }

      // 2. Search filter
      if (query.isNotEmpty) {
        final searchMatched =
            assetName.contains(query) || assetId.contains(query);
        if (!searchMatched) return false;
      }

      // If no filters are applied or all filters pass
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
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF00A7A7),
                    ),
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
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),

                // Category filters as chips
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
            // StreamBuilder listens for real-time changes, including new assets
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
                // The new asset will be in this list, and then filtered here.
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
                            _assetImage(asset.name),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
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

  // ℹ️ Note: This function still uses asset name to guess the image,
  // you might want to use asset.imageUrl instead if the admin uploads a custom image.
  Widget _assetImage(String assetName) {
    final name = assetName.toLowerCase();
    String assetPath = 'assets/images/default.png';

    if (name.contains('hdmi')) {
      assetPath = 'assets/images/hdmi.png';
    } else if (name.contains('usb') || name.contains('pendrive')) {
      assetPath = 'assets/images/usb.png';
    } else if (name.contains('projector')) {
      assetPath = 'assets/images/projector.png';
    } else if (name.contains('laptop')) {
      assetPath = 'assets/images/laptop.png';
    } else if (name.contains('extension') || name.contains('charger')) {
      assetPath = 'assets/images/extension.png';
    }

    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFEFF9F9),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          assetPath,
          width: 60,
          height: 60,
          errorBuilder: (_, __, ___) {
            return const Icon(
              Icons.devices_other,
              size: 40,
              color: Color(0xFF00A7A7),
            );
          },
        ),
      ),
    );
  }
}
