import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Placeholder for navigation targets to prevent errors
// Replace these with your actual imports
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text('Placeholder for $title')),
      );
}

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  // --- Firebase & Logic Variables ---
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  User? _user;
  Map<String, dynamic>? _userData;
  bool _loading = true;
  bool _editing = false;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _deptCtrl = TextEditingController();

  File? _newImageFile;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _loading = true);
    _user = _auth.currentUser;
    if (_user != null) {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      _userData = doc.exists ? doc.data() : null;
      _nameCtrl.text = _userData?['displayName'] ?? _user!.displayName ?? '';
      _phoneCtrl.text = _userData?['phone'] ?? '';
      _deptCtrl.text = _userData?['department'] ?? _userData?['role'] ?? '';
      _photoUrl = _userData?['photoUrl'] ?? _user?.photoURL;
    }
    setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 80,
      );
      if (picked != null) {
        if (!kIsWeb) {
          _newImageFile = File(picked.path);
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  Future<String?> _uploadProfileImage(File file) async {
    if (_user == null) return null;
    final ref = _storage.ref().child('profile_pics').child('${_user!.uid}.jpg');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    final url = await snapshot.ref.getDownloadURL();
    return url;
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = true);
    try {
      String? photoUrl = _photoUrl;
      if (_newImageFile != null) {
        final uploaded = await _uploadProfileImage(_newImageFile!);
        if (uploaded != null) photoUrl = uploaded;
      }

      final updates = {
        'displayName': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'department': _deptCtrl.text.trim(),
        'photoUrl': photoUrl,
      }..removeWhere((key, value) => value == null);

      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .set(updates, SetOptions(merge: true));

      await _user!.updateDisplayName(_nameCtrl.text.trim());
      if (photoUrl != null) {
        await _user!.updatePhotoURL(photoUrl);
      }

      await _loadUser();
      if (!mounted) return;
      setState(() => _editing = false);
      messenger.showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')));
    } catch (e) {
      debugPrint('Save profile error: $e');
      messenger
          .showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _deptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF9F9), // Matches message.dart bg

      // --- CUSTOM GRADIENT APP BAR START ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Navigation Icons matching message.dart style
                  IconButton(
                    icon: const Icon(Icons.message, color: Colors.white),
                    onPressed: () {
                      // Navigate to Messages
                      // Navigator.push(...)
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      // Navigate to Notifications
                    },
                  ),
                  // Person Icon (Highlighted as we are on Profile)
                  IconButton(
                    icon: const Icon(
                      Icons.person,
                      color:
                          Color(0xFFEFF9F9), // Lighter color for active state
                    ),
                    onPressed: () {}, // Already on Profile
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // --- CUSTOM GRADIENT APP BAR END ---

      // Floating Action Button to Handle Edit/Save State
      floatingActionButton: _loading
          ? null
          : FloatingActionButton(
              onPressed: () async {
                if (_editing) {
                  await _saveProfile();
                } else {
                  setState(() => _editing = true);
                }
              },
              backgroundColor: const Color(0xFF004C5C),
              child: Icon(_editing ? Icons.check : Icons.edit,
                  color: Colors.white),
            ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF00A7A7), width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ]),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _newImageFile != null
                              ? FileImage(_newImageFile!) as ImageProvider
                              : (_photoUrl != null && _photoUrl!.isNotEmpty)
                                  ? NetworkImage(_photoUrl!)
                                  : null,
                          child: (_photoUrl == null && _newImageFile == null)
                              ? const Icon(Icons.person,
                                  size: 60, color: Color(0xFF00A7A7))
                              : null,
                        ),
                      ),
                      if (_editing)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: FloatingActionButton.small(
                            onPressed: _pickImage,
                            backgroundColor: const Color(0xFF004C5C),
                            child: const Icon(Icons.camera_alt,
                                size: 18, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildInfoTile(
                    icon: Icons.person_outline,
                    title: 'Name',
                    isEditing: _editing,
                    controller: _nameCtrl,
                    fallbackText: '—',
                  ),
                  _buildInfoTile(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    isEditing: false, // Email usually not editable directly
                    textValue: _user?.email ?? '—',
                  ),
                  _buildInfoTile(
                    icon: Icons.phone_outlined,
                    title: 'Phone',
                    isEditing: _editing,
                    controller: _phoneCtrl,
                    fallbackText: '—',
                  ),
                  _buildInfoTile(
                    icon: Icons.business_outlined,
                    title: 'Department/Role',
                    isEditing: _editing,
                    controller: _deptCtrl,
                    fallbackText: '—',
                  ),
                  const SizedBox(height: 24),

                  if (_editing)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _editing = false;
                          _newImageFile = null;
                          _loadUser(); // Reset changes
                        });
                      },
                      icon: const Icon(Icons.close, color: Colors.grey),
                      label: const Text('Cancel Editing',
                          style: TextStyle(color: Colors.grey)),
                    ),

                  const SizedBox(height: 80), // Space for FAB and BottomNav
                ],
              ),
            ),

      // --- BOTTOM NAVIGATION BAR START ---
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: 0, // Assuming functionality or make this dynamic
              selectedItemColor: Colors.white,
              unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_scanner),
                  label: 'Scan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.logout),
                  label: 'Logout',
                ),
              ],
              onTap: (index) async {
                if (index == 0) {
                  Navigator.pop(context); // Go back Home
                } else if (index == 1) {
                  // Navigate to Scan
                } else if (index == 2) {
                  await _auth.signOut();
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
      // --- BOTTOM NAVIGATION BAR END ---
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required bool isEditing,
    TextEditingController? controller,
    String? textValue,
    String fallbackText = '—',
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00A7A7).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF00A7A7)),
        ),
        title: Text(title,
            style: const TextStyle(fontSize: 14, color: Colors.grey)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: isEditing && controller != null
              ? TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF00A7A7)))),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF004C5C)),
                )
              : Text(
                  (controller != null ? controller.text : textValue)!.isNotEmpty
                      ? (controller != null ? controller.text : textValue!)
                      : fallbackText,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
        ),
      ),
    );
  }
}
