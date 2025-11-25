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

  String selectedStatus = "AVAILABLE";

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Asset: ${widget.asset.name}"),
        backgroundColor: Colors.blue,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // --- NAME ---
              _buildLabel("Asset Name"),
              _buildTextField(nameController),

              // --- SERIAL NUMBER ---
              _buildLabel("Serial Number"),
              _buildTextField(serialController),

              // --- BRAND ---
              _buildLabel("Brand"),
              _buildTextField(brandController),

              // --- CATEGORY ---
              _buildLabel("Category"),
              _buildTextField(categoryController),

              // --- LOCATION ---
              _buildLabel("Location"),
              _buildTextField(locationController),

              // --- IMAGE PATH ---
              _buildLabel("Image Path"),
              _buildTextField(imagePathController),

              const SizedBox(height: 10),

              // --- STATUS DROPDOWN ---
              _buildLabel("Status"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(border: InputBorder.none),
                  items: const [
                    DropdownMenuItem(value: "AVAILABLE", child: Text("AVAILABLE")),
                    DropdownMenuItem(value: "BORROWED", child: Text("BORROWED")),
                    DropdownMenuItem(value: "MAINTENANCE", child: Text("MAINTENANCE")),
                    DropdownMenuItem(value: "DISPOSED", child: Text("DISPOSED")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 25),

              // --- SAVE BUTTON ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text("Save Changes", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // ======================================
  // SAVE CHANGES TO FIRESTORE
  // ======================================
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedData = {
      "name": nameController.text.trim(),
      "serialNumber": serialController.text.trim(),
      "brand": brandController.text.trim(),
      "category": categoryController.text.trim(),
      "location": locationController.text.trim(),
      "imagePath": imagePathController.text.trim(),
      "status": selectedStatus,
    };

    await FirebaseFirestore.instance
        .collection("assets")
        .doc(widget.asset.id)
        .update(updatedData);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Asset updated successfully!")),
    );

    Navigator.pop(context);
  }


  // ======================================
  // REUSABLE WIDGETS
  // ======================================
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? "This field cannot be empty" : null,
    );
  }
}
