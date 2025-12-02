import 'package:cloud_firestore/cloud_firestore.dart';

class AssetRequest {
  final String id;
  final String userId;
  final String userName;
  final String assetId;
  final String assetName;
  final DateTime requestedDate;
  final DateTime requiredDate;
  final String status; // 'PENDING', 'APPROVED', 'REJECTED'

  // ✅ ADDED: Field to hold the due date (set upon approval)
  final Timestamp? dueDateTime;

  AssetRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.assetId,
    required this.assetName,
    required this.requestedDate,
    required this.requiredDate,
    required this.status,
    // ✅ ADDED: Include in the constructor
    this.dueDateTime,
  });

  // Factory constructor to create a Request from a Firestore document
  factory AssetRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data was null for Request ID: ${doc.id}");
    }

    return AssetRequest(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Unknown User',
      assetId: data['assetId'] as String? ?? '',
      assetName: data['assetName'] as String? ?? 'Unknown Asset',
      requestedDate:
          (data['requestedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      requiredDate: (data['requiredDate'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 7)),
      status: data['status'] as String? ?? 'PENDING',

      // ✅ ADDED: Safely read the new dueDateTime field (it will be null until approved)
      dueDateTime: data['dueDateTime'] as Timestamp?,
    );
  }

  // Convert AssetRequest object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'assetId': assetId,
      'assetName': assetName,
      // NOTE: We generally store DateTimes as Timestamp in Firestore:
      'requestedDate': Timestamp.fromDate(requestedDate),
      'requiredDate': Timestamp.fromDate(requiredDate),
      'status': status,

      // ✅ ADDED: Write the dueDateTime field (will be null initially)
      'dueDateTime': dueDateTime,
    };
  }
}
