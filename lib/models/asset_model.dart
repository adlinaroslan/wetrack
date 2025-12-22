import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Asset {
  final String docId;
  final String id;
  final String serialNumber;
  final String name;
  final String brand;
  final String category;
  final String imageUrl; // REQUIRED
  final String location;
  final String status;
  final String? registerDate;
  final String? borrowedByUserId;
  final DateTime? dueDateTime;
  final DateTime? borrowDate; // <--- NEW: For history tracking
  final DateTime? returnDate; // <--- NEW: For history tracking

  Asset({
    required this.docId,
    required this.id,
    required this.serialNumber,
    required this.name,
    required this.brand,
    required this.category,
    required this.imageUrl,
    required this.location,
    required this.status,
    this.registerDate,
    this.borrowedByUserId,
    this.dueDateTime,
    this.borrowDate,
    this.returnDate,
  });

  // ============================
  // Firestore → Asset
  // ============================
  factory Asset.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Asset data is null for docId: ${doc.id}");
    }

    String? parseRegisterDate(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Timestamp) {
        return DateFormat("dd MMM yyyy").format(value.toDate());
      }
      return null;
    }

    // 🔴 HARD FAIL IF IMAGE MISSING (GOOD!)
    final imageUrl = data['imageUrl'];
    if (imageUrl == null || imageUrl.toString().isEmpty) {
      throw Exception("Asset ${doc.id} has no imageUrl saved");
    }

    return Asset(
      docId: doc.id,
      id: data['id'] ?? doc.id,
      serialNumber: data['serialNumber'] ?? '-',
      name: data['name'] ?? 'Unknown',
      brand: data['brand'] ?? 'Unknown',
      category: data['category'] ?? 'General',
      imageUrl: imageUrl,
      location: data['location'] ?? 'GO',
      status: data['status'] ?? 'In Stock',
      registerDate: parseRegisterDate(data['registerDate']),
      borrowedByUserId: data['borrowedByUserId'],
      dueDateTime: data['dueDateTime'] != null
          ? (data['dueDateTime'] as Timestamp).toDate()
          : null,
    );
  }

  // ============================
  // Asset → Firestore
  // ============================
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

  String get qrData => id;
}
