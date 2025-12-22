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
    "Sold Out",
    "DISPOSED",
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.asset.name);
    brandController = TextEditingController(text: widget.asset.brand);
    categoryController = TextEditingController(text: widget.asset.category);
    serialController =
        TextEditingController(text: widget.asset.serialNumber);
    locationController =
        TextEditingController(text: widget.asset.location);
    imagePathController =
        TextEditingController(text: widget.asset.imageUrl);

    selectedStatus = statusOptions.contains(widget.asset.status)
        ? widget.asset.status
        : statusOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Edit Asset: ${widget.asset.name}"),
        backgroundColor: const Color(0xFF004C5C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Asset Name"),
              _buildTextField(nameController),

              _buildLabel("Serial Number"),
              _buildTextField(serialController),

              _buildLabel("Brand"),
              _buildTextField(brandController),

              _buildLabel("Category"),
              _buildTextField(categoryController),

              _buildLabel("Location"),
              _buildTextField(locationController),

              _buildLabel("Image Path"),
              _buildTextField(imagePathController),

              const SizedBox(height: 10),

              _buildLabel("Status"),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: _inputDecoration(),
                items: statusOptions.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => selectedStatus = value!),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF00A7A7),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================
  // SAVE CHANGES (FIXED)
  // ======================================
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance
        .collection("assets")
        .doc(widget.asset.docId) // ✅ IMPORTANT FIX
        .update({
      "name": nameController.text.trim(),
      "serialNumber": serialController.text.trim(),
      "brand": brandController.text.trim(),
      "category": categoryController.text.trim(),
      "location": locationController.text.trim(),
      "imageUrl": imagePathController.text.trim(),
      "status": selectedStatus,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Asset updated successfully!")),
    );

    Navigator.pop(context, true); // ✅ notify previous page
  }

  // ======================================
  // HELPERS
  // ======================================
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 16),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(),
      validator: (v) =>
          v == null || v.isEmpty ? "This field cannot be empty" : null,
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
