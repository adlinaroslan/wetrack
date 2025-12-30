import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:wetrack/models/asset_model.dart';
import 'user_return_asset_details.dart';
import 'package:wetrack/services/asset_image_helper.dart';

class UserReturnAssetPage extends StatefulWidget {
  const UserReturnAssetPage({super.key});

  @override
  State<UserReturnAssetPage> createState() => _UserReturnAssetPageState();
}

class _UserReturnAssetPageState extends State<UserReturnAssetPage> {
  final Set<String> _selectedAssetIds = {};
  String _searchQuery = '';

  static const LinearGradient mainGradient = LinearGradient(
    colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  bool _isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    return dueDate.isBefore(DateTime.now());
  }

  void _toggleSelection(String assetId) {
    setState(() {
      if (_selectedAssetIds.contains(assetId)) {
        _selectedAssetIds.remove(assetId);
      } else {
        _selectedAssetIds.add(assetId);
      }
    });
  }

  void _goToDetailsPage(Asset asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserReturnAssetDetailsPage(
          assetName: asset.name,
          assetId: asset.docId,
          category: asset.category,
          location: asset.location,
          status: _isOverdue(asset.dueDateTime) ? 'Overdue' : 'In Use',
          imagePath: _getImagePath(asset.name),
          serialNumber: asset.serialNumber,
          dueDateTime: asset.dueDateTime,
        ),
      ),
    );
  }

  /// ✅ Updated: process each selected asset one by one
  void _processReturn() async {
    if (_selectedAssetIds.isEmpty) return;

    final selectedIds = List<String>.from(_selectedAssetIds);

    // Clear selection immediately
    setState(() {
      _selectedAssetIds.clear();
    });

    for (final assetId in selectedIds) {
      final doc = await FirebaseFirestore.instance
          .collection('assets')
          .doc(assetId)
          .get();

      final asset = Asset.fromFirestore(doc);

      // Navigate to details page and wait until user returns
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserReturnAssetDetailsPage(
            assetName: asset.name,
            assetId: asset.docId,
            category: asset.category,
            location: asset.location,
            status: _isOverdue(asset.dueDateTime) ? 'Overdue' : 'In Use',
            imagePath: _getImagePath(asset.name),
            serialNumber: asset.serialNumber,
            dueDateTime: asset.dueDateTime,
          ),
        ),
      );
    }

    // Optional: show summary after all assets processed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Processed ${selectedIds.length} returns.")),
    );
  }

  List<Asset> _filterAssets(List<Asset> assets) {
    if (_searchQuery.isEmpty) return assets;
    final query = _searchQuery.toLowerCase();
    return assets.where((asset) {
      return asset.name.toLowerCase().contains(query) ||
          asset.docId.toLowerCase().contains(query);
    }).toList();
  }

  String _getImagePath(String assetName) {
    final path = getAssetImagePath(assetName);
    return path.isNotEmpty ? path : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(gradient: mainGradient),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "Return Assets",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildScanHeader(context),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search asset name or ID...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00A7A7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFEFF9F9),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('assets').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allAssets = snapshot.data!.docs
                    .map((doc) => Asset.fromFirestore(doc))
                    .toList();

                final borrowedAssets = allAssets
                    .where((asset) => asset.borrowedByUserId != null)
                    .toList();

                final assets = _filterAssets(borrowedAssets);

                if (assets.isEmpty) {
                  return Center(
                      child: Text(_searchQuery.isEmpty
                          ? "No assets to return"
                          : "No assets matching '$_searchQuery'"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: assets.length,
                  itemBuilder: (context, index) {
                    final asset = assets[index];
                    final isSelected = _selectedAssetIds.contains(asset.docId);

                    return _selectableAssetCard(asset, isSelected);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedAssetIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _processReturn,
              backgroundColor: const Color(0xFF004C5C),
              icon: const Icon(Icons.assignment_return, color: Colors.white),
              label: Text("Return (${_selectedAssetIds.length}) Items",
                  style: const TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  // --- WIDGET: Large Scan Button Header ---
  Widget _buildScanHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00A7A7).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.qr_code_scanner, size: 40, color: Color(0xFF00A7A7)),
          const SizedBox(height: 8),
          const Text(
            "Quick Return",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF004C5C),
                fontSize: 16),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/scanqr'),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF00A7A7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("SCAN QR CODE TO RETURN"),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Selectable Card (MODIFIED onTap) ---
  Widget _selectableAssetCard(Asset asset, bool isSelected) {
    final isOverdue = _isOverdue(asset.dueDateTime);
    final dueStr = asset.dueDateTime != null
        ? DateFormat('dd MMM yyyy').format(asset.dueDateTime!)
        : 'N/A';
    final imagePath = _getImagePath(asset.name);

    return GestureDetector(
      // MODIFIED: Tapping the card now goes to the details page.
      onTap: () => _goToDetailsPage(asset),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: isOverdue ? Colors.red.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFF00A7A7), width: 2)
              : Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // CHECKBOX - Must be handled separately or disabled if not needed for bulk return
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: isSelected,
                  activeColor: const Color(0xFF00A7A7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  // Tapping the checkbox still calls _toggleSelection
                  onChanged: (bool? value) {
                    _toggleSelection(asset.docId);
                  },
                ),
              ),
              const SizedBox(width: 8),

              // IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.grey.shade100,
                  width: 50,
                  height: 50,
                  child: imagePath.isNotEmpty
                      ? Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.devices_other),
                        )
                      : const Icon(Icons.devices_other),
                ),
              ),
              const SizedBox(width: 15),

              // TEXT (NAME & DUE DATE)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF004C5C)
                            : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Due Date: $dueStr',
                      style: TextStyle(
                        color: isOverdue ? Colors.red.shade700 : Colors.grey,
                        fontWeight:
                            isOverdue ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // OVERDUE PILL
              if (isOverdue)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "OVERDUE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),

              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
