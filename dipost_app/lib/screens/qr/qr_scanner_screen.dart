import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  final Function(String) onScanComplete;

  const QRScannerScreen({super.key, required this.onScanComplete});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _cameraAvailable = true;

  @override
  void initState() {
    super.initState();
    _checkCameraStatus();
  }

  Future<void> _checkCameraStatus() async {
    // Vérifie si la caméra est disponible sans demander de permission
    final hasCamera = await cameraController.hasTorch;
    setState(() {
      _cameraAvailable = hasCamera;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: _buildScannerContent(),
    );
  }

  Widget _buildScannerContent() {
    if (!_cameraAvailable) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 64),
            SizedBox(height: 16),
            Text('Caméra non disponible'),
            SizedBox(height: 8),
            Text('Vérifiez les permissions dans les paramètres'),
          ],
        ),
      );
    }

    return MobileScanner(
      controller: cameraController,
      onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;
        for (final barcode in barcodes) {
          if (barcode.rawValue != null) {
            widget.onScanComplete(barcode.rawValue!);
            Navigator.pop(context);
            break;
          }
        }
      },
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}