import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddAssetPage extends StatefulWidget {
  const AddAssetPage({super.key});

  @override
  State<AddAssetPage> createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController idController = TextEditingController();
  final TextEditingController serialController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController registerDateController = TextEditingController();

  String? category;
  String status = "In Stock";

  File? assetImage;
  final picker = ImagePicker();

  // ============================
  // CHOOSE IMAGE
  // ============================
  Future<void> pickImageSheet() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SizedBox(
        height: 150,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                final XFile? img =
                    await picker.pickImage(source: ImageSource.gallery);
                if (img != null) setState(() => assetImage = File(img.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () async {
                Navigator.pop(context);
                final XFile? img =
                    await picker.pickImage(source: ImageSource.camera);
                if (img != null) setState(() => assetImage = File(img.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================
  // UPLOAD IMAGE
  // ============================
  Future<String> uploadImage(File file) async {
    final fileName =
        '${idController.text}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final ref = FirebaseStorage.instance
        .ref()
        .child("asset_images")
        .child(fileName);

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // ============================
  // SAVE ASSET
  // ============================
  Future<void> saveAsset() async {
    if (!_formKey.currentState!.validate()) return;

    String imageUrl = "assets/default.png";

    try {
      if (assetImage != null) {
        imageUrl = await uploadImage(assetImage!);
      }

      await FirebaseFirestore.instance.collection("assets").add({
        "id": idController.text.trim(),
        "serialNumber": serialController.text.trim(),
        "name": nameController.text.trim(),
        "brand": brandController.text.trim(),
        "category": category,
        "status": status,
        "imageUrl": imageUrl,
        "location": "Available",
        "registerDate": registerDateController.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Asset added successfully")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add asset: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // ░░ GRADIENT APPBAR ░░
      appBar: AppBar(
        elevation: 0,
        title: const Text("Add New Asset"),
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // IMAGE PICKER
              Center(
                child: GestureDetector(
                  onTap: pickImageSheet,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: const Color(0xFF00A7A7),
                    backgroundImage:
                        assetImage != null ? FileImage(assetImage!) : null,
                    child: assetImage == null
                        ? const Icon(Icons.camera_alt,
                            size: 50, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // FIELDS
              _buildTextField(idController, "Asset ID", Icons.qr_code),
              _buildTextField(serialController, "Serial Number", Icons.tag),
              _buildTextField(nameController, "Asset Name", Icons.devices),
              _buildTextField(brandController, "Brand", Icons.business),

              // DATE PICKER
              TextFormField(
                controller: registerDateController,
                readOnly: true,
                decoration: _inputDecoration().copyWith(
                  labelText: "Register Date",
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    registerDateController.text =
                        DateFormat("dd MMM yyyy").format(pickedDate);
                  }
                },
                validator: (v) =>
                    v == null || v.isEmpty ? "Please select date" : null,
              ),
              const SizedBox(height: 16),

              // CATEGORY
              DropdownButtonFormField<String>(
                decoration: _inputDecoration().copyWith(
                  labelText: "Category",
                ),
                items: const [
                  DropdownMenuItem(value: "Monitor", child: Text("Monitor")),
                  DropdownMenuItem(value: "Desktop", child: Text("Desktop")),
                  DropdownMenuItem(value: "Machine", child: Text("Machine")),
                  DropdownMenuItem(value: "Tools", child: Text("Tools")),
                  DropdownMenuItem(
                      value: "IT-Accessories",
                      child: Text("IT-Accessories")),
                ],
                onChanged: (value) => category = value,
                validator: (v) =>
                    v == null ? "Please choose a category" : null,
              ),
              const SizedBox(height: 16),

              // STATUS
              DropdownButtonFormField<String>(
                value: status,
                decoration: _inputDecoration().copyWith(labelText: "Status"),
                items: const [
                  DropdownMenuItem(value: "In Stock", child: Text("In Stock")),
                  DropdownMenuItem(value: "In Use", child: Text("In Use")),
                  DropdownMenuItem(
                      value: "Re-Purchased Needed",
                      child: Text("Re-Purchased Needed")),
                  DropdownMenuItem(value: "Sold Out", child: Text("Sold Out")),
                ],
                onChanged: (value) => setState(() => status = value!),
              ),
              const SizedBox(height: 30),

              // SAVE BUTTON
              ElevatedButton.icon(
                onPressed: saveAsset,
                icon: const Icon(Icons.save),
                label: const Text("Save Asset"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A7A7),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================
  // UI HELPERS
  // ============================
  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: _inputDecoration().copyWith(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF004C5C)),
        ),
        validator: (v) => v == null || v.isEmpty ? "Required field" : null,
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Color(0xFF004C5C)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
