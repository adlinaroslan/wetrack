import 'package:flutter/material.dart';
import 'admin_asset_detail_page.dart';
import '../../widgets/footer_nav.dart';

class AdminActivityPage extends StatelessWidget {
  const AdminActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> assets = [
      {
        'assetId': 'A67495',
        'assetName': 'Dell Laptop',
        'blNumber': 'BL12345',
        'user': 'Nurul Adlina'
      },
      {
        'assetId': 'AD3535',
        'assetName': 'My Name',
        'blNumber': 'BL12346',
        'user': 'PT. Example 1'
      },
      {
        'assetId': 'AD3636',
        'assetName': 'My Name',
        'blNumber': 'BL12347',
        'user': 'PT. Example 1'
      },
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
                      title: Text("Asset ID: ${asset['assetId']}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Asset Name: ${asset['assetName']}"),
                          Text("BL Number: ${asset['blNumber']}"),
                          Text("User: ${asset['user']}"),
                        ],
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TechnicianAssetDetailPage(asset: asset),
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
