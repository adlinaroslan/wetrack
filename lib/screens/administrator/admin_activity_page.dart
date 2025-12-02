import 'package:flutter/material.dart';
import '../../models/asset_model.dart';
import 'admin_asset_detail_page.dart';
import '../../widgets/footer_nav.dart';

class AdminActivityPage extends StatelessWidget {
  const AdminActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Assets (MUST match Asset model)
    final List<Asset> assets = [
      Asset(
        docId: "1",
        id: "A67495",
        serialNumber: "SN-001",
        name: "Dell Laptop",
        brand: "Dell",
        category: "Laptop",
        imageUrl: "assets/default.png",
        location: "HQ Office",
        status: "Active",
        registerDate: "2024-02-01",
      ),
      Asset(
        docId: "2",
        id: "AD3535",
        serialNumber: "SN-002",
        name: "My Name",
        brand: "Brand X",
        category: "Device",
        imageUrl: "assets/default.png",
        location: "HQ Office",
        status: "Active",
        registerDate: "2024-03-01",
      ),
      Asset(
        docId: "3",
        id: "AD3636",
        serialNumber: "SN-003",
        name: "My Name",
        brand: "Brand Y",
        category: "Device",
        imageUrl: "assets/default.png",
        location: "HQ Office",
        status: "Active",
        registerDate: "2024-04-01",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Asset Tracking"),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Select Asset ID / BL Number",
                hintText: "asset id / BL number",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // LISTVIEW FIXED
            Expanded(
              child: ListView.builder(
                itemCount: assets.length,
                itemBuilder: (context, index) {
                  final asset = assets[index];

                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text("Asset ID: ${asset.id}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Asset Name: ${asset.name}"),
                          Text("Serial Number: ${asset.serialNumber}"),
                          Text("User: ${asset.location}"), // you can change later
                        ],
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AssetDetailPage(asset: asset),
                            ),
                          );
                        },
                        child: const Text(
                          "View Detail",
                          style: TextStyle(
                            color: Color(0xFF00A7A7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
