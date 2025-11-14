import 'package:cloud_firestore/cloud_firestore.dart';

class Asset {
  final String id;
  final String name;
  final String category;
  final String location;
  final String status; // e.g., 'AVAILABLE', 'BORROWED', 'PENDING_RETURN'
  final String? borrowedByUserId;
  final DateTime? dueDateTime;

  Asset({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.status,
    this.borrowedByUserId,
    this.dueDateTime,
  });

  // Factory constructor to create an Asset from a Firestore document
  factory Asset.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data was null for Asset ID: ${doc.id}");
    }

    return Asset(
      id: data['assetId'] as String? ??
          doc.id, // Try assetId field first, fallback to doc ID
      name: data['name'] as String? ?? 'Unknown Asset',
      category: data['category'] as String? ?? 'General',
      location: data['location'] as String? ??
          'Available', // Default location if not provided
      status: data['status'] as String? ?? 'AVAILABLE',
      borrowedByUserId: data['borrowedByUserId'] as String?,
      dueDateTime: (data['dueDateTime'] as Timestamp?)?.toDate(),
    );
  }

  // Convert Asset object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'location': location,
      'status': status,
      'borrowedByUserId': borrowedByUserId,
      'dueDateTime': dueDateTime,
    };
  }
}
