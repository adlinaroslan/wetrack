import 'package:flutter/material.dart';
import '../../models/asset_model.dart';

class DisposalListPage extends StatelessWidget {
  const DisposalListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final disposedAssets = [
      Asset(
          id: 'X1001',
          name: 'Old Dell Laptop',
          brand: 'Dell',
          category: 'Laptop',
          registerDate: '01 Jan 2020',
          status: 'Disposed',
          imagePath: 'assets/images/dell.jpg'),
      Asset(
          id: 'X2002',
          name: 'Broken HDMI Cable',
          brand: 'Ugreen',
          category: 'Cable',
          registerDate: '05 Feb 2021',
          status: 'Disposed',
          imagePath: 'assets/images/hdmic.jpeg'),
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Disposed Assets"),
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: disposedAssets.length,
        itemBuilder: (context, index) {
          final asset = disposedAssets[index];
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Image.asset(asset.imagePath, height: 40),
              title: Text(asset.name),
              subtitle: Text("ID: ${asset.id} | ${asset.brand}"),
              trailing:
                  const Text("Disposed", style: TextStyle(color: Colors.red)),
            ),
          );
        },
      ),
    );
  }
}
