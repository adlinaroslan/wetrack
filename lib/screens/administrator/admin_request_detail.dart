// lib/pages/admin/admin_request_detail.dart
import 'package:flutter/material.dart';
import '../../models/request_model.dart';

class AdminRequestDetailPage extends StatelessWidget {
  final AssetRequest request;
  final ValueChanged<String>? onStatusChanged;

  const AdminRequestDetailPage({
    Key? key,
    required this.request,
    this.onStatusChanged,
  }) : super(key: key);

  void _changeStatus(BuildContext context, String status) {
    if (onStatusChanged != null) onStatusChanged!(status);
    // If you want to update the passed object directly:
    // request_model uses immutable fields; update via callback
    if (onStatusChanged != null) onStatusChanged!(status);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Status changed to $status")));
    Navigator.pop(context); // go back to list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Requests"),
        backgroundColor: const Color(0xFF00BFA6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(Icons.insert_drive_file,
                          size: 36, color: Colors.teal),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        request.id,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: request.status == "Approved"
                            ? Colors.green[50]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        request.status,
                        style: TextStyle(
                          color: request.status == "Approved"
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 18),
                _keyValueRow(
                    "Date / Time",
                    request.requestedDate
                        .toLocal()
                        .toString()
                        .split('.')
                        .first),
                const Divider(),
                _keyValueRow("Asset ID", request.assetId),
                const Divider(),
                _keyValueRow("Asset Name", request.assetName),
                const Divider(),
                _keyValueRow("User Name", request.userName),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Required Date",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700])),
                ),
                const SizedBox(height: 8),
                Text(
                    request.requiredDate.toLocal().toString().split('.').first),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _changeStatus(context, "Declined"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent),
                        child: const Text("Decline"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _changeStatus(context, "Approved"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: const Text("Accept"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _keyValueRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child:
                  Text("$key", style: const TextStyle(color: Colors.black54))),
          const SizedBox(width: 8),
          Expanded(
              flex: 5,
              child: Text(":  $value",
                  style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
