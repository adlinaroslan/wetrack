import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import '../models/asset_model.dart';
import '../models/request_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Singleton instance
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() {
    return _instance;
  }
  FirestoreService._internal();

  // --- Collection References ---
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

  // --- User Profile Management ---

  // Fetches the user's detailed profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await usersRef.doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // Creates a new user profile upon registration/first login
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
    String role = 'User', // Default role for new signups
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

  // --- Real-Time Streams ---

  Stream<List<Asset>> getAvailableAssets() {
    // Only fetch assets that are currently AVAILABLE
    return assetsRef
        .where('status', isEqualTo: 'AVAILABLE')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // NEW: Stream for assets currently borrowed by a specific user
  Stream<List<Asset>> getBorrowedAssets(String userId) {
    // Assets that are marked as 'BORROWED' and linked to the current user's ID
    return assetsRef
        .where('status', isEqualTo: 'BORROWED')
        .where('borrowedByUserId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // --- Core Transaction: Asset Request ---
  Future<void> requestAsset({
    required String assetId,
    required String assetName,
    required DateTime requiredDate,
    // Add user details to the request for easy admin viewing
    required String userId,
    required String userName,
  }) async {
    final newRequest = AssetRequest(
      id: '', // Firestore will assign this
      userId: userId,
      userName: userName,
      assetId: assetId,
      assetName: assetName,
      requestedDate: DateTime.now(),
      requiredDate: requiredDate,
      status: 'PENDING',
    );

    // 1. Create the request document
    await requestsRef.add(newRequest);

    // 2. Optionally update the asset status to PENDING_REQUEST
    await assetsRef.doc(assetId).update({'status': 'PENDING_REQUEST'});
  }

  // --- Request management ---
  // Stream requests for a specific user (useful for 'My Requests' page)
  Stream<List<AssetRequest>> getRequestsForUser(String userId) {
    return requestsRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => d.data()).toList());
  }

  // Stream all requests (for admin)
  Stream<List<AssetRequest>> getAllRequests() {
    return requestsRef
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => d.data()).toList());
  }

  // Approve a request: mark request approved, update asset to BORROWED and log history
  Future<void> approveRequest({
    required String requestId,
    required String assetId,
    required String borrowerUserId,
    required DateTime dueDate,
  }) async {
    final requestDoc = requestsRef.doc(requestId);
    final assetDoc = assetsRef.doc(assetId);

    await _db.runTransaction((transaction) async {
      // 1. Read request and asset
      final reqSnap = await transaction.get(requestDoc);
      if (!reqSnap.exists) throw Exception('Request not found');

      final assetSnap = await transaction.get(assetDoc);
      if (!assetSnap.exists) throw Exception('Asset not found');

      // 2. Update request status
      transaction.update(requestDoc,
          {'status': 'APPROVED', 'approvedAt': FieldValue.serverTimestamp()});

      // 3. Update asset status and borrower info
      transaction.update(assetDoc, {
        'status': 'BORROWED',
        'borrowedByUserId': borrowerUserId,
        'dueDateTime': Timestamp.fromDate(dueDate),
        'location': 'With User',
      });

      // 4. Add history entry
      _db.collection('asset_history').add({
        'assetId': assetId,
        'action': 'BORROWED',
        'byUserId': borrowerUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'dueDateTime': Timestamp.fromDate(dueDate),
      });
    });
  }

  // Decline a request: mark request rejected and reset asset status if it was set to pending
  Future<void> declineRequest({
    required String requestId,
    required String assetId,
  }) async {
    final requestDoc = requestsRef.doc(requestId);
    final assetDoc = assetsRef.doc(assetId);

    await _db.runTransaction((transaction) async {
      final reqSnap = await transaction.get(requestDoc);
      if (!reqSnap.exists) throw Exception('Request not found');

      transaction.update(requestDoc,
          {'status': 'REJECTED', 'rejectedAt': FieldValue.serverTimestamp()});

      // If asset was marked as pending, reset to AVAILABLE
      final assetSnap = await transaction.get(assetDoc);
      if (assetSnap.exists) {
        final assetObj = assetSnap.data(); // typed Asset (from converter)
        final currentStatus = assetObj != null ? assetObj.status : '';
        if (currentStatus == 'PENDING_REQUEST') {
          transaction.update(assetDoc, {'status': 'AVAILABLE'});
        }
      }
    });
  }

  // Update an existing request document
  Future<void> updateRequest(
      String requestId, Map<String, dynamic> updates) async {
    await requestsRef.doc(requestId).update(updates);
  }

  // --- Core Transaction: Asset Return ---
  Future<void> confirmReturn({
    required String assetId,
    required String condition,
    String? comments,
  }) async {
    final assetDocRef = assetsRef.doc(assetId);

    // Use a Firestore transaction to ensure atomicity
    await _db.runTransaction((transaction) async {
      // 1. Read the current asset data
      final assetSnapshot = await transaction.get(assetDocRef);
      if (!assetSnapshot.exists) {
        throw Exception("Asset not found for return: $assetId");
      }
      final currentAsset = assetSnapshot.data();

      // 2. Update the asset status and remove borrower details
      transaction.update(assetDocRef, {
        'status': 'AVAILABLE', // Reset to available
        'borrowedByUserId': FieldValue.delete(),
        'dueDateTime': FieldValue.delete(),
      });

      // 3. Log the return transaction in a separate 'history' collection
      _db.collection('asset_history').add({
        'assetId': assetId,
        'action': 'RETURNED',
        'condition': condition,
        'comments': comments,
        'returnedByUserId': currentAsset?.borrowedByUserId ?? 'N/A',
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }
}
