import 'package:flutter/material.dart';

class TechnicianNotificationPage extends StatelessWidget {
  const TechnicianNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'icon': Icons.error,
        'color': Colors.red,
        'message': 'Returned of HDMI – cable : A67495 is overdue',
        'date': '26 May 2025'
      },
      {
        'icon': Icons.check_circle,
        'color': Colors.green,
        'message': 'Asset Request Approved USB – Pendrive',
        'date': '26 May 2025'
      },
      {
        'icon': Icons.qr_code_2,
        'color': Colors.blue,
        'message': 'Barcode of Laptop : C23103 Scanned',
        'date': '10 Feb 2025'
      },
      {
        'icon': Icons.check_circle,
        'color': Colors.green,
        'message': 'Asset Request Approved HDMI – cable',
        'date': '23 Jan 2025'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFF00A7A7),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final note = notifications[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: note['color'].withAlpha(38),
                  child: Icon(note['icon'], color: note['color']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(note['message'],
                          style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(note['date'],
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF00A7A7),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner), label: "Scan"),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Logout"),
        ],
      ),
    );
  }
}
