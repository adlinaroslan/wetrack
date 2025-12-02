import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wetrack/services/firestore_service.dart';

class UserNotificationPage extends StatelessWidget {
  const UserNotificationPage({super.key});

  // Function to mark the notification as read
  Future<void> _markAsRead(String notificationId) async {
    try {
      // Accessing the singleton instance correctly
      await FirestoreService().markNotificationAsRead(notificationId);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current user ID
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF9F9),
      // --- APP BAR (Unchanged) ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
      ),

      // --- BODY: REAL-TIME DATA ---
      body: user == null
          ? const Center(child: Text("Please login"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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

                final notifications = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final doc = notifications[index];

                    // FIX HERE: Safely cast data to Map<String, dynamic> and handle null
                    final Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>? ?? {};

                    final String notificationId = doc.id;
                    final bool isRead = data['read'] ?? false;

                    // --- Updated Type Mapping Logic ---
                    final String type = data['type'] ?? 'info';
                    Color color;
                    IconData icon;

                    if (type == 'request_approved') {
                      color = Colors.green;
                      icon = Icons.check_circle;
                    } else if (type == 'request_declined') {
                      color = Colors.redAccent;
                      icon = Icons.cancel;
                    } else {
                      color = Colors.orange;
                      icon = Icons.info;
                    }

                    return Card(
                      elevation: isRead ? 0.5 : 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap:
                            isRead ? null : () => _markAsRead(notificationId),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor:
                              color.withOpacity(isRead ? 0.05 : 0.1),
                          child:
                              Icon(icon, color: isRead ? Colors.grey : color),
                        ),
                        title: Text(
                          data['title'] ?? 'Notification',
                          style: TextStyle(
                            fontWeight:
                                isRead ? FontWeight.normal : FontWeight.bold,
                            color: isRead
                                ? Colors.grey[700]
                                : const Color(0xFF004C5C),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['message'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: isRead ? Colors.grey : Colors.black87),
                            ),
                            if (data['timestamp'] is Timestamp)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  (data['timestamp'] as Timestamp)
                                      .toDate()
                                      .toLocal()
                                      .toString()
                                      .split('.')
                                      .first,
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey[500]),
                                ),
                              ),
                          ],
                        ),
                        trailing: isRead
                            ? null
                            : const Icon(Icons.circle,
                                color: Colors.blue, size: 10),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
