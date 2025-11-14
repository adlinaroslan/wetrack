import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';
import '../services/firestore_service.dart';

class EditRequestPage extends StatefulWidget {
  final AssetRequest request;

  const EditRequestPage({super.key, required this.request});

  @override
  State<EditRequestPage> createState() => _EditRequestPageState();
}

class _EditRequestPageState extends State<EditRequestPage> {
  late TextEditingController _requiredDateController;
  late String _status;
  final FirestoreService _fs = FirestoreService();

  @override
  void initState() {
    super.initState();
    _requiredDateController = TextEditingController(
        text: widget.request.requiredDate.toIso8601String().split('T').first);
    _status = widget.request.status;
  }

  @override
  void dispose() {
    _requiredDateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      final parsed = DateTime.parse(_requiredDateController.text);
      await _fs.updateRequest(widget.request.id, {
        'requiredDate': Timestamp.fromDate(parsed),
        'status': _status,
      });

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Request')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Asset: ${widget.request.assetName}'),
            const SizedBox(height: 12),
            TextField(
              controller: _requiredDateController,
              decoration: const InputDecoration(
                labelText: 'Required Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              items: const [
                DropdownMenuItem(value: 'PENDING', child: Text('PENDING')),
                DropdownMenuItem(value: 'APPROVED', child: Text('APPROVED')),
                DropdownMenuItem(value: 'REJECTED', child: Text('REJECTED')),
              ],
              onChanged: (v) => setState(() => _status = v ?? _status),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
