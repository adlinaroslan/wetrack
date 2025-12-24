import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/asset_model.dart';
import 'technician_service_detail_page.dart';
import '../../widgets/footer_nav.dart';

class TechnicianServicePage extends StatefulWidget {
  const TechnicianServicePage({super.key});

  @override
  State<TechnicianServicePage> createState() => _TechnicianServicePageState();
}

class _TechnicianServicePageState extends State<TechnicianServicePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color primaryTeal = Color(0xFF00A7A7);
  static const Color darkTeal = Color(0xFF004C5C);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _autoCreateServiceRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // =====================================================
  // 🔥 AUTO CREATE SERVICE REQUEST FOR ADMIN ACTION
  // =====================================================
  Future<void> _autoCreateServiceRequests() async {
    final firestore = FirebaseFirestore.instance;

    final assetsNeedingService = await firestore
        .collection('assets')
        .where('status', isEqualTo: 'Service Needed')
        .get();

    for (final assetDoc in assetsNeedingService.docs) {
      final existingRequest = await firestore
          .collection('service_requests')
          .where('assetDocId', isEqualTo: assetDoc.id)
          .where('status', isNotEqualTo: 'Fixed')
          .limit(1)
          .get();

      if (existingRequest.docs.isEmpty) {
        final asset = Asset.fromFirestore(assetDoc);

        await firestore.collection('service_requests').add({
          'assetDocId': asset.docId,
          'assetId': asset.id,
          'assetName': asset.name,
          'damage': 'Admin reported issue',
          'comment': 'Asset marked as Service Needed by admin',
          'status': 'In Progress',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Request"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryTeal, darkTeal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "In Progress"),
            Tab(text: "Fixed"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildServiceList("In Progress"),
          _buildServiceList("Fixed"),
        ],
      ),
      bottomNavigationBar: const FooterNav(),
    );
  }

  // =====================================================
  // SERVICE REQUEST LIST
  // =====================================================
  Widget _buildServiceList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('service_requests')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "No $status service requests",
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final serviceDoc = snapshot.data!.docs[index];
            final data = serviceDoc.data() as Map<String, dynamic>;

            final Color statusColor =
                status == "Fixed" ? Colors.green : Colors.amber;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  data['assetId'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${data['assetName']}\nIssue: ${data['damage']}",
                ),
                isThreeLine: true,
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TechnicianServiceDetailPage(
                              item: {
                                'serviceId': serviceDoc.id,
                                ...data,
                              },
                            ),
                          ),
                        );
                      },
                      child: const Text("View Detail"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
