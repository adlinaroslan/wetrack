// lib/pages/user/user_my_request_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wetrack/services/firestore_service.dart';
import '../../models/request_model.dart';

class UserMyRequestPage extends StatelessWidget {
  const UserMyRequestPage({super.key});

  // Helper function returning proper label + color
  Map<String, dynamic> _getStatusVisuals(String status) {
    final normalized = status.toUpperCase();

    switch (normalized) {
      case 'APPROVED':
        return {
          'text': 'Approved ✅',
          'color': Colors.green,
          'normalized': normalized
        };
      case 'DECLINED':
        return {
          'text': 'Declined ❌',
          'color': Colors.red,
          'normalized': normalized
        };
      case 'COMPLETED':
        return {
          'text': 'Completed',
          'color': Colors.blueGrey,
          'normalized': normalized
        };
      case 'PENDING':
      default:
        return {
          'text': 'Pending ⏳',
          'color': Colors.orange,
          'normalized': normalized
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF9F9),

      // ------------------- APP BAR -------------------
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
                      'My Asset Requests',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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

      // ------------------- BODY -------------------
      body: currentUserId == null
          ? const Center(child: Text("User not logged in."))
          : StreamBuilder<List<AssetRequest>>(
              stream: FirestoreService().getRequestsForUser(currentUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error fetching requests: ${snapshot.error}"),
                  );
                }

                final requests = snapshot.data ?? [];

                if (requests.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          "You have no pending asset requests.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    final visuals = _getStatusVisuals(request.status);
                    final normalizedStatus = visuals['normalized'];

                    // Pick icon based on status
                    IconData icon;
                    if (normalizedStatus == 'APPROVED' ||
                        normalizedStatus == 'COMPLETED') {
                      icon = Icons.check_circle_outline;
                    } else if (normalizedStatus == 'DECLINED') {
                      icon = Icons.cancel_outlined;
                    } else {
                      icon = Icons.access_time;
                    }

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: visuals['color'].withOpacity(0.1),
                          child: Icon(
                            icon,
                            color: visuals['color'],
                          ),
                        ),
                        title: Text(
                          request.assetName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF004C5C),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),

                            // Show due date ONLY if approved
                            if (normalizedStatus == 'APPROVED' &&
                                request.dueDateTime != null)
                              Text(
                                'Due Date: ${request.dueDateTime!.toDate().toLocal().toString().split(' ')[0]}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                            Text(
                                'Required by: ${request.requiredDate.toLocal().toString().split(' ')[0]}'),
                            Text(
                                'Requested on: ${request.requestedDate.toLocal().toString().split(' ')[0]}'),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: visuals['color'].withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            visuals['text'],
                            style: TextStyle(
                              color: visuals['color'],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
