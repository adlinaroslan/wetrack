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

  CollectionReference<Map<String, dynamic>> get assetHistoryRef =>
      _db.collection('asset_history');

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

  // ---------------------- ASSET STREAMS (User History) ----------------------

  /// Fetches a stream of assets that are currently marked as 'In Stock' in the database.
  Stream<List<Asset>> getAvailableAssets() {
    return assetsRef
        .where('status', isEqualTo: 'In Stock')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  /// Fetches a stream of assets currently borrowed by the specified user (for 'Ongoing' tab).
  Stream<List<Asset>> getBorrowedAssets(String userId) {
    // Looks for assets marked as 'BORROWED' and assigned to the user.
    return assetsRef
        .where('status', isEqualTo: 'BORROWED')
        .where('borrowedByUserId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  /// 🌟 NEW: Fetches history requests and links them to Asset data.
  /// Used for 'Returned' and 'Declined' tabs.
  Stream<List<Asset>> getHistoryByStatusAndUser(
      String userId, String statusFilter) {
    // 1. Stream the REQUESTS with the target final status for the user.
    return requestsRef
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: statusFilter) // 'RETURNED' or 'DECLINED'
        .orderBy('requestedDate', descending: true)
        .snapshots()
        .asyncMap((requestSnap) async {
      if (requestSnap.docs.isEmpty) {
        return [];
      }

      // 2. Extract asset IDs for batch fetching
      final assetIds =
          requestSnap.docs.map((d) => d.data().assetId).toSet().toList();

      // 3. Batch fetch the full Asset data using whereIn (Handles up to 10 IDs)
      final List<Asset> historyAssets = [];
      if (assetIds.isNotEmpty) {
        // You may need to batch this if assetIds is > 10, but a simple list is used here for brevity
        final assetSnap = await assetsRef
            .where(FieldPath.documentId, whereIn: assetIds)
            .get();
        final Map<String, Asset> assetMap = {
          for (var doc in assetSnap.docs) doc.id: doc.data()
        };

        // 4. Synthesize the final list for the UI
        for (var reqDoc in requestSnap.docs) {
          final request = reqDoc.data();
          final asset = assetMap[request.assetId];

          if (asset != null) {
            // Recreate the Asset object, providing history dates from the Request
            historyAssets.add(Asset(
              docId: asset.docId,
              id: asset.id,
              serialNumber: asset.serialNumber,
              name: asset.name,
              brand: asset.brand,
              category: asset.category,
              imageUrl: asset.imageUrl,
              location: asset.location,
              status: statusFilter,
              registerDate: asset.registerDate,
              borrowedByUserId: userId,
              dueDateTime: null, // Not relevant for history views

              // Use request data to fill the history timeline fields
              borrowDate: request.approvedAt ??
                  request.requestedDate, // Start date of transaction
              returnDate: request
                  .returnedAt, // End date (only set for 'RETURNED' status)
            ));
          }
        }
      }

      return historyAssets;
    });
  }

  /// 🌟 MISSING METHOD ADDED: Fetches a single Asset document by its ID (from QR scan).
  Future<Asset?> getAssetById(String assetId) async {
    try {
      final docSnapshot = await assetsRef.doc(assetId).get();
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
      // Read both request and asset first (required by Firestore transactions)
      final reqSnap = await transaction.get(requestDoc);
      if (!reqSnap.exists) throw Exception('Request not found');

      final assetSnapInside = await transaction.get(assetDoc);
      final assetObj = assetSnapInside.data();
      final currentStatus = assetObj?.status ?? '';

      // Now perform writes
      transaction.update(
        requestDoc,
        {'status': 'DECLINED', 'rejectedAt': FieldValue.serverTimestamp()},
      );

      if (currentStatus == 'PENDING_REQUEST') {
        transaction.update(assetDoc, {'status': 'In Stock'});
      }
    });

    // NOTIFICATION: Request Declined (outside transaction)
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

    // If requestId not provided, find the active request for this asset
    String? actualRequestId = requestId;
    if (actualRequestId == null || actualRequestId.isEmpty) {
      try {
        final activeRequest = await requestsRef
            .where('assetId', isEqualTo: assetId)
            .where('status', isEqualTo: 'APPROVED')
            .limit(1)
            .get();
        if (activeRequest.docs.isNotEmpty) {
          actualRequestId = activeRequest.docs.first.id;
        }
      } catch (_) {
        // If query fails, proceed without updating request
      }
    }

    await _db.runTransaction((transaction) async {
      final snap = await transaction.get(assetDocRef);
      if (!snap.exists) throw Exception("Asset not found");

      final asset = snap.data();
      final borrowerId = asset?.borrowedByUserId ?? 'N/A';

      // ✅ Update Asset Status back to In Stock
      transaction.update(assetDocRef, {
        'status': 'In Stock',
        'borrowedByUserId': FieldValue.delete(),
        'dueDateTime': FieldValue.delete(),
        'location': 'Storage',
      });

      // ✅ Update request status if we found the requestId
      if (actualRequestId != null && actualRequestId.isNotEmpty) {
        final requestDocRef = requestsRef.doc(actualRequestId);
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
        'requestId': actualRequestId,
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
