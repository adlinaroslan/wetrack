import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/footer_nav.dart';
import '../../services/chat_list_page.dart';
import 'admin_activity_page.dart';
import 'asset_list_page.dart';
import 'admin_request_page.dart';
import 'admin_profile_page.dart';
import 'admin_notification_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String _selectedYear = '2021';

  // Temporary sample data
  final Map<String, String> _assetInfo = const {
    "id": "B 2791 STJ",
    "name": "Laptop Dell",
    "date": "29 Dec 2021 10:23",
  };

  final Map<String, String> _incomingRequest = const {
    "date": "29 Dec 2021 12:05",
    "assetId": "A5684",
    "status": "On Progress",
  };

  final Map<String, String> _lastRequest = const {
    "date": "29 Dec 2021 12:05",
    "assetId": "A5684",
    "status": "Approved",
  };

  // Sample monthly usage data for multiple years
  final Map<String, Map<String, int>> _yearlyUsage = {
    '2021': {
      "Jan": 5,
      "Feb": 8,
      "Mar": 3,
      "Apr": 10,
      "May": 7,
      "Jun": 6,
      "Jul": 9,
      "Aug": 4,
      "Sep": 11,
      "Oct": 6,
      "Nov": 8,
      "Dec": 7,
    },
    '2022': {
      "Jan": 6,
      "Feb": 9,
      "Mar": 4,
      "Apr": 11,
      "May": 6,
      "Jun": 7,
      "Jul": 10,
      "Aug": 5,
      "Sep": 12,
      "Oct": 7,
      "Nov": 9,
      "Dec": 8,
    },
    '2023': {
      "Jan": 7,
      "Feb": 10,
      "Mar": 5,
      "Apr": 12,
      "May": 8,
      "Jun": 9,
      "Jul": 11,
      "Aug": 6,
      "Sep": 13,
      "Oct": 8,
      "Nov": 10,
      "Dec": 9,
    },
  };

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'On Progress':
        return Colors.amber;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // Top Bar
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "WeTrack.",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // ⭐ ONLY CHANGE MADE HERE: Added Profile Icon
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

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              const Text(
                "Hi, Admin!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Feature Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _featureCard(
                    context,
                    icon: Icons.devices_other,
                    title: "Asset",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AssetListPage(),
                        ),
                      );
                    },
                  ),
                  _featureCard(
                    context,
                    icon: Icons.history,
                    title: "Activity",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminActivityPage(),
                        ),
                      );
                    },
                  ),
                  _featureCard(
                    context,
                    icon: Icons.request_page,
                    title: "Request",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminRequestPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Asset Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Assets Info",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(_assetInfo['date']!),
                ],
              ),
              const SizedBox(height: 10),
              _infoCard(
                icon: Icons.laptop_mac,
                title: _assetInfo['id']!,
                subtitle: _assetInfo['name']!,
              ),

              const SizedBox(height: 25),
              const Text("Incoming Request",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _requestCard(_incomingRequest),

              const SizedBox(height: 25),
              const Text("Last Request",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _requestCard(_lastRequest),

              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Monthly Asset Usage",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: _selectedYear,
                    items: _yearlyUsage.keys
                        .map((year) => DropdownMenuItem(
                              value: year,
                              child: Text(year),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedYear = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _assetUsageGraph(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const FooterNav(role: 'Administrator'),
    );
  }

  Widget _featureCard(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
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
                  color: Color(0x1A000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: Icon(
                  icon,
                  size: 35,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFF00BFA6).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Icon(
                icon,
                size: 28,
                color: Colors.white,
              ),
            ),
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _requestCard(Map<String, String> request) {
    final color = _statusColor(request['status']!);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date / Time : ${request['date']}"),
            Text("Asset ID     : ${request['assetId']}"),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text("Status      : "),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request['status']!,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _assetUsageGraph() {
    final months = _yearlyUsage[_selectedYear]!.keys.toList();
    final usageValues = _yearlyUsage[_selectedYear]!.values.toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY:
                  (usageValues.reduce((a, b) => a > b ? a : b)).toDouble() + 2,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < months.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            months[index],
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    interval: 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, interval: 2),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(usageValues.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: usageValues[index].toDouble(),
                      width: 14,
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF004C5C), Color(0xFF00A7A7)],
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
  }
}
