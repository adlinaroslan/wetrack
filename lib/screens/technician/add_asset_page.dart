import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddAssetPage extends StatefulWidget {
  const AddAssetPage({super.key});

  @override
  State<AddAssetPage> createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  final _formKey = GlobalKey<FormState>();

  // ============================
  // TEXT CONTROLLERS
  // ============================
  final TextEditingController idController = TextEditingController();
  final TextEditingController serialController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController registerDateController = TextEditingController();

  String? category;
  String status = "In Stock";
  String? selectedImage;

  // ============================
  // IMAGE OPTIONS
  // ============================
  final Map<String, String> imageOptions = {
    'Laminator': 'assets/images/laminator.png',
    'Apacer': 'assets/images/apacer.png',
    'Maxell': 'assets/images/maxell.jpg',
    'Acer': 'assets/images/acer.png',
    'TV Mount Bracket': 'assets/images/tv mount bracket.jpg',
    'Sandisk': 'assets/images/sandisk.jpg',
    'Cable': 'assets/images/cable.png',
    'Keelat': 'assets/images/keelat.jpg',
    'Cordless Blower': 'assets/images/cordless blower.jpg',
    'Portable Voice Amplifier':
        'assets/images/portable voice amplifier.jpg',
    'HDMI': 'assets/images/hdmi.jpg',
    'VGA': 'assets/images/VGA.jpg',
    'UGreen Adapter': 'assets/images/ugreen adapter.jpg',
    'Microphone Stand': 'assets/images/mic stand.png',
    'RASPBERRY PI 4B': 'assets/images/RASPBERRY PI 4B.jpg',
    'HyperX': 'assets/images/hyperx.jpg',
  };

  // ============================
  // SAVE ASSET
  // ============================
  Future<void> saveAsset() async {
    if (!_formKey.currentState!.validate()) return;

    final assetId = idController.text.trim();

    try {
      final docRef =
          FirebaseFirestore.instance.collection('assets').doc(assetId);

      if ((await docRef.get()).exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Asset ID already exists")),
        );
        return;
      }

      await docRef.set({
        'id': assetId,
        'serialNumber': serialController.text.trim(),
        'name': nameController.text.trim(),
        'brand': brandController.text.trim(),
        'category': category,
        'imageUrl': selectedImage,
        'location': 'Available',
        'status': status,
        'registerDate': registerDateController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Asset added successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add asset: $e")),
      );
    }
  }

  // ============================
  // UI
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text("Add Asset"),
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
              // ============================
              // IMAGE PREVIEW
              // ============================
              CircleAvatar(
                radius: 58,
                backgroundColor: Colors.white,
                backgroundImage:
                    selectedImage != null ? AssetImage(selectedImage!) : null,
                child: selectedImage == null
                    ? const Icon(Icons.image,
                        size: 42, color: Colors.grey)
                    : null,
              ),

              const SizedBox(height: 22),

              // ============================
              // IMAGE DROPDOWN
              // ============================
              DropdownButtonFormField<String>(
                value: selectedImage,
                decoration: _inputDecoration("Asset Image"),
                items: imageOptions.entries.map((e) {
                  return DropdownMenuItem(
                    value: e.value,
                    child: Row(
                      children: [
                        Image.asset(e.value, width: 28),
                        const SizedBox(width: 10),
                        Text(e.key),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => selectedImage = value),
                validator: (v) =>
                    v == null ? "Please choose an image" : null,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: idController,
                label: "Asset ID",
                icon: Icons.qr_code,
                isId: true,
              ),
              _buildTextField(
                controller: serialController,
                label: "Serial Number",
                icon: Icons.tag,
              ),
              _buildTextField(
                controller: nameController,
                label: "Asset Name",
                icon: Icons.devices,
              ),
              _buildTextField(
                controller: brandController,
                label: "Brand",
                icon: Icons.business,
              ),

              // ============================
              // REGISTER DATE
              // ============================
              TextFormField(
                controller: registerDateController,
                readOnly: true,
                decoration: _inputDecoration("Register Date").copyWith(
                  prefixIcon:
                      const Icon(Icons.calendar_today, color: Color(0xFF004C5C)),
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
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
                decoration: _inputDecoration("Category"),
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
                decoration: _inputDecoration("Status"),
                items: const [
                  DropdownMenuItem(
                      value: "In Stock", child: Text("In Stock")),
                  DropdownMenuItem(value: "In Use", child: Text("In Use")),
                  DropdownMenuItem(
                      value: "Re-Purchased Needed",
                      child: Text("Re-Purchased Needed")),
                ],
                onChanged: (value) =>
                    setState(() => status = value!),
              ),

              const SizedBox(height: 32),

              // SAVE BUTTON
              ElevatedButton.icon(
                onPressed: saveAsset,
                icon: const Icon(Icons.save),
                label: const Text("Save Asset"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A7A7),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 42, vertical: 14),
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
  // HELPERS
  // ============================
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isId = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: _inputDecoration(label).copyWith(
          prefixIcon: Icon(icon, color: const Color(0xFF004C5C)),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return "Required field";
          if (isId && v.contains('/')) {
            return "Asset ID cannot contain '/' character";
          }
          return null;
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
