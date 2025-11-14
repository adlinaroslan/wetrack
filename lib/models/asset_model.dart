import 'package:cloud_firestore/cloud_firestore.dart';

class Asset {
  final String id;
  final String name;
  final String category;
  final String location;
  final String status; 
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

  factory Asset.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data was null for Asset ID: ${doc.id}");
    }

    return Asset(
      id: data['assetId'] as String? ?? doc.id,
      name: data['name'] as String? ?? 'Unknown Asset',
      category: data['category'] as String? ?? 'General',
      location: data['location'] as String? ?? 'Available',
      status: data['status'] as String? ?? 'AVAILABLE',
      borrowedByUserId: data['borrowedByUserId'] as String?,
      dueDateTime: (data['dueDateTime'] as Timestamp?)?.toDate(),
    );
  }

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
