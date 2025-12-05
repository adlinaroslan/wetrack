import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 1. 💡 NEW: Import for date formatting

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
  final String? registerDate; // This must be a String?
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

  /// Convert Firestore document → Asset object
  factory Asset.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data was null for Asset docId: ${doc.id}");
    }

    // 2. 🚀 NEW HELPER FUNCTION: Safely handle registerDate field
    String? _getRegisterDate(dynamic dateValue) {
      if (dateValue == null) return null;

      if (dateValue is String) {
        return dateValue; // If it's a String, use it directly
      } else if (dateValue is Timestamp) {
        // If it's a Timestamp, convert it to a formatted String
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

      // 3. ✅ CORRECTED: Use the helper function to ensure it's a String
      registerDate: _getRegisterDate(data['registerDate']),

      borrowedByUserId: data['borrowedByUserId'],
      dueDateTime: data['dueDateTime'] != null
          ? (data['dueDateTime'] as Timestamp).toDate()
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
    };
  }

  /// QR-friendly string for QR Viewer
  String get qrData => id;
}
