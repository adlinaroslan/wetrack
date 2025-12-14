import 'package:flutter/material.dart';
import 'asset_list_page.dart';
import 'technician_activity_page.dart';
import 'technician_notification_page.dart';
import 'technician_service_page.dart';
import 'technician_profile_page.dart'; // <-- Import the profile page
import '../../widgets/footer_nav.dart';
import '../../services/chat_list_page.dart';

class TechnicianHomePage extends StatelessWidget {
  const TechnicianHomePage({super.key});

  // Sample recent status data for the list at the bottom
  List<Map<String, String>> get _recentServices => const [
        {"id": "B230159", "type": "Laptop", "status": "In Progress"},
        {"id": "RQE6138", "type": "Power Cable", "status": "In Progress"},
        {"id": "A67495", "type": "Electronics", "status": "Fixed"},
      ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Fixed':
        return Colors.green;
      case 'In Progress':
        return Colors.amber;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
          // Profile button
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
          // Notification button
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TechnicianNotificationPage(),
                ),
              );
            },
          ),
          // Messages icon: open chat list (plain white icon)
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ChatListPage()));
            },
            icon: const Icon(Icons.message_outlined, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              const Text(
                "Hi, Technician!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // 3 Feature Cards (Asset, Activity, Service)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFeatureCard(
                    context,
                    icon: Icons.devices_other,
                    title: "Asset",
                    page: const AssetListPage(),
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.history,
                    title: "Activity",
                    page: const TechnicianActivityPage(),
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.build_circle,
                    title: "Service",
                    page: const TechnicianServicePage(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Services header with "See all"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Services",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TechnicianServicePage(),
                        ),
                      );
                    },
                    child: const Text("See all"),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Recent Services list
              Column(
                children: _recentServices.map((s) {
                  final color = _statusColor(s["status"]!);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color(0xFF00BFA6).withOpacity(0.15),
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) => const LinearGradient(
                            colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          blendMode: BlendMode.srcIn,
                          child: const Icon(Icons.build, color: Colors.white),
                        ),
                      ),
                      title: Text(s["id"]!),
                      subtitle: Text(s["type"]!),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          s["status"]!,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),

      // Footer
      bottomNavigationBar: const FooterNav(role: 'Technician'),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000), // ~10% black
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ShaderMask(
              shaderCallback: (Rect bounds) => const LinearGradient(
                colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Icon(icon, size: 35, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
