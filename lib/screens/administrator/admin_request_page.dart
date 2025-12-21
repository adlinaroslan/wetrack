import 'package:flutter/material.dart';
import '../../models/request_model.dart';
import 'package:wetrack/services/firestore_service.dart';
import 'admin_request_detail.dart';

class AdminRequestPage extends StatefulWidget {
  const AdminRequestPage({Key? key}) : super(key: key);

  @override
  State<AdminRequestPage> createState() => _AdminRequestPageState();
}

/* ---------- STATUS COLOR HELPER ---------- */

class StatusColor {
  final Color background;
  final Color text;

  const StatusColor({required this.background, required this.text});
}

StatusColor getStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'APPROVED':
      return const StatusColor(
        background: Color(0xFFDFF5E1),
        text: Colors.green,
      );
    case 'PENDING':
    case 'PENDING_REQUEST':
      return const StatusColor(
        background: Color(0xFFFFF8E1),
        text: Colors.amber,
      );
    case 'DECLINED':
      return const StatusColor(
        background: Color(0xFFFDECEA),
        text: Colors.red,
      );
    case 'COMPLETED':
      return const StatusColor(
        background: Color(0xFFE8F5E9),
        text: Colors.greenAccent,
      );
    default:
      return const StatusColor(
        background: Colors.grey,
        text: Colors.black54,
      );
  }
}

/* ---------- PAGE STATE ---------- */

class _AdminRequestPageState extends State<AdminRequestPage> {
  final FirestoreService _fs = FirestoreService();

  void _openDetail(AssetRequest req) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminRequestDetailPage(request: req),
      ),
    );
  }

  Widget _requestCard(AssetRequest r) {
    final statusColors = getStatusColor(r.status);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Status indicator bar
            Container(
              width: 8,
              height: 110,
              decoration: BoxDecoration(
                color: statusColors.background.withOpacity(0.7),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Date Time : ${r.requestedDate.toLocal().toString().split('.').first}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    "Asset ID : ${r.assetId}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    "User : ${r.userName}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => _openDetail(r),
                        child: const Text("View Detail"),
                      ),

                      // Action buttons only for pending requests
                      if (r.status.toUpperCase() == 'PENDING' ||
                          r.status.toUpperCase() == 'PENDING_REQUEST')
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await _fs.approveRequest(
                                  requestId: r.id,
                                  assetId: r.assetId,
                                  borrowerUserId: r.userId,
                                  dueDate: DateTime.now()
                                      .add(const Duration(days: 7)),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Accept"),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                await _fs.declineRequest(
                                  requestId: r.id,
                                  assetId: r.assetId,
                                  borrowerUserId: r.userId,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Decline"),
                            ),
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            r.status,
                            style: TextStyle(
                              color: statusColors.text,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _requestList(Set<String> statuses) {
    return StreamBuilder<List<AssetRequest>>(
      stream: _fs.getAllRequests(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = snapshot.data!
            .where((r) => statuses.contains(r.status.toUpperCase()))
            .toList();

        if (list.isEmpty) {
          return const Center(
            child: Text(
              "No requests",
              style: TextStyle(color: Colors.black54),
            ),
          );
        }

        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) => _requestCard(list[i]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 👈 THREE TABS
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text("Requests"),
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
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "In Progress"),
              Tab(text: "Approved"),
              Tab(text: "Declined"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // In Progress
            _requestList({'PENDING', 'PENDING_REQUEST'}),

            // Approved
            _requestList({'APPROVED', 'COMPLETED'}),

            // Declined
            _requestList({'DECLINED'}),
          ],
        ),
      ),
    );
  }
}
