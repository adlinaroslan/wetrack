import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TechnicianScanPage extends StatefulWidget {
  const TechnicianScanPage({super.key});

  @override
  State<TechnicianScanPage> createState() => _TechnicianScanPageState();
}

class _TechnicianScanPageState extends State<TechnicianScanPage> {
  String? scannedCode;
  bool isScanning = true;
  final MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: const Color(0xFF00BFA6),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch, color: Colors.white),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // ✅ Use the SAME controller instance here
          MobileScanner(
            controller: cameraController,
            onDetect: (BarcodeCapture capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (isScanning && barcode.rawValue != null) {
                  setState(() => isScanning = false);
                  _showResultDialog(barcode.rawValue!);
                  break;
                }
              }
            },
          ),

          // ✅ Square border overlay
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // ✅ Instruction text
          const Positioned(
            bottom: 100,
            child: Text(
              "Align QR code within the box",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Scanned'),
        content: Text('Data: $code'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => isScanning = true);
            },
            child: const Text('Scan Again'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
