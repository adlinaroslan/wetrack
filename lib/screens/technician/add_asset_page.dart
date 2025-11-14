import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/asset_model.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class AddAssetPage extends StatefulWidget {
  const AddAssetPage({super.key});

  @override
  State<AddAssetPage> createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController registerDateController = TextEditingController();

  String? category;
  String? status = 'Active';
  File? assetImage;

  final ImagePicker picker = ImagePicker();

  // ============================
  // IMAGE PICKER (Gallery / Camera)
  // ============================
  Future<void> showImageSourceActionSheet() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() => assetImage = File(image.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo =
                      await picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    setState(() => assetImage = File(photo.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BFA6),
        title: const Text("Add New Asset"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // ============================
              // IMAGE PICKER UI
              // ============================
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: showImageSourceActionSheet,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage:
                            assetImage != null ? FileImage(assetImage!) : null,
                        child: assetImage == null
                            ? const Icon(Icons.photo, size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: showImageSourceActionSheet,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00BFA6),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ============================
              // TEXT FIELDS
              // ============================

              _buildTextField(idController, "Asset ID", Icons.qr_code),
              _buildTextField(nameController, "Asset Name", Icons.devices),
              _buildTextField(brandController, "Asset Brand", Icons.branding_watermark),

              // ============================
              // DATE PICKER
              // ============================
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: registerDateController,
                  decoration: _inputDecoration().copyWith(
                    labelText: "Register Date",
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        registerDateController.text =
                            DateFormat('dd MMM yyyy').format(pickedDate);
                      });
                    }
                  },
                  validator: (value) =>
                      value == null || value.isEmpty ? "Please select a date" : null,
                ),
              ),

              // ============================
              // CATEGORY DROPDOWN
              // ============================
              const Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: category,
                decoration: _inputDecoration(),
                items: const [
                  DropdownMenuItem(value: "Laptop", child: Text("Laptop")),
                  DropdownMenuItem(value: "Cable", child: Text("Cable")),
                  DropdownMenuItem(value: "Storage", child: Text("Storage")),
                  DropdownMenuItem(value: "Electronics", child: Text("Electronics")),
                ],
                onChanged: (value) => setState(() => category = value),
                validator: (value) =>
                    value == null ? "Please select a category" : null,
              ),

              const SizedBox(height: 16),

              // ============================
              // STATUS DROPDOWN
              // ============================
              const Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: status,
                decoration: _inputDecoration(),
                items: const [
                  DropdownMenuItem(value: "Active", child: Text("Active")),
                  DropdownMenuItem(value: "Disposed", child: Text("Disposed")),
                ],
                onChanged: (value) => setState(() => status = value),
              ),

              const SizedBox(height: 24),

              // ============================
              // SAVE BUTTON
              // ============================
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA6),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text("Save Asset"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newAsset = Asset(
                        id: idController.text,
                        name: nameController.text,
                        brand: brandController.text,
                        registerDate: registerDateController.text,
                        category: category ?? '',
                        status: status ?? 'Active',
                        imagePath: assetImage?.path ?? 'assets/default.png',
                      );

                      Navigator.pop(context, newAsset);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TEXT FIELD BUILDER
  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration:
            _inputDecoration().copyWith(labelText: label, prefixIcon: Icon(icon)),
        validator: (value) => value == null || value.isEmpty ? "Required field" : null,
      ),
    );
  }

  // DECORATION STYLE
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
