// lib/pages/admin/admin_request_page.dart
import 'package:flutter/material.dart';
import '../../models/asset_request.dart';
import 'admin_request_detail.dart';

class AdminRequestPage extends StatefulWidget {
  const AdminRequestPage({Key? key}) : super(key: key);

  @override
  State<AdminRequestPage> createState() => _AdminRequestPageState();
}

// Helper class for status colors
class StatusColor {
  final Color background;
  final Color text;

  const StatusColor({required this.background, required this.text});
}

// Function to get status colors
StatusColor getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return const StatusColor(background: Color(0xFFDFF5E1), text: Colors.green);
    case 'in progress':
      return const StatusColor(background: Color(0xFFE0F7FA), text: Colors.teal);
    case 'pending':
      return const StatusColor(background: Color(0xFFFFF8E1), text: Colors.amber);
    case 'declined':
      return const StatusColor(background: Color(0xFFFDECEA), text: Colors.red);
    case 'completed':
      return const StatusColor(background: Color(0xFFE8F5E9), text: Colors.greenAccent);
    default:
      return const StatusColor(background: Colors.grey, text: Colors.black54);
  }
}

class _AdminRequestPageState extends State<AdminRequestPage> {
  // Sample data — replace with real data source (Firebase / API) later
  final List<AssetRequest> _requests = [
    AssetRequest(
      requestId: "#ROE5638",
      assetId: "B230159",
      requesterName: "Adlina Roslan",
      reason: "Need laptop for presentation",
      dateTime: "29 Dec 2021 12:05",
      status: "In Progress",
    ),
    AssetRequest(
      requestId: "#RQE6139",
      assetId: "A67495",
      requesterName: "Nurul Adlina",
      reason: "Borrow projector",
      dateTime: "29 Dec 2021 10:00",
      status: "Approved",
    ),
    AssetRequest(
      requestId: "#RQE6140",
      assetId: "A12501",
      requesterName: "PT. Example 1",
      reason: "USB pendrive request",
      dateTime: "29 Dec 2021 09:15",
      status: "In Progress",
    ),
  ];

  List<AssetRequest> get _inProgress =>
      _requests.where((r) => r.status == "In Progress" || r.status == "Pending").toList();

  List<AssetRequest> get _approved =>
      _requests.where((r) => r.status == "Approved" || r.status == "Completed").toList();

  void _acceptRequest(AssetRequest req) {
    setState(() {
      req.status = "Approved";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Request accepted")),
    );
  }

  void _declineRequest(AssetRequest req) {
    setState(() {
      req.status = "Declined";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Request declined")),
    );
  }

  void _openDetail(AssetRequest req) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminRequestDetailPage(
          request: req,
          onStatusChanged: (newStatus) {
            setState(() {
              req.status = newStatus;
            });
          },
        ),
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
            // Side color bar
            Container(
              width: 8,
              height: 110,
              decoration: BoxDecoration(
                color: statusColors.background.withOpacity(0.5),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Date Time :  ${r.dateTime}", style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                          child: Text("Asset ID    :  ${r.assetId}", style: const TextStyle(fontSize: 12))),
                      const SizedBox(width: 6),
                      Text("B/L Number : BL123456", style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text("User          :  ${r.requesterName}", style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => _openDetail(r),
                        child: const Text("View Detail"),
                      ),
                      if (r.status.toLowerCase() != "approved" && r.status.toLowerCase() != "declined")
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => _acceptRequest(r),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightBlue[200], foregroundColor: Colors.white),
                              child: const Text("Accept"),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _declineRequest(r),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              child: const Text("Decline"),
                            ),
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inProgressList() {
    final list = _inProgress;
    if (list.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text("No ongoing requests", style: TextStyle(color: Colors.black54)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final r = list[idx];
        return _requestCard(r);
      },
    );
  }

  Widget _approvedList() {
    final list = _approved;
    if (list.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text("No approved requests", style: TextStyle(color: Colors.black54)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final r = list[idx];
        return _requestCard(r);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF00BFA6),
          elevation: 0,
          leading: BackButton(color: Colors.white),
          title: const Text('Requests', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "In Progress"),
              Tab(text: "Approved requests"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _inProgressList(),
            _approvedList(),
          ],
        ),
      ),
    );
  }
}
