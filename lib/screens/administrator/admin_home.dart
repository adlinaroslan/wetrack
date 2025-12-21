import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/footer_nav.dart';
import '../../services/chat_list_page.dart';
import 'admin_activity_page.dart';
import 'asset_list_page.dart';
import 'admin_request_page.dart';
import 'admin_profile_page.dart';
import 'admin_report_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String _selectedYear = DateTime.now().year.toString();

  /// --------------------- Safe date parser ---------------------
  DateTime? parseDocumentDate(Map<String, dynamic> data) {
    if (data.containsKey('date') && data['date'] is Timestamp) {
      return (data['date'] as Timestamp).toDate();
    } else if (data.containsKey('createdAt') && data['createdAt'] is Timestamp) {
      return (data['createdAt'] as Timestamp).toDate();
    } else if (data.containsKey('registerDate') && data['registerDate'] is String) {
      try {
        return DateTime.tryParse(data['registerDate']);
      } catch (_) {
        return null;
      }
    } else {
      return null;
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return Colors.green;
      case 'IN USE':
        return Colors.amber;
      case 'RETIRED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _requestStatusColor(String status) {
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
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.message_outlined, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChatListPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hi, Admin!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              /// --------------------- Summary Cards ---------------------
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('assets').snapshots(),
                builder: (context, assetSnap) {
                  if (!assetSnap.hasData) return const CircularProgressIndicator();
                  int totalAssets = assetSnap.data!.docs.length;

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('requests').snapshots(),
                    builder: (context, reqSnap) {
                      if (!reqSnap.hasData) return const CircularProgressIndicator();

                      int approved = reqSnap.data!.docs.where((d) => d['status']=='Approved').length;
                      int pending = reqSnap.data!.docs.where((d) => d['status']=='On Progress').length;
                      int inUse = assetSnap.data!.docs.where((d) => d['status'].toString().toUpperCase()=='IN USE').length;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _summaryCard("Total Assets", totalAssets.toString(), Icons.devices, Colors.blue),
                          _summaryCard("Pending Requests", pending.toString(), Icons.pending_actions, Colors.orange),
                          _summaryCard("Approved", approved.toString(), Icons.check_circle, Colors.green),
                          _summaryCard("In Use", inUse.toString(), Icons.computer, Colors.purple),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              /// --------------------- Feature Buttons ---------------------
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
                        MaterialPageRoute(builder: (_) => const AssetListPage()),
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
                        MaterialPageRoute(builder: (_) => const AdminActivityPage()),
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
                        MaterialPageRoute(builder: (_) => const AdminRequestPage()),
                      );
                    },
                  ),
                  _featureCard(
                    context,
                    icon: Icons.bar_chart,
                    title: "Report",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminReportPage()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              /// --------------------- Recent Assets ---------------------
              const Text("Recent Assets", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('assets')
                    .orderBy('createdAt', descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  final assets = snapshot.data!.docs;
                  if (assets.isEmpty) return const Text("No recent assets available.");
                  return Column(
                    children: assets.map((doc) => _assetCard(doc)).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              /// --------------------- Incoming Requests ---------------------
              const Text("Incoming Requests", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('requests')
                    .where('status', isEqualTo: 'On Progress')
                    .orderBy('date', descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  final requests = snapshot.data!.docs;
                  if (requests.isEmpty) return const Text("No incoming requests.");
                  return Column(
                    children: requests.map((doc) {
                      final date = parseDocumentDate(doc.data() as Map<String, dynamic>);
                      final dateStr = date != null ? "${date.day}-${date.month}-${date.year}" : "N/A";
                      return _requestCard({
                        'date': dateStr,
                        'assetId': doc['assetId'],
                        'status': doc['status'],
                      });
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              /// --------------------- Monthly Asset Usage ---------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Monthly Asset Usage", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  DropdownButton<String>(
                    value: _selectedYear,
                    items: List.generate(5, (i) => DateTime.now().year - i)
                        .map((year) => DropdownMenuItem(
                              value: year.toString(),
                              child: Text(year.toString()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedYear = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('requests').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  final requests = snapshot.data!.docs.where((doc) {
                    final date = parseDocumentDate(doc.data() as Map<String, dynamic>);
                    return date != null && date.year.toString() == _selectedYear;
                  }).toList();

                  Map<String, int> monthlyUsage = {
                    "Jan":0,"Feb":0,"Mar":0,"Apr":0,"May":0,"Jun":0,
                    "Jul":0,"Aug":0,"Sep":0,"Oct":0,"Nov":0,"Dec":0,
                  };

                  for (var req in requests) {
                    final date = parseDocumentDate(req.data() as Map<String, dynamic>);
                    if (date == null) continue;
                    switch (date.month) {
                      case 1: monthlyUsage["Jan"] = monthlyUsage["Jan"]! + 1; break;
                      case 2: monthlyUsage["Feb"] = monthlyUsage["Feb"]! + 1; break;
                      case 3: monthlyUsage["Mar"] = monthlyUsage["Mar"]! + 1; break;
                      case 4: monthlyUsage["Apr"] = monthlyUsage["Apr"]! + 1; break;
                      case 5: monthlyUsage["May"] = monthlyUsage["May"]! + 1; break;
                      case 6: monthlyUsage["Jun"] = monthlyUsage["Jun"]! + 1; break;
                      case 7: monthlyUsage["Jul"] = monthlyUsage["Jul"]! + 1; break;
                      case 8: monthlyUsage["Aug"] = monthlyUsage["Aug"]! + 1; break;
                      case 9: monthlyUsage["Sep"] = monthlyUsage["Sep"]! + 1; break;
                      case 10: monthlyUsage["Oct"] = monthlyUsage["Oct"]! + 1; break;
                      case 11: monthlyUsage["Nov"] = monthlyUsage["Nov"]! + 1; break;
                      case 12: monthlyUsage["Dec"] = monthlyUsage["Dec"]! + 1; break;
                    }
                  }

                  final months = monthlyUsage.keys.toList();
                  final values = monthlyUsage.values.toList();

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (values.isEmpty ? 10 : values.reduce((a,b)=>a>b?a:b))+2,
                            barGroups: List.generate(values.length, (index) {
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: values[index].toDouble(),
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
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int idx = value.toInt();
                                    if (idx < 0 || idx >= months.length) return const SizedBox();
                                    return Text(months[idx], style: const TextStyle(fontSize: 10));
                                  }
                                ),
                              ),
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                            ),
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

  /// --------------------- Summary Card ---------------------
  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  /// --------------------- Feature Card ---------------------
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
                child: Icon(icon, size: 35, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// --------------------- Asset Card ---------------------
  Widget _assetCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final name = data['name'] ?? "Unknown Asset";
    final id = data['id'] ?? "Unknown ID";
    final status = data['status'] ?? "Unknown";

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(id),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor(status).withAlpha(40),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  /// --------------------- Request Card ---------------------
  Widget _requestCard(Map<String, String> request) {
    final color = _requestStatusColor(request['status']!);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(request['status']!, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
