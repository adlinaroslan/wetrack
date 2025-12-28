import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/footer_nav.dart';
import '../../services/chat_list_page.dart';

import 'asset_list_page.dart';
import 'technician_activity_page.dart';
import 'technician_notification_page.dart';
import 'technician_service_page.dart';
import 'technician_profile_page.dart';
import 'technician_report_page.dart';

class TechnicianHomePage extends StatefulWidget {
  const TechnicianHomePage({super.key});

  @override
  State<TechnicianHomePage> createState() => _TechnicianHomePageState();
}

class _TechnicianHomePageState extends State<TechnicianHomePage> {
  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'FIXED':
        return Colors.green;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'PENDING':
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
                MaterialPageRoute(
                    builder: (_) => const TechnicianProfilePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const TechnicianNotificationPage()),
              );
            },
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
                    title: "Asset",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AssetListPage()),
                    ),
                  ),
                  _featureCard(
                    icon: Icons.history,
                    title: "Activity",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TechnicianActivityPage()),
                    ),
                  ),
                  _featureCard(
                    icon: Icons.build_circle,
                    title: "Service",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TechnicianServicesPage()),
                    ),
                  ),
                  _featureCard(
                    icon: Icons.bar_chart,
                    title: "Report",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TechnicianReportPage()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// ================= SUMMARY CARDS =================
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('services')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  final total = docs.length;
                  final pending = docs
                      .where((d) =>
                          d['status'].toString().toUpperCase() == 'PENDING')
                      .length;
                  final inProgress = docs
                      .where((d) =>
                          d['status'].toString().toUpperCase() ==
                          'IN_PROGRESS')
                      .length;
                  final fixed = docs
                      .where((d) =>
                          d['status'].toString().toUpperCase() == 'FIXED')
                      .length;

                  return Row(
                    children: [
                      _summaryCard("Total", total, Icons.build, Colors.teal),
                      _summaryCard(
                          "Pending", pending, Icons.pending, Colors.red),
                      _summaryCard("In Progress", inProgress,
                          Icons.build_circle, Colors.orange),
                      _summaryCard(
                          "Fixed", fixed, Icons.check_circle, Colors.green),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              /// ---------- RECENT SERVICES ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Services",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TechnicianServicesPage()),
                      );
                    },
                    child: const Text("See all"),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('services')
                    .orderBy('createdAt', descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Text("No service records found.");
                  }

                  return Column(
                    children:
                        snapshot.data!.docs.map(_serviceCard).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const FooterNav(role: 'Technician'),
    );
  }

  /// ---------- SUMMARY CARD ----------
  Widget _summaryCard(
      String title, int value, IconData icon, Color color) {
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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------- FEATURE CARD ----------
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

  /// ---------- SERVICE CARD ----------
  Widget _serviceCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final status = data['status'] ?? 'UNKNOWN';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.build),
        title: Text(data['assetName'] ?? '-'),
        subtitle: Text(data['assetId'] ?? '-'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor(status).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: _statusColor(status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
