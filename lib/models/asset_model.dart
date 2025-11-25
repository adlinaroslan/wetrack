import 'package:cloud_firestore/cloud_firestore.dart';

class Asset {
  final String docId;
  final String id;
  final String serialNumber;
  final String name;
  final String brand;
  final String category;
  final String imageUrl;
  final String location;
  final String status;
  final String? registerDate;
  final String? borrowedByUserId;
  final DateTime? dueDateTime;

  Asset({
    required this.docId,
    required this.id,
    required this.serialNumber,
    required this.name,
    required this.brand,
    required this.category,
    this.imageUrl = 'assets/default.png',
    this.location = 'Available',
    required this.status,
    this.registerDate,
    this.borrowedByUserId,
    this.dueDateTime,
  });

  factory Asset.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data was null for Asset docId: ${doc.id}");
    }

    return Asset(
      docId: doc.id,
      id: data['id'] ?? doc.id,
      serialNumber: data['serialNumber'] ?? '-',
      name: data['name'] ?? 'Unknown',
      brand: data['brand'] ?? 'Unknown',
      category: data['category'] ?? 'General',
      imageUrl: data['imageUrl'] ?? 'assets/default.png',
      location: data['location'] ?? 'Available',
      status: data['status'] ?? 'Active',
      registerDate: data['registerDate'],
      borrowedByUserId: data['borrowedByUserId'],
      dueDateTime: data['dueDateTime'] != null
          ? (data['dueDateTime'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'serialNumber': serialNumber,
      'name': name,
      'brand': brand,
      'category': category,
      'imageUrl': imageUrl,
      'location': location,
      'status': status,
      'registerDate': registerDate,
      'borrowedByUserId': borrowedByUserId,
      'dueDateTime':
          dueDateTime != null ? Timestamp.fromDate(dueDateTime!) : null,
    };
  }
}
