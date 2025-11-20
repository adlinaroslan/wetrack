import 'package:flutter/material.dart';
import 'asset_detail_page.dart';
import '../../models/asset_model.dart';
import '../../widgets/footer_nav.dart';
import 'add_asset_page.dart';
import 'disposal_list_page.dart';

class AssetListPage extends StatefulWidget {
  const AssetListPage({super.key});

  @override
  State<AssetListPage> createState() => _AssetListPageState();
}

class _AssetListPageState extends State<AssetListPage> {
  final List<Asset> allAssets = [
    Asset(
      id: 'A67495',
      name: 'HDMI Cable',
      brand: 'Belkin',
      category: 'Cable',
      registerDate: '10 April 2021',
      status: 'Active',
      imagePath: 'assets/images/hdmi.jpg',
    ),
    Asset(
      id: 'B2603',
      name: 'USB Pendrive',
      brand: 'SanDisk',
      category: 'Storage',
      registerDate: '15 June 2021',
      status: 'Active',
      imagePath: 'assets/images/usb.jpg',
    ),
    Asset(
      id: 'C23103',
      name: 'Dell Laptop',
      brand: 'Dell',
      category: 'Laptop',
      registerDate: '12 May 2021',
      status: 'Active',
      imagePath: 'assets/images/dell.jpg',
    ),
    Asset(
      id: 'D15002',
      name: 'Projector',
      brand: 'Epson',
      category: 'Electronics',
      registerDate: '20 March 2022',
      status: 'Active',
      imagePath: 'assets/images/projector.jpg',
    ),
    Asset(
      id: 'E54123',
      name: 'HDMI - Type C',
      brand: 'Ugreen',
      category: 'Cable',
      registerDate: '02 August 2023',
      status: 'Active',
      imagePath: 'assets/images/hdmic.jpeg',
    ),
  ];

  String searchQuery = '';
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final filteredAssets = allAssets.where((asset) {
      final matchesSearch =
          asset.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              asset.id.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory =
          selectedCategory == null || asset.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text("Asset"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: "Disposed Assets",
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DisposalListPage()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search + Filter Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search Asset",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => setState(() => searchQuery = value),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list, color: Colors.black54),
                  onSelected: (value) => setState(
                      () => selectedCategory = value == "All" ? null : value),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: "All", child: Text("All Categories")),
                    const PopupMenuItem(value: "Laptop", child: Text("Laptop")),
                    const PopupMenuItem(value: "Cable", child: Text("Cable")),
                    const PopupMenuItem(
                        value: "Storage", child: Text("Storage")),
                    const PopupMenuItem(
                        value: "Electronics", child: Text("Electronics")),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ➕ Add New Asset Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A7A7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add),
                label: const Text("Add New Asset"),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AddAssetPage()));
                },
              ),
            ),
            const SizedBox(height: 16),

            // 📦 Asset Grid
            Expanded(
              child: GridView.builder(
                itemCount: filteredAssets.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final asset = filteredAssets[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AssetDetailPage(asset: asset)),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(asset.imagePath, height: 60),
                          const SizedBox(height: 8),
                          Text(asset.id,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(asset.name),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FooterNav(),
    );
  }
}
