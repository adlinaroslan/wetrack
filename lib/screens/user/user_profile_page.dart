import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
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
        } else {
          // For web, we can't use File; keep XFile path as placeholder
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

      // reload local data
      await _loadUser();
      setState(() => _editing = false);
    } catch (e) {
      debugPrint('Save profile error: $e');
      ScaffoldMessenger.of(context)
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
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF00A7A7),
        actions: [
          if (!_loading)
            IconButton(
              icon: Icon(_editing ? Icons.check : Icons.edit),
              onPressed: () async {
                if (_editing) {
                  await _saveProfile();
                } else {
                  setState(() => _editing = true);
                }
              },
            )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFF00A7A7),
                        backgroundImage: _newImageFile != null
                            ? FileImage(_newImageFile!) as ImageProvider
                            : (_photoUrl != null && _photoUrl!.isNotEmpty)
                                ? NetworkImage(_photoUrl!)
                                : null,
                        child: (_photoUrl == null && _newImageFile == null)
                            ? const Icon(Icons.person,
                                size: 60, color: Colors.white)
                            : null,
                      ),
                      if (_editing)
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: FloatingActionButton.small(
                            onPressed: _pickImage,
                            backgroundColor: const Color(0xFF004C5C),
                            child: const Icon(Icons.camera_alt, size: 18),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoTile(
                    icon: Icons.person_outline,
                    title: 'Name',
                    child: _editing
                        ? TextField(controller: _nameCtrl)
                        : Text(
                            _nameCtrl.text.isNotEmpty ? _nameCtrl.text : '—'),
                  ),
                  _buildInfoTile(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    child: Text(_user?.email ?? '—'),
                  ),
                  _buildInfoTile(
                    icon: Icons.phone_outlined,
                    title: 'Phone',
                    child: _editing
                        ? TextField(controller: _phoneCtrl)
                        : Text(
                            _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : '—'),
                  ),
                  _buildInfoTile(
                    icon: Icons.business_outlined,
                    title: 'Department/Role',
                    child: _editing
                        ? TextField(controller: _deptCtrl)
                        : Text(
                            _deptCtrl.text.isNotEmpty ? _deptCtrl.text : '—'),
                  ),
                  const SizedBox(height: 24),
                  if (_editing)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _editing = false;
                              _newImageFile = null;
                              _loadUser();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00A7A7)),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile(
      {required IconData icon, required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF00A7A7)),
        title: Text(title),
        subtitle: child,
      ),
    );
  }
}
