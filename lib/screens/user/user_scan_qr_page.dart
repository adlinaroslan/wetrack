import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:wetrack/services/firestore_service.dart';
import 'user_request_asset.dart';
import '../../models/asset_model.dart';
import 'asset_borrowed_page.dart';

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({super.key});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  final FirestoreService _firestoreService = FirestoreService();
  String? scannedCode;
  final MobileScannerController cameraController = MobileScannerController();
  bool isNavigating = false;
  bool isFlashlightOn = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      _requestCameraPermission();
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();

    if (status.isPermanentlyDenied && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Camera access permanently denied. Please enable it in settings.'),
        ),
      );
    }
  }

  void _toggleFlashlight() {
    cameraController.toggleTorch();
    setState(() {
      isFlashlightOn = !isFlashlightOn;
    });
  }

  // ✅ UPDATED: Conditional navigation
  void _handleScan(String assetId) async {
    if (isNavigating) return;

    setState(() {
      scannedCode = assetId;
      isNavigating = true;
    });

    cameraController.stop();
    if (isFlashlightOn) {
      cameraController.toggleTorch();
      isFlashlightOn = false;
    }

    Asset? asset;
    try {
      asset = await _firestoreService.getAssetById(assetId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error fetching asset data: $e'),
              backgroundColor: Colors.red),
        );
      }
    }

    if (!mounted) return;

    if (asset != null) {
      if (asset.status == 'BORROWED') {
        // 🚨 Navigate to Borrowed Info Page
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AssetBorrowedPage(asset: asset!)),
        );
      } else {
        // ✅ Navigate to Request Asset Page
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => UserRequestAssetPage(asset: asset!)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: Asset not found for this QR code.'),
            backgroundColor: Colors.orange),
      );
    }

    setState(() {
      scannedCode = null;
      isNavigating = false;
    });
    cameraController.start();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return Scaffold(
        backgroundColor: const Color(0xFFEFF9F9),
        appBar: AppBar(
          title: const Text("Scan QR Code"),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_2, size: 80, color: Color(0xFF00A7A7)),
              SizedBox(height: 20),
              Text(
                'QR Scanner not available on Desktop',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Please use this feature on Android or iOS',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Scan Asset QR Code',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isFlashlightOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                    onPressed: _toggleFlashlight,
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.flip_camera_ios, color: Colors.white),
                    onPressed: () => cameraController.switchCamera(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      final String? code = barcodes.first.rawValue;
                      if (code != null && !isNavigating) {
                        _handleScan(code);
                      }
                    }
                  },
                ),
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF00A7A7),
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const Positioned(
                  top: 20,
                  child: Text(
                    "Align the QR code within the frame",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        backgroundColor: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: const Color(0xFFEFF9F9),
              child: Center(
                child: isNavigating
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF00A7A7)),
                          SizedBox(height: 10),
                          Text("Fetching asset details...",
                              style: TextStyle(fontSize: 16)),
                        ],
                      )
                    : const Text(
                        "Scanning for an asset...",
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
