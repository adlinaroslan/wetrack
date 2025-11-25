import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/asset_model.dart';

class DisposalListPage extends StatelessWidget {
  const DisposalListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Disposal List"),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('assets')
              .where('status', isEqualTo: 'Disposed')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No disposed assets found."));
            }

            final disposedAssets = snapshot.data!.docs
                .map((doc) => Asset.fromFirestore(doc))
                .toList();

            return ListView.builder(
              itemCount: disposedAssets.length,
              itemBuilder: (context, index) {
                final asset = disposedAssets[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Image.asset(
                      asset.imageUrl,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported),
                    ),
                    title: Text(asset.name),
                    subtitle: Text("ID: ${asset.id} | ${asset.brand}"),
                    trailing: const Text(
                      "Disposed",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
