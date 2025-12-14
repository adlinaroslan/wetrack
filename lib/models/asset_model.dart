import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
  final DateTime? borrowDate; // <--- NEW: For history tracking
  final DateTime? returnDate; // <--- NEW: For history tracking

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
    this.borrowDate,
    this.returnDate,
  });

  /// Convert Firestore document → Asset object
  factory Asset.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data was null for Asset docId: ${doc.id}");
    }

    String? _getRegisterDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is String) {
        return dateValue;
      } else if (dateValue is Timestamp) {
        return DateFormat("dd MMM yyyy").format(dateValue.toDate());
      }
      return null;
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
      registerDate: _getRegisterDate(data['registerDate']),
      borrowedByUserId: data['borrowedByUserId'],
      dueDateTime: data['dueDateTime'] != null
          ? (data['dueDateTime'] as Timestamp).toDate()
          : null,

      // MAPPING NEW FIELDS
      borrowDate: data['borrowDate'] != null
          ? (data['borrowDate'] as Timestamp).toDate()
          : null,
      returnDate: data['returnDate'] != null
          ? (data['returnDate'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert Asset → Firestore Map
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
      'borrowDate':
          borrowDate != null ? Timestamp.fromDate(borrowDate!) : null, // NEW
      'returnDate':
          returnDate != null ? Timestamp.fromDate(returnDate!) : null, // NEW
    };
  }

  /// Convert Asset → JSON (for QR Code)
  Map<String, dynamic> toJson() {
    return {
      'docId': docId,
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
      'dueDateTime': dueDateTime?.toIso8601String(),
      'borrowDate': borrowDate?.toIso8601String(), // NEW
      'returnDate': returnDate?.toIso8601String(), // NEW
    };
  }

  String get qrData => id;
}
