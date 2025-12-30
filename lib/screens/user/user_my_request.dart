import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wetrack/services/firestore_service.dart';
import '../../models/request_model.dart';
import 'user_request_edit.dart';

class UserMyRequestPage extends StatelessWidget {
  const UserMyRequestPage({super.key});

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
      body: currentUserId == null
          ? const Center(child: Text("User not logged in."))
          : StreamBuilder<List<AssetRequest>>(
              stream: FirestoreService().getRequestsForUser(currentUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
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
                        Text("You have no asset requests.",
                            style: TextStyle(color: Colors.grey)),
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

                    IconData icon;
                    if (normalizedStatus == 'APPROVED' ||
                        normalizedStatus == 'COMPLETED') {
                      icon = Icons.check_circle_outline;
                    } else if (normalizedStatus == 'DECLINED') {
                      icon = Icons.cancel_outlined;
                    } else {
                      icon = Icons.access_time;
                    }

                    // 2. Wrap the Card in an InkWell for tap functionality
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        // 3. Navigate only if status is PENDING
                        onTap: normalizedStatus == 'PENDING'
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UserRequestEditPage(request: request),
                                  ),
                                );
                              }
                            : null, // Disable tap for non-pending requests
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          leading: CircleAvatar(
                            backgroundColor: visuals['color'].withOpacity(0.1),
                            child: Icon(icon, color: visuals['color']),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  request.assetName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF004C5C),
                                  ),
                                ),
                              ),
                              // 4. Show an edit icon if it's pending to hint it's clickable
                              if (normalizedStatus == 'PENDING')
                                const Icon(Icons.edit,
                                    size: 16, color: Colors.grey),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              if (normalizedStatus == 'APPROVED' &&
                                  request.dueDateTime != null)
                                Text(
                                  'Due Date: ${request.dueDateTime!.toDate().toLocal().toString().split(' ')[0]}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
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
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
