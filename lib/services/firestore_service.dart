import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/asset_model.dart';
import '../models/request_model.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  // ---------------------- 🔧 MIGRATION: Fix missing borrowDate ----------------------

  /// Fixes borrowed assets that are missing the borrowDate field
  /// Call this once during app initialization to migrate existing data
  Future<void> fixMissingBorrowDates() async {
    try {
      final borrowedAssets = await _db
          .collection('assets')
          .where('status', isEqualTo: 'BORROWED')
          .get();

      for (var doc in borrowedAssets.docs) {
        if (doc['borrowDate'] == null) {
          // Set borrowDate to now (or approvedAt if available from requests)
          await doc.reference.update({
            'borrowDate': FieldValue.serverTimestamp(),
          });
          debugPrint('Fixed borrowDate for asset: ${doc.id}');
        }
      }
      debugPrint('Migration complete: All borrowed assets now have borrowDate');
    } catch (e) {
      debugPrint('Error in fixMissingBorrowDates: $e');
    }
  }

  /// Service requests created by technicians/admins when an asset needs service.
  /// Kept separate from `requests` (which are borrow requests).
  CollectionReference<Map<String, dynamic>> get serviceRequestsRef =>
      _db.collection('service_requests');

  /// Stream service requests filtered by status (e.g., 'On Progress', 'Fixed')
  Stream<List<Map<String, dynamic>>> getServiceRequestsByStatus(String status) {
    return serviceRequestsRef
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final m = Map<String, dynamic>.from(d.data());
              m['serviceId'] = d.id;
              return m;
            }).toList());
  }

  /// Stream assets with 'Service Needed' status that haven't been converted to service_requests yet
  Stream<List<Map<String, dynamic>>> getAssetsWithServiceNeeded() {
    return assetsRef
        .where('status', isEqualTo: 'Service Needed')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final asset = d.data().toFirestore();
              asset['assetDocId'] = d.id;
              asset['type'] = 'asset'; // Mark as asset, not service_request
              return asset;
            }).toList());
  }

  Future<Map<String, dynamic>?> getServiceRequestWithAsset(
      String serviceId) async {
    try {
      // 1. Fetch service request
      final serviceSnap = await serviceRequestsRef.doc(serviceId).get();
      if (!serviceSnap.exists) return null;

      final service = Map<String, dynamic>.from(serviceSnap.data()!);
      service['serviceId'] = serviceSnap.id;

      final assetId = service['assetId'];
      if (assetId == null) return service;

      // 2. Fetch asset
      final assetSnap = await assetsRef.doc(assetId).get();
      if (!assetSnap.exists) return service;

      final asset = assetSnap.data()!;

      // 3. Merge ONLY required fields
      service['assetDocId'] = asset.docId;
      service['assetId'] = asset.id;
      service['assetName'] = asset.name;
      service['serialNumber'] = asset.serialNumber;
      service['brand'] = asset.brand;
      service['category'] = asset.category;
      service['location'] = asset.location;

      return service;
    } catch (e) {
      debugPrint('Error fetching service detail: $e');
      return null;
    }
  }

  // ---------------------- USER PROFILE ----------------------

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await usersRef.doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<String?> getBorrowerName(String userId) async {
    try {
      final user = await getUserProfile(userId);
      return user?.displayName;
    } catch (e) {
      debugPrint('Error fetching borrower name: $e');
      return null;
    }
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

  Future<Asset?> getAssetById(String assetId) async {
    try {
      final docSnapshot = await assetsRef.doc(assetId).get();
      return docSnapshot.exists ? docSnapshot.data() : null;
    } catch (e) {
      debugPrint('Error fetching asset by ID $assetId: $e');
      return null;
    }
  }

  // (Your existing getHistoryByStatusAndUser code remains here - omitted for brevity)
  Stream<List<Asset>> getHistoryByStatusAndUser(
      String userId, String statusFilter) {
    // ... Keep your existing implementation ...
    return const Stream.empty(); // Placeholder to save space in this answer
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

  // ---------------------- 🌟 UPDATED: CREATE REQUEST ----------------------

  Future<void> requestAsset({
    required String assetId,
    required String assetName,
    required DateTime requiredDate,
    required String userId,
    required String userName,
  }) async {
    // 1. Create the request
    final newRequestRef = requestsRef.doc(); // Generate ID first
    final newRequest = AssetRequest(
      id: newRequestRef.id,
      userId: userId,
      userName: userName,
      assetId: assetId,
      assetName: assetName,
      requestedDate: DateTime.now(),
      requiredDate: requiredDate,
      status: 'PENDING',
    );

    await newRequestRef.set(newRequest);
    await assetsRef.doc(assetId).update({'status': 'PENDING_REQUEST'});

    // 2. 🌟 NOTIFICATION LOOP: Notify Admins
    await sendRoleNotification(
      role: 'Admin',
      title: "New Asset Request 📩",
      message: "$userName has requested: $assetName.",
      type: 'info',
      relatedId: newRequestRef.id,
    );

    // ✅ Optionally also notify Technicians
    await sendRoleNotification(
      role: 'Technician',
      title: "New Asset Request 📩",
      message: "$userName has requested: $assetName.",
      type: 'info',
      relatedId: newRequestRef.id,
    );
  }

  // ---------------------- APPROVE REQUEST ----------------------

  Future<void> approveRequest({
    required String requestId,
    required String assetId,
    required String borrowerUserId,
    required DateTime dueDate,
    required DateTime requestedDate, // 1. Add this parameter
  }) async {
    final requestDoc = requestsRef.doc(requestId);
    final assetDoc = assetsRef.doc(assetId);
    final assetSnap = await assetDoc.get();
    final assetName = assetSnap.data()?.name ?? 'Asset';

    await _db.runTransaction((transaction) async {
      final reqSnap = await transaction.get(requestDoc);
      if (!reqSnap.exists) throw Exception('Request not found');

      transaction.update(requestDoc, {
        'status': 'APPROVED',
        'approvedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(assetDoc, {
        'status': 'BORROWED',
        'borrowedByUserId': borrowerUserId,
        'dueDateTime': Timestamp.fromDate(dueDate),
        'borrowDate':
            Timestamp.fromDate(requestedDate), // 2. Use requestedDate here
        'location': 'With User',
      });

      _db.collection('asset_history').add({
        'assetId': assetId,
        'action': 'BORROWED',
        'byUserId': borrowerUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'dueDateTime': Timestamp.fromDate(dueDate),
        'borrowDate':
            Timestamp.fromDate(requestedDate), // 3. Keep history consistent
      });
    });

    // 🌟 NOTIFICATION: To User
    await sendUserNotification(
      toUserId: borrowerUserId,
      title: 'Request Approved ✅',
      message: 'Your request for **$assetName** has been approved.',
      type: 'request_approved',
      relatedId: requestId,
    );

    await sendRoleNotification(
      role: 'Technician',
      title: "Asset Added 🆕",
      message: "New asset registered: $assetName",
      type: 'asset_added',
      relatedId: assetId,
    );
  }
  // ---------------------- DECLINE REQUEST ----------------------

  Future<void> declineRequest({
    required String requestId,
    required String assetId,
    required String borrowerUserId,
  }) async {
    final requestDoc =
        requestsRef.doc(requestId); // withConverter<AssetRequest>
    final assetDoc = assetsRef.doc(assetId); // withConverter<Asset>

    // Get asset name up front (outside transaction OK)
    final assetSnap = await assetDoc.get();
    final assetName = assetSnap.data()?.name ?? 'Asset';

    // Get requestedDate from the model (NOT a map)
    final reqSnap = await requestDoc.get();
    final AssetRequest? reqModel = reqSnap.data();
    final DateTime? requestedDate = reqModel?.requestedDate;

    await _db.runTransaction((transaction) async {
      // Re-read inside transaction for consistency
      final reqSnapTx = await transaction.get(requestDoc);
      if (!reqSnapTx.exists) throw Exception('Request not found');

      final assetSnapTx = await transaction.get(assetDoc);
      final String currentStatus = assetSnapTx.data()?.status ?? '';

      // Update request → DECLINED
      transaction.update(requestDoc, {
        'status': 'DECLINED',
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      // If asset was in PENDING_REQUEST, restore to AVAILABLE
      if (currentStatus == 'PENDING_REQUEST') {
        transaction.update(assetDoc, {'status': 'In Stock'});
      }

      // Log DECLINED in asset_history with fallback borrowDate
      final historyRef = _db.collection('asset_history').doc();
      transaction.set(historyRef, {
        'assetId': assetId,
        'name': assetName,
        'action': 'DECLINED',
        'userId': borrowerUserId,
        'requestId': requestId,
        'borrowDate': requestedDate != null
            ? Timestamp.fromDate(requestedDate) // ✅ use model field
            : null,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });

    // Notify User
    await sendUserNotification(
      toUserId: borrowerUserId,
      title: 'Request Declined ❌',
      message: 'Your request for **$assetName** was declined.',
      type: 'request_declined',
      relatedId: requestId,
    );
  }

  // ---------------------- 🌟 NEW: EDIT REQUEST ----------------------

  Future<void> editRequest({
    required String requestId,
    required String assetName,
    required String userName,
    required DateTime newRequiredDate, // Contains date AND time
    String? newReason,
  }) async {
    try {
      // 1. Update the Request Document
      await _db.collection('requests').doc(requestId).update({
        'requiredDate': Timestamp.fromDate(newRequiredDate),
        'reason': newReason ?? '',
        // Optional: Add a flag so admins see it was edited
        'isEdited': true,
        'lastEditedAt': FieldValue.serverTimestamp(),
      });

      // 2. 🔔 NOTIFICATION LOOP: Alert Admins
      // (Reusing your existing admin fetch logic)
      final adminSnap = await _db
          .collection('users')
          .where('role', whereIn: ['Admin', 'Technician']).get();

      for (var doc in adminSnap.docs) {
        await sendRoleNotification(
          role: 'Admin',
          title: "Request Modified ✏️",
          message: "$userName changed the time/date for **$assetName**.",
          type: 'info',
          relatedId: requestId,
        );

        await sendRoleNotification(
          role: 'Technician',
          title: "Request Modified ✏️",
          message: "$userName changed the time/date for **$assetName**.",
          type: 'info',
          relatedId: requestId,
        );
      }
    } catch (e) {
      print("Error editing request: $e");
      rethrow;
    }
  }
  // ---------------------- 🌟 UPDATED: CONFIRM RETURN ----------------------

  Future<void> confirmReturn({
    required String assetId,
    required String condition,
    String? requestId,
    String? comments,
  }) async {
    final assetDocRef = _db.collection('assets').doc(assetId);
    final assetSnapshot = await assetDocRef.get();
    final assetData = assetSnapshot.data();

    final borrowerId = assetData?['borrowedByUserId'];
    final assetName = assetData?['name'] ?? 'Asset';
    final borrowDate = assetData?['borrowDate'];

    // 🌟 Fallback: get requestedDate from request if borrowDate is missing
    DateTime? fallbackBorrowDate;
    if ((borrowDate == null || borrowDate is! Timestamp) &&
        requestId != null &&
        requestId.isNotEmpty) {
      final requestSnap = await _db.collection('requests').doc(requestId).get();
      final requestedTimestamp = requestSnap.data()?['requestedDate'];
      if (requestedTimestamp is Timestamp) {
        fallbackBorrowDate = requestedTimestamp.toDate();
      }
    }

    final historyDocRef = _db.collection('asset_history').doc();

    await _db.runTransaction((transaction) async {
      transaction.update(assetDocRef, {
        'status': 'In Stock',
        'borrowedByUserId': FieldValue.delete(),
        'dueDateTime': FieldValue.delete(),
        'returnDate': FieldValue.serverTimestamp(),
        'location': 'Storage',
      });

      if (requestId != null && requestId.isNotEmpty) {
        transaction.update(_db.collection('requests').doc(requestId), {
          'status': 'RETURNED',
          'returnedAt': FieldValue.serverTimestamp(),
        });
      }

      transaction.set(historyDocRef, {
        'assetId': assetId,
        'name': assetName,
        'action': 'RETURNED',
        'condition': condition,
        'comments': comments ?? "",
        'userId': borrowerId,
        'requestId': requestId,
        'borrowDate': borrowDate is Timestamp
            ? borrowDate.toDate()
            : fallbackBorrowDate, // ✅ fallback used here
        'returnDate': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    });

    // Notify User
    if (borrowerId != null) {
      await sendUserNotification(
        toUserId: borrowerId,
        title: "Return Confirmed ↩️",
        message: "We have received **$assetName**. Thank you!",
        type: 'success',
        relatedId: requestId,
      );
    }

    // Notify Admins/Technicians
    await sendRoleNotification(
      role: 'Admin',
      title: "Asset Returned ↩️",
      message: "Asset **$assetName** has been returned.",
      type: 'info',
      relatedId: assetId,
    );

    await sendRoleNotification(
      role: 'Technician',
      title: "Asset Returned ↩️",
      message: "Asset **$assetName** has been returned.",
      type: 'info',
      relatedId: assetId,
    );
  }
  // ---------------------- ASSET HISTORY STREAM ----------------------

  Stream<List<Asset>> getAssetHistory(String userId, String statusFilter) {
    return _db
        .collection('asset_history')
        .where('userId', isEqualTo: userId)
        .where('action', isEqualTo: statusFilter)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return Asset(
          docId: doc.id,
          id: data['assetId'] ?? doc.id,
          name: data['name'] ?? 'Unknown',
          status: data['action'] ?? 'RETURNED',
          borrowDate: (data['borrowDate'] as Timestamp?)?.toDate(),
          returnDate: (data['returnDate'] as Timestamp?)?.toDate(),
          category: '',
          location: 'Storage',
          serialNumber: data['serialNumber'] ?? '',
          brand: data['brand'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
        );
      }).toList();
    });
  }

  //---------------------- REMINDER ----------------------
  Future<void> sendDueSoonReminders(String userId) async {
    try {
      final now = DateTime.now();
      final twoDaysLater = now.add(const Duration(days: 2));

      final borrowedAssets = await _db
          .collection('assets')
          .where('status', isEqualTo: 'BORROWED')
          .where('borrowedByUserId', isEqualTo: userId)
          .get();

      for (var doc in borrowedAssets.docs) {
        final data = doc.data();
        final dueTimestamp = data['dueDateTime'];
        final assetName = data['name'] ?? 'Asset';

        if (dueTimestamp is Timestamp) {
          final dueDate = dueTimestamp.toDate();
          if (dueDate.isAfter(now) && dueDate.isBefore(twoDaysLater)) {
            await sendUserNotification(
              toUserId: userId,
              title: "Return Reminder ⏰",
              message:
                  "Please return **$assetName** by ${DateFormat('dd MMM yyyy').format(dueDate)}",
              type: 'return_reminder',
              relatedId: doc.id,
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error sending due soon reminders: $e");
    }
  }

  // ---------------------- NOTIFICATIONS ----------------------

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

  Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({
      'read': true,
    });
  }

  Stream<List<NotificationModel>> getAdminNotifications() {
    return _db
        .collection('notifications')
        .where('role', isEqualTo: 'Admin')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<NotificationModel>> getTechnicianNotifications() {
    return _db
        .collection('notifications')
        .where('role', isEqualTo: 'Technician')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  Future<void> sendUserNotification({
    required String toUserId,
    required String title,
    required String message,
    required String type,
    String? relatedId,
  }) async {
    await _db.collection('notifications').add({
      'userId': toUserId,
      'title': title,
      'message': message,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'relatedId': relatedId,
    });
  }

  Future<void> sendRoleNotification({
    required String role, // 'Admin' or 'Technician'
    required String title,
    required String message,
    required String type,
    String? relatedId,
  }) async {
    await _db.collection('notifications').add({
      'role': role,
      'title': title,
      'message': message,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'relatedId': relatedId,
    });
  }
}
