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

  final List<String> categories = const [
    "All",
    "Monitor",
    "Desktop",
    "Machine",
    "Tools",
    "IT-Accessories",
    "Facilities",
  ];

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
            /// ================= SEARCH + ADD BUTTON =================
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search Asset Name or ID",
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFF00A7A7)),
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

                /// ADD NEW ASSET BUTTON (RIGHT BESIDE SEARCH)
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A7A7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text("Add"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddAssetPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// ================= CATEGORY FILTER (LIKE USER PAGE) =================
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected =
                      (selectedCategory == null && cat == "All") ||
                          selectedCategory == cat;

                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: const Color(0xFF00A7A7),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = cat == "All" ? null : cat;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            /// ================= FIRESTORE GRID =================
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('assets')
                    .orderBy('id')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No assets found."));
                  }

                  final assets = snapshot.data!.docs
                      .map((doc) => Asset.fromFirestore(doc))
                      .where((asset) => asset.status != 'Disposed')
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
                              builder: (_) =>
                                  AssetDetailPage(asset: asset),
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
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      asset.id,
                                      style:
                                          const TextStyle(fontSize: 11),
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
