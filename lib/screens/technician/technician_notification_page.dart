import 'package:flutter/material.dart';
import 'package:wetrack/services/firestore_service.dart';
import 'package:wetrack/models/notification_model.dart';
import '../../widgets/footer_nav.dart';

class TechnicianNotificationPage extends StatelessWidget {
  const TechnicianNotificationPage({super.key});

  Future<void> _markAsRead(String id) async {
    await FirestoreService().markNotificationAsRead(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
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
      body: StreamBuilder<List<NotificationModel>>(
        stream: FirestoreService().getTechnicianNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No notifications yet",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final note = notifications[index];

              Color color;
              IconData icon;

              switch (note.type) {
                case 'asset_damage':
                  color = Colors.red;
                  icon = Icons.error;
                  break;
                case 'asset_added':
                  color = Colors.blue;
                  icon = Icons.qr_code_2;
                  break;
                case 'request_approved':
                  color = Colors.green;
                  icon = Icons.check_circle;
                  break;
                default:
                  color = Colors.orange;
                  icon = Icons.info;
              }

              return GestureDetector(
                onTap: note.read ? null : () => _markAsRead(note.id),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: note.read ? Colors.grey.shade100 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: color.withOpacity(0.15),
                        child: Icon(icon, color: color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.message,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: note.read
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              note.timestamp
                                  .toLocal()
                                  .toString()
                                  .split('.')
                                  .first,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      if (!note.read)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child:
                              Icon(Icons.circle, size: 10, color: Colors.red),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const FooterNav(),
    );
  }
}
