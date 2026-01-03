import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/asset_model.dart';

class EditAssetPage extends StatefulWidget {
  final Asset asset;

  const EditAssetPage({super.key, required this.asset});

  @override
  State<EditAssetPage> createState() => _EditAssetPageState();
}

class _EditAssetPageState extends State<EditAssetPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController brandController;
  late TextEditingController categoryController;
  late TextEditingController serialController;
  late TextEditingController locationController;
  late TextEditingController imagePathController;

  late String selectedStatus;

  final List<String> statusOptions = [
    "In Stock",
    "In Use",
    "Re-Purchased Needed",
    "Service Needed",
    "Available",
    "Disposed",
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.asset.name);
    brandController = TextEditingController(text: widget.asset.brand);
    categoryController = TextEditingController(text: widget.asset.category);
    serialController = TextEditingController(text: widget.asset.serialNumber);
    locationController = TextEditingController(text: widget.asset.location);
    imagePathController = TextEditingController(text: widget.asset.imageUrl);

    selectedStatus = widget.asset.status;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final firestore = FirebaseFirestore.instance;

    // 1️⃣ Update asset
    await firestore.collection("assets").doc(widget.asset.docId).update({
      "name": nameController.text.trim(),
      "serialNumber": serialController.text.trim(),
      "brand": brandController.text.trim(),
      "category": categoryController.text.trim(),
      "location": locationController.text.trim(),
      "imageUrl": imagePathController.text.trim(),
      "status": selectedStatus,
    });

    // 2️⃣ CREATE SERVICE REQUEST IF NEEDED
    if (selectedStatus == "Service Needed") {
      final existing = await firestore
          .collection('service_requests')
          .where('assetDocId', isEqualTo: widget.asset.docId)
          .where('status', isEqualTo: 'In Progress')
          .limit(1)
          .get();

      if (existing.docs.isEmpty) {
        await firestore.collection('service_requests').add({
          'assetDocId': widget.asset.docId,
          'assetId': widget.asset.id,
          'assetName': widget.asset.name,
          'assetType': widget.asset.category,
          'damage': 'Reported by admin',
          'comment': '-',
          'user': 'Admin',
          'status': 'In Progress',
'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Changes successfully saved."),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Asset")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label("Asset Name"),
              _field(nameController),

              _label("Serial Number"),
              _field(serialController),

              _label("Brand"),
              _field(brandController),

              _label("Category"),
              _field(categoryController),

              _label("Location"),
              _field(locationController),

              _label("Image Path"),
              _field(imagePathController),

              _label("Status"),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                items: statusOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => selectedStatus = v!),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text("Save Changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
      );

  Widget _field(TextEditingController c) => TextFormField(
        controller: c,
        validator: (v) => v!.isEmpty ? "Required" : null,
      );
}
