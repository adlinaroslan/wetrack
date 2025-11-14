import 'package:cloud_firestore/cloud_firestore.dart';

class Asset {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String imagePath;
  final String location;
  final String status;
  final String? registerDate; // kept as String to match existing UI usage
  final String? borrowedByUserId;
  final DateTime? dueDateTime;

  Asset({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    this.imagePath = 'assets/default.png',
    this.location = 'Available',
    required this.status,
    this.registerDate,
    this.borrowedByUserId,
    this.dueDateTime,
  });

  factory Asset.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data was null for Asset ID: ${doc.id}");
    }

    // registerDate in Firestore may be stored as a String or as a Timestamp.
    String? registerDateStr;
    final reg = data['registerDate'];
    if (reg is String) {
      registerDateStr = reg;
    } else if (reg is Timestamp) {
      registerDateStr = reg.toDate().toIso8601String();
    }

    return Asset(
      id: data['assetId'] as String? ?? doc.id,
      name: data['name'] as String? ?? 'Unknown Asset',
      brand: (data['brand'] as String?) ??
          (data['manufacturer'] as String?) ??
          'Unknown',
      category: data['category'] as String? ?? 'General',
      imagePath: data['imagePath'] as String? ?? 'assets/default.png',
      location: data['location'] as String? ?? 'Available',
      status: data['status'] as String? ?? 'AVAILABLE',
      registerDate: registerDateStr,
      borrowedByUserId: data['borrowedByUserId'] as String?,
      dueDateTime: (data['dueDateTime'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'assetId': id,
      'name': name,
      'brand': brand,
      'category': category,
      'imagePath': imagePath,
      'location': location,
      'status': status,
      'registerDate': registerDate,
      'borrowedByUserId': borrowedByUserId,
      'dueDateTime':
          dueDateTime is DateTime ? Timestamp.fromDate(dueDateTime!) : null,
    };
  }
}
