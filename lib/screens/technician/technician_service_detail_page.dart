import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // <-- For formatting date

class TechnicianServiceDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const TechnicianServiceDetailPage({super.key, required this.item});

  @override
  State<TechnicianServiceDetailPage> createState() =>
      _TechnicianServiceDetailPageState();
}

class _TechnicianServiceDetailPageState
    extends State<TechnicianServiceDetailPage> {
  late Map<String, dynamic> _itemData;
  bool _loading = false;
  bool _processing = false;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _assetSub;

  @override
  void initState() {
    super.initState();
    _itemData = Map<String, dynamic>.from(widget.item);
    _loadAssetDetailsIfNeeded().then((_) => _subscribeToAssetIfExists());
    _subscribeToServiceRequest();
  }

  void _subscribeToAssetIfExists() {
    final assetDocId = (_itemData['assetDocId'] ?? '').toString();
    if (assetDocId.isEmpty) return;

    _assetSub?.cancel();
    _assetSub = FirebaseFirestore.instance
        .collection('assets')
        .doc(assetDocId)
        .snapshots()
        .listen((snap) {
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _itemData['assetId'] = data['id'] ?? _itemData['assetId'];
        _itemData['assetName'] = data['name'] ?? _itemData['assetName'];
        _itemData['serialNumber'] =
            data['serialNumber'] ?? _itemData['serialNumber'];
        _itemData['brand'] = data['brand'] ?? _itemData['brand'];
        _itemData['category'] = data['category'] ?? _itemData['category'];
        _itemData['location'] = data['location'] ?? _itemData['location'];
        _itemData['status'] = data['status'] ?? _itemData['status'];
      });
    });
  }

  void _subscribeToServiceRequest() {
    final serviceId = (_itemData['serviceId'] ?? '').toString();
    if (serviceId.isEmpty) return;

    FirebaseFirestore.instance
        .collection('service_requests')
        .doc(serviceId)
        .snapshots()
        .listen((snap) {
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _itemData['status'] = data['status'] ?? _itemData['status'];
        _itemData['fixedAt'] = data['fixedAt'] ?? _itemData['fixedAt'];
        _itemData['userName'] = data['userName'] ?? _itemData['userName'];
      });
    });
  }

  Future<void> _loadAssetDetailsIfNeeded() async {
    try {
      if ((_itemData['assetName'] ?? '').toString().isNotEmpty &&
          (_itemData['assetId'] ?? '').toString().isNotEmpty) return;

      setState(() => _loading = true);

      final firestore = FirebaseFirestore.instance;

      String? assetDocId = (_itemData['assetDocId'] ?? '').toString();
      String assetIdField = (_itemData['assetId'] ?? '').toString();

      DocumentSnapshot? assetSnap;

      if (assetDocId.isNotEmpty) {
        assetSnap = await firestore.collection('assets').doc(assetDocId).get();
      }

      if ((assetSnap == null || !assetSnap.exists) && assetIdField.isNotEmpty) {
        final cand =
            await firestore.collection('assets').doc(assetIdField).get();
        if (cand.exists) {
          assetSnap = cand;
          assetDocId = cand.id;
        }
      }

      if ((assetSnap == null || !assetSnap.exists) && assetIdField.isNotEmpty) {
        final q = await firestore
            .collection('assets')
            .where('id', isEqualTo: assetIdField)
            .limit(1)
            .get();
        if (q.docs.isNotEmpty) {
          assetSnap = q.docs.first;
          assetDocId = q.docs.first.id;
        }
      }

      if (assetSnap != null && assetSnap.exists) {
        final data = assetSnap.data() as Map<String, dynamic>;
        setState(() {
          _itemData['assetDocId'] = assetDocId ?? assetSnap!.id;
          _itemData['assetId'] =
              _itemData['assetId'] ?? data['id'] ?? data['assetId'];
          _itemData['assetName'] =
              _itemData['assetName'] ?? data['name'] ?? data['assetName'];
          _itemData['serialNumber'] =
              _itemData['serialNumber'] ?? data['serialNumber'];
          _itemData['brand'] = _itemData['brand'] ?? data['brand'];
          _itemData['category'] = _itemData['category'] ?? data['category'];
          _itemData['location'] = _itemData['location'] ?? data['location'];
          _itemData['status'] = _itemData['status'] ?? data['status'];
        });
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAsFixed(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Resolve asset doc id OUTSIDE transaction (no reads/writes needed yet)
      String? assetDocId = (_itemData['assetDocId'] ?? '').toString();
      final assetIdField = (_itemData['assetId'] ?? '').toString();

      if (assetDocId.isEmpty && assetIdField.isNotEmpty) {
        // try document id
        final cand =
            await firestore.collection('assets').doc(assetIdField).get();
        if (cand.exists) {
          assetDocId = cand.id;
        } else {
          // try querying by 'id' field
          final q = await firestore
              .collection('assets')
              .where('id', isEqualTo: assetIdField)
              .limit(1)
              .get();
          if (q.docs.isNotEmpty) assetDocId = q.docs.first.id;
        }
      }

      // NOW perform transaction with all reads first, then writes
      await firestore.runTransaction((tx) async {
        final rawServiceId = (_itemData['serviceId'] ?? '').toString();
        final serviceIdVal =
            (rawServiceId.isNotEmpty && rawServiceId != assetDocId)
                ? rawServiceId
                : '';

        // PHASE 1: All reads first
        DocumentSnapshot? serviceSnap;
        DocumentSnapshot? assetSnap;

        if (serviceIdVal.isNotEmpty) {
          final serviceDocRef =
              firestore.collection('service_requests').doc(serviceIdVal);
          serviceSnap = await tx.get(serviceDocRef);
        }

        if (assetDocId != null && assetDocId.isNotEmpty) {
          final assetRef = firestore.collection('assets').doc(assetDocId);
          assetSnap = await tx.get(assetRef);
        }

        // PHASE 2: All writes (after all reads are done)
        if (serviceSnap != null && serviceSnap.exists) {
          tx.update(serviceSnap.reference, {
            'status': 'Fixed',
            'fixedAt': Timestamp.now(),
          });
        }

        if (assetSnap != null && assetSnap.exists) {
          tx.update(assetSnap.reference, {
            'status': 'In Stock',
            'location': 'Storage',
            'borrowedByUserId': FieldValue.delete(),
            'dueDateTime': FieldValue.delete(),
          });

          // If there was no service request, create one so item shows in Fixed tab
          if (serviceIdVal.isEmpty) {
            final newServiceRef =
                firestore.collection('service_requests').doc();
            final assetMap = assetSnap.data() as Map<String, dynamic>;
            tx.set(newServiceRef, {
              'assetDocId': assetDocId,
              'assetId': assetMap['id'] ?? assetDocId,
              'assetName': _itemData['assetName'] ?? assetMap['name'] ?? '',
              'damage': _itemData['damage'] ?? '',
              'status': 'Fixed',
              'createdAt': Timestamp.now(),
              'fixedAt': Timestamp.now(),
            });
          }
        }
      });

      // Ensure any service_requests that reference this asset are also marked Fixed
      try {
        final resolvedAssetDocId = (_itemData['assetDocId'] ?? '').toString();
        final resolvedAssetId = (_itemData['assetId'] ?? '').toString();

        // candidate field names to search for the asset reference
        final assetFields = [
          'assetDocId',
          'asset_doc_id',
          'assetId',
          'asset_id',
          'asset'
        ];

        for (final field in assetFields) {
          try {
            if (resolvedAssetDocId.isNotEmpty) {
              final q = await firestore
                  .collection('service_requests')
                  .where(field, isEqualTo: resolvedAssetDocId)
                  .get();
              for (final d in q.docs) {
                await d.reference
                    .update({'status': 'Fixed', 'fixedAt': Timestamp.now()});
              }
            }
          } catch (_) {
            // ignore invalid queries for fields that don't exist
          }

          try {
            if (resolvedAssetId.isNotEmpty) {
              final q2 = await firestore
                  .collection('service_requests')
                  .where(field, isEqualTo: resolvedAssetId)
                  .get();
              for (final d in q2.docs) {
                await d.reference
                    .update({'status': 'Fixed', 'fixedAt': Timestamp.now()});
              }
            }
          } catch (_) {
            // ignore
          }
        }
      } catch (_) {
        // non-fatal
      }

      // Ensure the asset document is updated to 'In Stock' in case the
      // transaction couldn't resolve the asset doc id earlier.
      try {
        final assetsCol = firestore.collection('assets');
        final resolvedAssetDocId = (_itemData['assetDocId'] ?? '').toString();
        final resolvedAssetId = (_itemData['assetId'] ?? '').toString();

        if (resolvedAssetDocId.isNotEmpty) {
          try {
            await assetsCol.doc(resolvedAssetDocId).update({
              'status': 'In Stock',
              'location': 'Storage',
              'borrowedByUserId': FieldValue.delete(),
              'dueDateTime': FieldValue.delete(),
            });
          } catch (_) {
            // ignore update failures
          }
        } else if (resolvedAssetId.isNotEmpty) {
          try {
            final q = await assetsCol
                .where('id', isEqualTo: resolvedAssetId)
                .limit(1)
                .get();
            if (q.docs.isNotEmpty) {
              await q.docs.first.reference.update({
                'status': 'In Stock',
                'location': 'Storage',
                'borrowedByUserId': FieldValue.delete(),
                'dueDateTime': FieldValue.delete(),
              });
            }
          } catch (_) {
            // ignore
          }
        }
      } catch (_) {
        // non-fatal
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Service marked as Fixed successfully."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating service: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFixed = (_itemData['status'] ?? '').toString() == 'Fixed';

    // Format fixedAt timestamp if exists
    String fixedAtFormatted = '-';
    if ((_itemData['fixedAt']) != null) {
      Timestamp ts = _itemData['fixedAt'] as Timestamp;
      fixedAtFormatted = DateFormat('yyyy-MM-dd HH:mm').format(ts.toDate());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Service Detail",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asset Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Asset Information",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _infoRow("Asset ID", _itemData['assetId']),
                    _infoRow("Name", _itemData['assetName']),
                    _infoRow("Serial Number", _itemData['serialNumber']),
                    _infoRow("Brand", _itemData['brand']),
                    _infoRow("Category", _itemData['category']),
                    _infoRow("Location", _itemData['location']),
                    _infoRow("Status", _itemData['status']),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Service Request Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Service Request Information",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _infoRow("Service ID", _itemData['serviceId']),
                    _infoRow("User",
                        _itemData['userName'] ?? _itemData['userId'] ?? '-'),
                    _infoRow("Issue / Damage", _itemData['damage']),
                    _infoRow("Status", _itemData['status']),
                    _infoRow("Fixed At", fixedAtFormatted),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Show Mark as Fixed button only if not fixed
            if (!isFixed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _processing
                      ? null
                      : () async {
                          setState(() => _processing = true);
                          await _markAsFixed(context);
                          if (mounted) setState(() => _processing = false);
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Container(
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(minHeight: 48),
                        child: _processing
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Marking... ',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              )
                            : const Text(
                                "Mark as Fixed",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _assetSub?.cancel();
    super.dispose();
  }
}
