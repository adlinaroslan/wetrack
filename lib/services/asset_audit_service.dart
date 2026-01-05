import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to log all asset status changes and updates to an audit trail
class AssetAuditService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Log an asset status change or update
  Future<void> logAssetChange({
    required String assetDocId,
    required String assetId,
    required String assetName,
    required String previousStatus,
    required String newStatus,
    required String changeType, // e.g., "Status Change", "Request Approved", "Fixed", "Disposed"
    String? details, // Optional details about the change
    String? changedBy, // Who made the change (user, admin, technician)
  }) async {
    try {
      await _firestore.collection('asset_audit_logs').add({
        'assetDocId': assetDocId,
        'assetId': assetId,
        'assetName': assetName,
        'previousStatus': previousStatus,
        'newStatus': newStatus,
        'changeType': changeType,
        'details': details ?? '',
        'changedBy': changedBy ?? 'System',
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': Timestamp.now(), // For filtering by date
      });
    } catch (e) {
      print('Error logging asset change: $e');
      // Don't throw - audit logging should not break main operations
    }
  }

  /// Get all audit logs for a specific asset
  Stream<List<Map<String, dynamic>>> getAssetAuditLogs(String assetDocId) {
    return _firestore
        .collection('asset_audit_logs')
        .where('assetDocId', isEqualTo: assetDocId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get all audit logs for a date range (for reports)
  Stream<List<Map<String, dynamic>>> getAuditLogsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _firestore
        .collection('asset_audit_logs')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get all audit logs by change type (for filtering)
  Stream<List<Map<String, dynamic>>> getAuditLogsByChangeType(String changeType) {
    return _firestore
        .collection('asset_audit_logs')
        .where('changeType', isEqualTo: changeType)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
