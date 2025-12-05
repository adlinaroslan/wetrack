import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/asset_model.dart';
import '../models/request_model.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Singleton Instance
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  // ---------------------- COLLECTION REFERENCES ----------------------

  CollectionReference<Asset> get assetsRef =>
      _db.collection('assets').withConverter<Asset>(
            fromFirestore: (snapshot, _) => Asset.fromFirestore(snapshot),
            toFirestore: (asset, _) => asset.toFirestore(),
          );

  CollectionReference<AssetRequest> get requestsRef =>
      _db.collection('requests').withConverter<AssetRequest>(
            fromFirestore: (snapshot, _) =>
                AssetRequest.fromFirestore(snapshot),
            toFirestore: (request, _) => request.toFirestore(),
          );

  CollectionReference<UserModel> get usersRef =>
      _db.collection('users').withConverter<UserModel>(
            fromFirestore: (snapshot, _) => UserModel.fromFirestore(snapshot),
            toFirestore: (user, _) => user.toFirestore(),
          );

  // ---------------------- USER PROFILE ----------------------

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await usersRef.doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
    String role = 'User',
  }) async {
    final newUser = UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      role: role,
      createdAt: DateTime.now(),
    );
    await usersRef.doc(uid).set(newUser);
  }

  // ---------------------- ASSET STREAMS ----------------------

  Stream<List<Asset>> getAvailableAssets() {
    return assetsRef
        // 🚀 CHANGE: Filter for 'In Stock', which is the admin's default
        .where('status', isEqualTo: 'In Stock')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Stream<List<Asset>> getBorrowedAssets(String userId) {
    return assetsRef
        .where('status', isEqualTo: 'BORROWED')
        .where('borrowedByUserId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  // 🌟 NEW METHOD: Fetch single asset by ID (from QR scan)
  /// Fetches a single Asset document from the 'assets' collection by its ID.
  Future<Asset?> getAssetById(String assetId) async {
    try {
      final docSnapshot = await assetsRef.doc(assetId).get();

      // Use docSnapshot.data() which already returns the converted Asset object
      return docSnapshot.exists ? docSnapshot.data() : null;
    } catch (e) {
      debugPrint('Error fetching asset by ID $assetId: $e');
      return null;
    }
  }
  // ---------------------- REQUEST STREAMS ----------------------

  Stream<List<AssetRequest>> getRequestsForUser(String userId) {
    return requestsRef
        .where('userId', isEqualTo: userId)
        .orderBy('requestedDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Stream<List<AssetRequest>> getAllRequests() {
    return requestsRef
        .orderBy('requestedDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  // ---------------------- CREATE REQUEST ----------------------

  Future<void> requestAsset({
    required String assetId,
    required String assetName,
    required DateTime requiredDate,
    required String userId,
    required String userName,
  }) async {
    final newRequest = AssetRequest(
      id: '',
      userId: userId,
      userName: userName,
      assetId: assetId,
      assetName: assetName,
      requestedDate: DateTime.now(),
      requiredDate: requiredDate,
      status: 'PENDING',
    );

    await requestsRef.add(newRequest);
    await assetsRef.doc(assetId).update({'status': 'PENDING_REQUEST'});
  }

  // ---------------------- APPROVE REQUEST ----------------------

  Future<void> approveRequest({
    required String requestId,
    required String assetId,
    required String borrowerUserId,
    required DateTime dueDate,
  }) async {
    final requestDoc = requestsRef.doc(requestId);
    final assetDoc = assetsRef.doc(assetId);

    // Fetch the asset name for notification
    final assetSnap = await assetDoc.get();
    final assetName = assetSnap.data()?.name ?? 'Asset';

    await _db.runTransaction((transaction) async {
      final reqSnap = await transaction.get(requestDoc);
      if (!reqSnap.exists) throw Exception('Request not found');

      // Update request
      transaction.update(requestDoc, {
        'status': 'APPROVED',
        'approvedAt': FieldValue.serverTimestamp(),
      });

      // Update asset
      transaction.update(assetDoc, {
        'status': 'BORROWED',
        'borrowedByUserId': borrowerUserId,
        'dueDateTime': Timestamp.fromDate(dueDate),
        'location': 'With User',
      });

      // History
      _db.collection('asset_history').add({
        'assetId': assetId,
        'action': 'BORROWED',
        'byUserId': borrowerUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'dueDateTime': Timestamp.fromDate(dueDate),
      });

      // NOTIFICATION: Request Approved
      _db.collection('notifications').doc().set({
        'userId': borrowerUserId,
        'title': 'Request Approved ✅',
        'message':
            'Your request for **$assetName** (ID: $assetId) has been approved.\nDue Date: ${dueDate.toLocal().toString().split(" ").first}',
        'type': 'request_approved',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'relatedId': requestId,
      });
    });
  }

  // ---------------------- DECLINE REQUEST ----------------------

  Future<void> declineRequest({
    required String requestId,
    required String assetId,
    required String borrowerUserId,
  }) async {
    final requestDoc = requestsRef.doc(requestId);
    final assetDoc = assetsRef.doc(assetId);

    final assetSnap = await assetDoc.get();
    final assetName = assetSnap.data()?.name ?? 'Asset';

    await _db.runTransaction((transaction) async {
      final reqSnap = await transaction.get(requestDoc);
      if (!reqSnap.exists) throw Exception('Request not found');

      transaction.update(
        requestDoc,
        {'status': 'DECLINED', 'rejectedAt': FieldValue.serverTimestamp()},
      );

      final assetSnapInside = await transaction.get(assetDoc);
      final assetObj = assetSnapInside.data();
      final currentStatus = assetObj?.status ?? '';

      if (currentStatus == 'PENDING_REQUEST') {
        transaction.update(assetDoc, {'status': 'AVAILABLE'});
      }

      // NOTIFICATION: Request Declined
      _db.collection('notifications').doc().set({
        'userId': borrowerUserId,
        'title': 'Request Declined ❌',
        'message':
            'Your request for **$assetName** (ID: $assetId) was declined by the administrator.',
        'type': 'request_declined',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'relatedId': requestId,
      });
    });
  }

  // ---------------------- UPDATE REQUEST ----------------------

  Future<void> updateRequest(
      String requestId, Map<String, dynamic> updates) async {
    await requestsRef.doc(requestId).update(updates);
  }

  // ---------------------- CONFIRM RETURN ----------------------

  Future<void> confirmReturn({
    required String assetId,
    required String condition,
    String? requestId,
    String? comments,
  }) async {
    final assetDocRef = assetsRef.doc(assetId);

    await _db.runTransaction((transaction) async {
      final snap = await transaction.get(assetDocRef);
      if (!snap.exists) throw Exception("Asset not found");

      final asset = snap.data();
      final borrowerId = asset?.borrowedByUserId ?? 'N/A';

      // ✅ Update Asset Status back to AVAILABLE
      transaction.update(assetDocRef, {
        'status': 'AVAILABLE',
        'borrowedByUserId': FieldValue.delete(),
        'dueDateTime': FieldValue.delete(),
        'location': 'Storage',
      });

      // ✅ Update request status if requestId is provided
      if (requestId != null && requestId.isNotEmpty) {
        final requestDocRef = requestsRef.doc(requestId);
        transaction.update(requestDocRef, {
          'status': 'RETURNED',
          'returnedAt': FieldValue.serverTimestamp(),
        });
      }

      // ✅ Add to history
      _db.collection('asset_history').add({
        'assetId': assetId,
        'action': 'RETURNED',
        'condition': condition,
        'comments': comments,
        'returnedByUserId': borrowerId,
        'requestId': requestId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  // ---------------------- NOTIFICATIONS ----------------------

  /// Stream notifications for a specific user
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({
      'read': true,
    });
  }
}
