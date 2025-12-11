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

  /// Firestore → Asset
  factory Asset.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data was null for Asset docId: ${doc.id}");
    }

    String? _getRegisterDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is String) return dateValue;
      if (dateValue is Timestamp) return DateFormat("dd MMM yyyy").format(dateValue.toDate());
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
      dueDateTime: data['dueDateTime'] != null ? (data['dueDateTime'] as Timestamp).toDate() : null,
    );
  }

  /// Asset → Firestore Map
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
      'dueDateTime': dueDateTime != null ? Timestamp.fromDate(dueDateTime!) : null,
    };
  }

  /// Asset → JSON (for QR Code)
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

  /// QR-friendly string
  String get qrData => id;

  /// Optional: copyWith for future use
  Asset copyWith({
    String? docId,
    String? id,
    String? serialNumber,
    String? name,
    String? brand,
    String? category,
    String? imageUrl,
    String? location,
    String? status,
    String? registerDate,
    String? borrowedByUserId,
    DateTime? dueDateTime,
  }) {
    return Asset(
      docId: docId ?? this.docId,
      id: id ?? this.id,
      serialNumber: serialNumber ?? this.serialNumber,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      status: status ?? this.status,
      registerDate: registerDate ?? this.registerDate,
      borrowedByUserId: borrowedByUserId ?? this.borrowedByUserId,
      dueDateTime: dueDateTime ?? this.dueDateTime,
    );
  }
}
