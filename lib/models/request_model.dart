import 'package:cloud_firestore/cloud_firestore.dart';

class AssetRequest {
  final String id;
  final String userId;
  final String userName;
  final String assetId;
  final String assetName;
  final DateTime requestedDate;
  final DateTime requiredDate;
  final String status;

  // Field to hold the asset's due date (set upon approval)
  final Timestamp? dueDateTime;

  // 💡 NEW FIELDS: Fields needed for history tracking
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime? returnedAt;

  AssetRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.assetId,
    required this.assetName,
    required this.requestedDate,
    required this.requiredDate,
    required this.status,
    this.dueDateTime,
    // 💡 NEW: Include in constructor
    this.approvedAt,
    this.rejectedAt,
    this.returnedAt,
  });

  // Factory constructor to create a Request from a Firestore document
  factory AssetRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data was null for Request ID: ${doc.id}");
    }

    // Helper to safely convert Timestamp to DateTime
    DateTime? _toDateTime(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      return null;
    }

    return AssetRequest(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Unknown User',
      assetId: data['assetId'] as String? ?? '',
      assetName: data['assetName'] as String? ?? 'Unknown Asset',
      requestedDate: _toDateTime(data['requestedDate']) ?? DateTime.now(),
      requiredDate: _toDateTime(data['requiredDate']) ??
          DateTime.now().add(const Duration(days: 7)),
      status: data['status'] as String? ?? 'PENDING',

      dueDateTime: data['dueDateTime'] as Timestamp?,

      // 💡 NEW MAPPING: Map the history timestamps
      approvedAt: _toDateTime(data['approvedAt']),
      rejectedAt: _toDateTime(data['rejectedAt']),
      returnedAt: _toDateTime(data['returnedAt']),
    );
  }

  // Convert AssetRequest object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    // Helper to safely convert DateTime to Timestamp for writing
    Timestamp? _toTimestamp(DateTime? date) {
      if (date != null) {
        return Timestamp.fromDate(date);
      }
      return null;
    }

    return {
      'userId': userId,
      'userName': userName,
      'assetId': assetId,
      'assetName': assetName,
      'requestedDate': Timestamp.fromDate(requestedDate),
      'requiredDate': Timestamp.fromDate(requiredDate),
      'status': status,
      'dueDateTime': dueDateTime,

      // 💡 NEW WRITING: Write the history timestamps
      'approvedAt': _toTimestamp(approvedAt),
      'rejectedAt': _toTimestamp(rejectedAt),
      'returnedAt': _toTimestamp(returnedAt),
    };
  }
}
