import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'user_asset_details.dart';

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({super.key});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  String? scannedCode;
  final MobileScannerController cameraController = MobileScannerController();
  bool isNavigating = false;
  // State variable to track the flashlight status
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

  // --- Flashlight Toggle Method ---
  void _toggleFlashlight() {
    // Call the controller's toggleTorch method
    cameraController.toggleTorch();
    setState(() {
      // Update the local state to change the icon
      isFlashlightOn = !isFlashlightOn;
    });
  }
  // ---------------------------------

  void _handleScan(String code) {
    if (!isNavigating) {
      setState(() {
        scannedCode = code;
        isNavigating = true;
      });

      // Stop the camera and turn off the torch before navigating
      cameraController.stop();
      if (isFlashlightOn) {
        cameraController.toggleTorch();
        isFlashlightOn = false;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AssetDetailsPage(
            assetName: "Scanned Asset",
            assetId: code,
          ),
        ),
      ).then((_) {
        // This runs when the user returns from the AssetDetailsPage
        setState(() {
          scannedCode = null;
          isNavigating = false;
        });
        cameraController.start();
      });
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show message on desktop platforms
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

    // Mobile (Android/iOS) UI
    return Scaffold(
      backgroundColor: const Color(0xFFEFF9F9),
      appBar: AppBar(
        title: const Text("Scan QR Code"),
        actions: [
          // 1. Flashlight/Torch Button
          IconButton(
            icon: Icon(
              isFlashlightOn
                  ? Icons.flash_on
                  : Icons.flash_off, // Dynamic icon change
              color: Colors.white,
            ),
            onPressed: _toggleFlashlight,
          ),
          // 2. Camera Flip Button
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
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
                      if (code != null) {
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
            child: Center(
              child: isNavigating
                  ? const CircularProgressIndicator(color: Color(0xFF00A7A7))
                  : const Text(
                      "Scanning for an asset...",
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
