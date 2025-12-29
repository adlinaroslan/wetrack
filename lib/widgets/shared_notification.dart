import 'package:flutter/material.dart';
import 'package:wetrack/models/notification_model.dart';

class NotificationList extends StatelessWidget {
  final Stream<List<NotificationModel>> stream;
  final Function(String) onMarkRead;

  const NotificationList({
    super.key,
    required this.stream,
    required this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NotificationModel>>(
      stream: stream,
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
          padding: const EdgeInsets.all(16.0),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final n = notifications[index];
            final isRead = n.read;

            // Type mapping
            Color color;
            IconData icon;
            switch (n.type) {
              case 'request_approved':
                color = Colors.green;
                icon = Icons.check_circle;
                break;
              case 'request_declined':
                color = Colors.redAccent;
                icon = Icons.cancel;
                break;
              case 'asset_damage':
                color = Colors.orange;
                icon = Icons.build;
                break;
              case 'asset_added':
                color = Colors.blue;
                icon = Icons.add_box;
                break;
              case 'deadline_reminder':
                color = Colors.purple;
                icon = Icons.access_time;
                break;
              case 'return_confirmed':
                color = Colors.teal;
                icon = Icons.assignment_return;
                break;
              default:
                color = Colors.grey;
                icon = Icons.info;
            }

            return Card(
              elevation: isRead ? 0.5 : 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: isRead ? null : () => onMarkRead(n.id),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: color.withOpacity(isRead ? 0.05 : 0.1),
                  child: Icon(icon, color: isRead ? Colors.grey : color),
                ),
                title: Text(
                  n.title,
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    color: isRead ? Colors.grey[700] : const Color(0xFF004C5C),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: isRead ? Colors.grey : Colors.black87),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        n.timestamp.toLocal().toString().split('.').first,
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ),
                  ],
                ),
                trailing: isRead
                    ? null
                    : const Icon(Icons.circle, color: Colors.blue, size: 10),
              ),
            );
          },
        );
      },
    );
  }
}
