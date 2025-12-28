import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import 'technician_service_detail_page.dart';

class TechnicianServicesPage extends StatelessWidget {
  const TechnicianServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // Align title immediately next to back button
          titleSpacing: 0,
          title: const Text(
            "Services",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: false, // align left
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
          bottom: const TabBar(
            indicatorWeight: 3,
            labelColor: Colors.white,       // active tab label
            unselectedLabelColor: Colors.white70, // inactive tab label
            tabs: [
              Tab(text: "In Progress"),
              Tab(text: "Fixed"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ServiceList(status: "On Progress"),
            _ServiceList(status: "Fixed"),
          ],
        ),
      ),
    );
  }
}

class _ServiceList extends StatelessWidget {
  final String status;
  const _ServiceList({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == "On Progress") {
      return StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().getServiceRequestsByStatus(status),
        builder: (context, serviceSnapshot) {
          if (!serviceSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: FirestoreService().getAssetsWithServiceNeeded(),
            builder: (context, assetSnapshot) {
              if (!assetSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final allDocs = [
                ...serviceSnapshot.data!,
                ...assetSnapshot.data!,
              ];

              if (allDocs.isEmpty) {
                return const Center(child: Text("No services found"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: allDocs.length,
                itemBuilder: (context, index) {
                  final data = allDocs[index];
                  final assetId =
                      (data['assetId'] ?? data['id'] ?? '').toString();
                  final assetName =
                      (data['assetName'] ?? data['name'] ?? '').toString();
                  final serviceId =
                      (data['serviceId'] ?? data['assetDocId'] ?? '').toString();

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      isThreeLine: true,
                      contentPadding: const EdgeInsets.all(12),
                      leading: const CircleAvatar(
                        child: Icon(Icons.build),
                      ),
                      title: Text(
                        assetId.isNotEmpty ? assetId : 'Unknown Asset',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        assetName.isNotEmpty ? assetName : 'No name',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TechnicianServiceDetailPage(
                              item: {
                                ...data,
                                'serviceId': serviceId,
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      );
    }

    // FIXED TAB
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService().getServiceRequestsByStatus(status),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final data = snapshot.data![index];
            final assetId = (data['assetId'] ?? '').toString();
            final assetName = (data['assetName'] ?? '').toString();
            final serviceId = (data['serviceId'] ?? '').toString();

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                isThreeLine: true,
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, color: Colors.white),
                ),
                title: Text(
                  assetId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  assetName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TechnicianServiceDetailPage(
                        item: {
                          ...data,
                          'serviceId': serviceId,
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
