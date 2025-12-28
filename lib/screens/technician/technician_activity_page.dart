import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/asset_model.dart';
import '../../models/request_model.dart';
import 'technician_asset_detail_page.dart';
import '../../widgets/footer_nav.dart';

class TechnicianActivityPage extends StatefulWidget {
  const TechnicianActivityPage({super.key});

  @override
  State<TechnicianActivityPage> createState() => _TechnicianActivityPageState();
}

class _TechnicianActivityPageState extends State<TechnicianActivityPage> {
  String searchKeyword = '';

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔍 SEARCH BAR
            TextField(
              decoration: InputDecoration(
                labelText: "Search Asset ID / Serial / Name",
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchKeyword = value.toLowerCase();
                });
              },
            ),

            const SizedBox(height: 16),

            /// 🔥 ASSET LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('assets')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No assets found"));
                  }

                  final assets = snapshot.data!.docs
                      .map((doc) => Asset.fromFirestore(doc))
                      .where((asset) =>
                          asset.id.toLowerCase().contains(searchKeyword) ||
                          asset.name.toLowerCase().contains(searchKeyword) ||
                          asset.serialNumber
                              .toLowerCase()
                              .contains(searchKeyword))
                      .toList();

                  return ListView.builder(
                    itemCount: assets.length,
                    itemBuilder: (context, index) {
                      final asset = assets[index];

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text("Asset ID: ${asset.id}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Name: ${asset.name}"),
                              Text("Serial: ${asset.serialNumber}"),
                              Text("Status: ${asset.status}"),
                            ],
                          ),
                          trailing: TextButton(
                            child: const Text(
                              "View Detail",
                              style: TextStyle(
                                color: Color(0xFF00A7A7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () async {
                              AssetRequest? activeRequest;

                              /// 🔥 GET CURRENT ACTIVE (APPROVED) REQUEST
                              final reqSnapshot = await FirebaseFirestore
                                  .instance
                                  .collection('requests')
                                  .where('assetId', isEqualTo: asset.id)
                                  .where('status', isEqualTo: 'APPROVED')
                                  .limit(1)
                                  .get();

                              if (reqSnapshot.docs.isNotEmpty) {
                                activeRequest = AssetRequest.fromFirestore(
                                  reqSnapshot.docs.first,
                                );
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AssetDetailPage(
                                    asset: asset,
                                    req: activeRequest,
                                  ),
                                ),
                              );
                            },
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
