import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'internal_unit_info.dart';
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
  String searchQuery = '';
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DisposalListPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// SEARCH + FILTER
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search Asset",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) =>
                        setState(() => searchQuery = value),
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) {
                    setState(() {
                      selectedCategory = value == "All" ? null : value;
                    });
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: "All", child: Text("All")),
                    PopupMenuItem(value: "Monitor", child: Text("Monitor")),
                    PopupMenuItem(value: "Desktop", child: Text("Desktop")),
                    PopupMenuItem(value: "Machine", child: Text("Machine")),
                    PopupMenuItem(value: "Tools", child: Text("Tools")),
                    PopupMenuItem(
                        value: "IT-Accessories",
                        child: Text("IT-Accessories")),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A7A7),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add),
                label: const Text("Add New Asset"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddAssetPage()),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            /// FIRESTORE GRID
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('assets')
                    .orderBy('id')
                    .snapshots(), // fetch all assets
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No assets found."));
                  }

                  final assets = snapshot.data!.docs
                      .map((doc) => Asset.fromFirestore(doc))
                      .where((asset) =>
                          asset.status != 'DISPOSED') // filter disposed here
                      .where((asset) {
                        final matchesSearch =
                            asset.name
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase()) ||
                                asset.id
                                    .toLowerCase()
                                    .contains(searchQuery.toLowerCase());

                        final matchesCategory = selectedCategory == null ||
                            asset.category == selectedCategory;

                        return matchesSearch && matchesCategory;
                      })
                      .toList();

                  if (assets.isEmpty) {
                    return const Center(child: Text("No assets found."));
                  }

                  return GridView.builder(
                    itemCount: assets.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemBuilder: (context, index) {
                      final asset = assets[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AssetDetailPage(asset: asset),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    asset.imageUrl,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    Text(
                                      asset.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      asset.id,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ],
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
      ),
      bottomNavigationBar: const FooterNav(),
    );
  }
}
