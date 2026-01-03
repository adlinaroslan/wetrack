import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/asset_model.dart';

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({super.key});

  @override
  State<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  String selectedYear = DateTime.now().year.toString();
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());

  late final List<String> years = List.generate(
    DateTime.now().year - 2020 + 1,
    (index) => (2020 + index).toString(),
  );

  final List<String> months = const [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December'
  ];

  Stream<List<Asset>> get assetsStream {
    return FirebaseFirestore.instance
        .collection('assets')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final asset = Asset.fromFirestore(doc);

              // Optional: fallback for borrowDate/returnDate if not stored
              final data = doc.data() as Map<String, dynamic>;
              final borrowTs = data['borrowDate'];
              final returnTs = data['returnDate'];
              final createdTs = data['createdAt'];

              return Asset(
                docId: asset.docId,
                id: asset.id,
                serialNumber: asset.serialNumber,
                name: asset.name,
                brand: asset.brand,
                category: asset.category,
                imageUrl: asset.imageUrl,
                location: asset.location,
                status: asset.status,
                registerDate: asset.registerDate,
                borrowedByUserId: asset.borrowedByUserId,
                dueDateTime: asset.dueDateTime,
                borrowDate: borrowTs != null && borrowTs is Timestamp
                    ? borrowTs.toDate()
                    : null,
                returnDate: returnTs != null && returnTs is Timestamp
                    ? returnTs.toDate()
                    : null,
                createdAt: createdTs != null && createdTs is Timestamp
                    ? createdTs.toDate()
                    : null,
              );
            }).toList());
  }

  Future<void> _generatePdf(List<Asset> assets) async {
    final pdf = pw.Document();
    final formatter = DateFormat('dd MMM yyyy');

    // 🔹 Filter by createdAt timestamp to get activities for selected month
    final filtered = assets.where((a) {
      final timestamp = a.createdAt ?? (a.registerDate != null ? 
          DateFormat('dd MMM yyyy').parse(a.registerDate!) : null);
      
      if (timestamp == null) return false;
      
      return DateFormat('yyyy').format(timestamp) == selectedYear &&
             DateFormat('MMMM').format(timestamp) == selectedMonth;
    }).toList();

    // 🔹 Sort by timestamp descending (newest first)
    filtered.sort((a, b) {
      final timeA = a.createdAt ?? (a.registerDate != null ? 
          DateFormat('dd MMM yyyy').parse(a.registerDate!) : DateTime(2000));
      final timeB = b.createdAt ?? (b.registerDate != null ? 
          DateFormat('dd MMM yyyy').parse(b.registerDate!) : DateTime(2000));
      return timeB.compareTo(timeA);
    });

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Text(
            'Asset Activity Report – $selectedMonth $selectedYear',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: ['Timestamp', 'Asset ID', 'Name', 'Status', 'Register Date', 'Borrow Date', 'Return Date'],
            data: filtered.map((a) {
              final timestamp = a.createdAt ?? (a.registerDate != null ? 
                  DateFormat('dd MMM yyyy').parse(a.registerDate!) : null);
              
              return [
                timestamp != null ? formatter.format(timestamp) : '-',
                a.id,
                a.name,
                a.status,
                a.registerDate ?? '-',
                a.borrowDate != null ? formatter.format(a.borrowDate!) : '-',
                a.returnDate != null ? formatter.format(a.returnDate!) : '-',
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Asset Report', style: TextStyle(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Year Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Year',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: DropdownButton<String>(
                    value: selectedYear,
                    underline: const SizedBox(),
                    items: years
                        .map((y) => DropdownMenuItem(
                              value: y,
                              child: Text(y, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => selectedYear = v!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Month Buttons Grid
            Expanded(
              child: GridView.builder(
                itemCount: months.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.2,
                ),
                itemBuilder: (context, index) {
                  final month = months[index];
                  final isSelected = selectedMonth == month;

                  return GestureDetector(
                    onTap: () => setState(() => selectedMonth = month),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFF00A7A7), Color(0xFF004C5C)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : const LinearGradient(colors: [Colors.white, Colors.white]),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        month,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Download Button
            SizedBox(
              width: double.infinity,
              child: StreamBuilder<List<Asset>>(
                stream: assetsStream,
                builder: (context, snapshot) {
                  final assets = snapshot.data ?? [];

                  return ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: Text(
                      'Download $selectedMonth $selectedYear Report (PDF)',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF004C5C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: assets.isEmpty
                        ? null
                        : () => _generatePdf(assets),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
