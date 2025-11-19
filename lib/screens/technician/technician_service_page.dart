import 'package:flutter/material.dart';
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

  final List<Map<String, dynamic>> onProgress = [
    {
      'id': 'B230159',
      'type': 'Laptop',
      'damage': 'Keyboard Malfunction',
      'status': 'In Progress',
    },
    {
      'id': 'RQE6138',
      'type': 'Power Cable',
      'damage': 'Broken Wire',
      'status': 'In Progress',
    },
  ];

  final List<Map<String, dynamic>> fixed = [
    {
      'id': 'A67495',
      'type': 'Electronics',
      'damage': 'Screen Replaced',
      'status': 'Fixed',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Service Request"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          // 🟢 KEY CHANGE 1: Set the selected tab label color to white
          labelColor: Colors.white,
          // 🟢 KEY CHANGE 2: Set the unselected tab label color to a lighter white for contrast
          unselectedLabelColor: Colors.white70,
          // 🟢 KEY CHANGE 3: Set the indicator (underline) color to white
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'On Progress'),
            Tab(text: 'Fixed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(context, onProgress),
          _buildList(context, fixed),
        ],
      ),
      bottomNavigationBar: const FooterNav(),
    );
  }

  Widget _buildList(BuildContext context, List<Map<String, dynamic>> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        Color statusColor;

        if (item['status'] == 'Fixed') {
          statusColor = Colors.green;
        } else if (item['status'] == 'In Progress') {
          statusColor = Colors.amber;
        } else {
          statusColor = Colors.red;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: ListTile(
            title: Text(item['id']),
            subtitle: Text('${item['type']} - ${item['damage']}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['status'],
                    style: TextStyle(color: statusColor, fontSize: 12),
                  ),
                ),
                TextButton(
                  child: const Text('View Detail'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TechnicianServiceDetailPage(item: item),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
