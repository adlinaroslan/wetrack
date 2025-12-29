import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/footer_nav.dart';
import '../../services/chat_list_page.dart';
import 'admin_activity_page.dart';
import 'asset_list_page.dart';
import 'admin_request_page.dart';
import 'admin_profile_page.dart';
import 'admin_notification_page.dart';
import 'admin_report_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String _selectedYear = DateTime.now().year.toString();

  DateTime? _parseDate(Map<String, dynamic> data) {
    if (data['date'] is Timestamp) {
      return (data['date'] as Timestamp).toDate();
    }
    if (data['createdAt'] is Timestamp) {
      return (data['createdAt'] as Timestamp).toDate();
    }
    return null;
  }

  Color _assetStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return Colors.green;
      case 'IN USE':
        return Colors.orange;
      case 'DISPOSED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      /// ---------------- APP BAR ----------------
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "WeTrack.",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminProfilePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminNotificationPage()),
              );
            },
          ),
          // Messages icon: open chat list
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ChatListPage()));
            },
            icon: const Icon(Icons.message_outlined, color: Colors.white),
          ),
        ],
      ),

      /// ---------------- BODY ----------------
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---------- GREETING ----------
              const Text(
                "Hi, Admin!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              /// ================= FEATURE BUTTONS (MOVED UP) =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _featureCard(
                    icon: Icons.devices_other,
                    title: "Asset",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AssetListPage()),
                    ),
                  ),
                  _featureCard(
                    icon: Icons.history,
                    title: "Activity",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminActivityPage()),
                    ),
                  ),
                  _featureCard(
                    icon: Icons.request_page,
                    title: "Request",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminRequestPage()),
                    ),
                  ),
                  _featureCard(
                    icon: Icons.bar_chart,
                    title: "Report",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminReportPage()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// ================= SUMMARY COUNT CARDS (MOVED DOWN) =================
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('assets').snapshots(),
                builder: (context, assetSnap) {
                  if (!assetSnap.hasData)
                    return const CircularProgressIndicator();

                  final totalAssets = assetSnap.data!.docs.length;
                  final inUse = assetSnap.data!.docs
                      .where((d) =>
                          d['status'].toString().toUpperCase() == 'IN USE')
                      .length;

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('requests')
                        .snapshots(),
                    builder: (context, reqSnap) {
                      if (!reqSnap.hasData)
                        return const CircularProgressIndicator();

                      final pending = reqSnap.data!.docs.where((d) {
                        final s = d['status'].toString().toUpperCase();
                        return s == 'PENDING' || s == 'PENDING_REQUEST';
                      }).length;

                      final approved = reqSnap.data!.docs.where((d) {
                        final s = d['status'].toString().toUpperCase();
                        return s == 'APPROVED' || s == 'COMPLETED';
                      }).length;

                      return Row(
                        children: [
                          _summaryCard("Total Assets", totalAssets,
                              Icons.devices, Color(0xFF00A7A7)),
                          _summaryCard("Pending", pending,
                              Icons.pending_actions, Color(0xFF00A7A7)),
                          _summaryCard("Approved", approved, Icons.check_circle,
                              Color(0xFF00A7A7)),
                          _summaryCard("In Use", inUse, Icons.computer,
                              Color(0xFF00A7A7)),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              /// ---------- RECENT ASSETS ----------
              const Text(
                "Recent Assets",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('assets')
                    .orderBy('createdAt', descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
                  if (snapshot.data!.docs.isEmpty) {
                    return const Text("No recent assets available.");
                  }
                  return Column(
                    children: snapshot.data!.docs.map(_assetCard).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),

              /// ================= GRAPH (UNCHANGED) =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Monthly Asset Usage",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: _selectedYear,
                    items: List.generate(5, (i) => DateTime.now().year - i)
                        .map((y) => DropdownMenuItem(
                              value: y.toString(),
                              child: Text(y.toString()),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedYear = v);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('requests')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();

                  final monthly = List<int>.filled(12, 0);

                  for (var doc in snapshot.data!.docs) {
                    final date = _parseDate(doc.data() as Map<String, dynamic>);
                    if (date != null && date.year.toString() == _selectedYear) {
                      monthly[date.month - 1]++;
                    }
                  }

                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            maxY: monthly.reduce((a, b) => a > b ? a : b) + 2,
                            barGroups: List.generate(12, (i) {
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: monthly[i].toDouble(),
                                    width: 14,
                                    borderRadius: BorderRadius.circular(4),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF004C5C),
                                        Color(0xFF00A7A7)
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const FooterNav(role: 'Administrator'),
    );
  }

  /// ---------- SUMMARY CARD ----------
  Widget _summaryCard(String title, int value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 6),
              Text(value.toString(),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------- FEATURE BUTTON ----------
  Widget _featureCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: Icon(icon, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// ---------- ASSET CARD ----------
  Widget _assetCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final status = data['status'] ?? 'UNKNOWN';

    return Card(
      child: ListTile(
        title: Text(data['name'] ?? '-'),
        subtitle: Text(data['id'] ?? '-'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _assetStatusColor(status).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
                color: _assetStatusColor(status), fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
