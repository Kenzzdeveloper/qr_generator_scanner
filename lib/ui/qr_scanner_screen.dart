import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: true,
    formats: [BarcodeFormat.qrCode],
  );

  String? _barcodeValue;

  late final AnimationController _scanAnimController;
  late final Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
    WidgetsBinding.instance.addObserver(this);

    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0, end: 260).animate(
      CurvedAnimation(parent: _scanAnimController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const ScanGuideBottomSheet(),
      );
    });
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (!status.isGranted) {
      final result = await Permission.camera.request();
      if (!result.isGranted && result.isPermanentlyDenied) {
        openAppSettings();
      }
    } else {
      _controller.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanAnimController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    if (state == AppLifecycleState.inactive) {
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      _controller.start();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          'Scan QR Code',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
            placeholderBuilder: (_) =>
                const Center(child: CircularProgressIndicator()),
          ),

          Container(color: const Color.fromARGB(255, 0, 102, 255).withOpacity(0.35)),

          Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(280, 280),
                    painter: ScannerOverlayPainter(),
                  ),
                  AnimatedBuilder(
                    animation: _scanLineAnimation,
                    builder: (_, __) => Positioned(
                      top: _scanLineAnimation.value,
                      left: 12,
                      right: 12,
                      child: Container(
                        height: 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.lightBlueAccent,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Arahkan QR Code ke dalam kotak',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBarcode(BarcodeCapture capture) {
    final Uint8List? image = capture.image;
    final barcode = capture.barcodes.firstOrNull;

    if (barcode != null && barcode.rawValue != null && image != null) {
      _controller.stop();
      setState(() => _barcodeValue = barcode.rawValue);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('QR Terdeteksi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.memory(image, height: 180),
              const SizedBox(height: 16),
              SelectableText(
                _barcodeValue!,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Copy'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _barcodeValue!));
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Disalin ke clipboard')),
                );
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.close),
              label: const Text('Tutup'),
              onPressed: () {
                Navigator.pop(ctx);
                _controller.start();
              },
            ),
          ],
        ),
      );
    }
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5;

    const cornerLength = 30.0;
    final path = Path();

    path
      ..moveTo(0, cornerLength)
      ..lineTo(0, 0)
      ..lineTo(cornerLength, 0)
      ..moveTo(size.width - cornerLength, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, cornerLength)
      ..moveTo(0, size.height - cornerLength)
      ..lineTo(0, size.height)
      ..lineTo(cornerLength, size.height)
      ..moveTo(size.width - cornerLength, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height - cornerLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

    class ScanGuideBottomSheet extends StatelessWidget {
      const ScanGuideBottomSheet({super.key});

      @override
      Widget build(BuildContext context) {
        return AnimatedScale(
          scale: 1,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Scan QR Code',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Arahkan kamera ke QR Code di dalam kotak.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Image.asset(
                  'assets/images/scan-icon.png',
                  width: 180,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Mulai Scan'),
                ),
              ],
            ),
          ),
        );
      }
    }
