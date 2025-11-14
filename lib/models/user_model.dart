import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid; // Matches Firebase Auth User ID
  final String email;
  final String displayName;
  final String role; // e.g., 'User', 'Admin'
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role = 'User', // Default role is 'User'
    required this.createdAt,
  });

  // Factory constructor to create a UserModel from a Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data was null for User ID: ${doc.id}");
    }

    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? 'No Email',
      displayName: data['displayName'] as String? ?? 'New User',
      role: data['role'] as String? ?? 'User',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert UserModel object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'createdAt': createdAt,
    };
  }
}
