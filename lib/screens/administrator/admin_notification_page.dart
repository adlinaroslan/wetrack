import 'package:flutter/material.dart';
import 'package:wetrack/services/firestore_service.dart';
import 'package:wetrack/widgets/notification_list.dart';
import '../../widgets/footer_nav.dart';

class AdminNotificationPage extends StatelessWidget {
  const AdminNotificationPage({super.key});

  Future<void> _markAsRead(String id) async {
    await FirestoreService().markNotificationAsRead(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Notifications"),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications),
          ),
        ],
      ),

      // ✅ Use the shared NotificationList widget
      body: NotificationList(
        stream: FirestoreService().getAdminNotifications(),
        onMarkRead: _markAsRead,
      ),

      bottomNavigationBar: const FooterNav(),
    );
  }
}
