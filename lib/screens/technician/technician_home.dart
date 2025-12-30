import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../widgets/footer_nav.dart';
import '../../services/chat_list_page.dart';
import 'asset_list_page.dart';
import 'technician_service_page.dart';
import 'technician_profile_page.dart';
import 'technician_report_page.dart';
import 'technician_activity_page.dart';

class TechnicianHomePage extends StatefulWidget {
  const TechnicianHomePage({super.key});

  @override
  State<TechnicianHomePage> createState() => _TechnicianHomePageState();
}

class _TechnicianHomePageState extends State<TechnicianHomePage> {
  String _selectedYear = DateTime.now().year.toString();

  DateTime? _parseDate(Map<String, dynamic> data) {
    if (data['date'] is Timestamp) return (data['date'] as Timestamp).toDate();
    if (data['createdAt'] is Timestamp) {
      return (data['createdAt'] as Timestamp).toDate();
    }
    if (data['timestamp'] is Timestamp) {
      return (data['timestamp'] as Timestamp).toDate();
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
      case 'PENDING':
        return Colors.orange;
      case 'IN PROGRESS':
        return Colors.blue;
      case 'FIXED':
        return Colors.green;
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
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.message_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatListPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TechnicianProfilePage(),
                ),
              );
            },
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
              const Text(
                "Hi, Technician!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              /// ================= FEATURE BUTTONS =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _featureCard(
                    icon: Icons.devices_other,
                    title: "Assets",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AssetListPage(),
                      ),
                    ),
                  ),
                  _featureCard(
                    icon: Icons.history,
                    title: "Activity",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TechnicianActivityPage(),
                      ),
                    ),
                  ),
                  _featureCard(
                    icon: Icons.build,
                    title: "Service",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TechnicianServicesPage(),
                      ),
                    ),
                  ),
                  _featureCard(
                    icon: Icons.bar_chart,
                    title: "Reports",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TechnicianReportPage(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// ================= SUMMARY CARDS =================
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('assets')
                    .snapshots(),
                builder: (context, assetSnap) {
                  if (!assetSnap.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final totalAssets = assetSnap.data!.docs.length;

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('service_requests')
                        .snapshots(),
                    builder: (context, serviceSnap) {
                      if (!serviceSnap.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final services = serviceSnap.data!.docs;
                      final Set<String> pendingSet = {};
                      final Set<String> inProgressSet = {};
                      final Set<String> fixedSet = {};

                      for (var d in services) {
                        final sd = d.data() as Map<String, dynamic>;
                        final status =
                            (sd['status'] ?? '').toString().toLowerCase();

                        String key =
                            (sd['assetDocId'] ?? sd['assetId'] ?? '').toString();
                        if (key.isEmpty) key = d.id;

                        if (status.contains('pending')) {
                          pendingSet.add(key);
                        } else if (status.contains('progress')) {
                          inProgressSet.add(key);
                        } else if (status.contains('fixed')) {
                          fixedSet.add(key);
                        }
                      }

                      /// ------- Updated Summary Card UI like Admin -------
                      return Row(
                        children: [
                          _summaryCard(
                              "Total Assets", totalAssets, Icons.devices, Color(0xFF00A7A7)),
                          _summaryCard(
                              "Pending", pendingSet.length, Icons.pending_actions, Color(0xFF00A7A7)),
                          _summaryCard(
                              "In Progress", inProgressSet.length, Icons.check_circle, Color(0xFF00A7A7)),
                          _summaryCard(
                              "Fixed", fixedSet.length, Icons.computer, Color(0xFF00A7A7)),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              /// ================= RECENT ASSETS =================
              const Text(
                "Recent Assets",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('asset_history')
                    .orderBy('timestamp', descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return const CircularProgressIndicator();
                  if (snap.data!.docs.isEmpty) {
                    return const Text("No recent assets available.");
                  }

                  return Column(
                    children: snap.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final assetId = data['assetId'] ?? '';
                      final action =
                          (data['action'] ?? 'Activity').toString();
                      final date = _parseDate(data) ?? DateTime.now();
                      final formattedDate =
                          "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('assets')
                            .doc(assetId.toString())
                            .get(),
                        builder: (context, assetSnap) {
                          String name = assetId.toString();
                          String status = "UNKNOWN";

                          if (assetSnap.hasData && assetSnap.data!.exists) {
                            final a =
                                assetSnap.data!.data() as Map<String, dynamic>;
                            name = a['name'] ?? assetId;
                            status = a['status'] ?? 'UNKNOWN';
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "ID: $assetId",
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          _assetStatusColor(status).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _assetStatusColor(status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),

              /// ================= GRAPH =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Monthly Service Requests",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: _selectedYear,
                    items: List.generate(
                      5,
                      (i) => DateTime.now().year - i,
                    )
                        .map(
                          (y) => DropdownMenuItem(
                            value: y.toString(),
                            child: Text(y.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _selectedYear = v);
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// ===== DUMMY GRAPH =====
              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    maxY: 12,
                    barGroups: List.generate(
                      12,
                      (i) => BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: (i + 2).toDouble(),
                            width: 14,
                            color: const Color(0xFF00A7A7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            const m = [
                              'J','F','M','A','M','J','J','A','S','O','N','D'
                            ];
                            return Text(m[v.toInt()]);
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: true),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const FooterNav(role: 'Technician'),
    );
  }

  /// ---------- SUMMARY CARD ---------- (Updated UI like Admin)
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
              Text(
                value.toString(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

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
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
