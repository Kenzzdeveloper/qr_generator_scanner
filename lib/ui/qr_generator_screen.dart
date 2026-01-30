import 'dart:io'; 
import 'package:path_provider/path_provider.dart'; 
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../store/qr_store.dart';

const Color primaryColor = Color(0xFF3A2EC3);

const List<Color> qrColors = [
  Colors.white,
  Colors.grey,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.cyan,
];

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  String? _qrData;
  Color _qrColor = Colors.white;

  // 🔹 QR TYPE (PNG / PDF / SVG)
  String _qrType = 'PNG';
  final List<String> qrTypes = ['PNG', 'PDF', 'SVG'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create QR', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(height: 220, color: primaryColor),
              Expanded(child: Container(color: Colors.grey.shade50)),
            ],
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Screenshot(
                          controller: _screenshotController,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _qrColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.black12,
                                width: 2,
                              ),
                            ),
                            child: _qrData == null || _qrData!.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(40),
                                    child: Text(
                                      'Masukkan teks/link untuk generate QR',
                                      style: TextStyle(color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : PrettyQrView.data(
                                    data: _qrData!,
                                    decoration: const PrettyQrDecoration(
                                      shape: PrettyQrSmoothSymbol(),
                                    ),
                                  ),
                                ),
                              ),

                        const SizedBox(height: 32),

                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Link atau Teks',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          onChanged: (v) {
                            setState(() {
                              _qrData = v.trim().isEmpty ? null : v.trim();
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // 🔹 QR TYPE DROPDOWN
                        DropdownButtonFormField<String>(
                          value: _qrType,
                          items: qrTypes
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _qrType = v!),
                          decoration: InputDecoration(
                            labelText: 'QR Code Type',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Wrap(
                          spacing: 15,
                          children: qrColors.map((c) {
                            return GestureDetector(
                              onTap: () => setState(() => _qrColor = c),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _qrColor == c
                                        ? Colors.black
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 30),

                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          alignment: WrapAlignment.center,
                          children: [
                            _actionButton(
                              label: 'Reset',
                              icon: Icons.refresh,
                              color: Colors.white,
                              textColor: Colors.red,
                              borderColor: Colors.red,
                              onTap: () {
                                setState(() {
                                  _qrData = null;
                                  _qrColor = Colors.white;
                                });
                              },
                            ),
                            _actionButton(
                              label: 'Share',
                              icon: Icons.share,
                              color: primaryColor,
                              textColor: Colors.white,
                              onTap: _shareQr,
                            ),
                            _actionButton(
                              label: 'Download',
                              icon: Icons.download,
                              color: Colors.green,
                              textColor: Colors.white,
                              onTap: _downloadQr,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 95,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: borderColor != null
                ? BorderSide(color: borderColor)
                : BorderSide.none,
          ),
        ),
        child: FittedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }


Future<void> _saveFile(Uint8List bytes, String fileName) async {
  Directory? directory;

  if (Platform.isAndroid) {
    // Untuk Android tetap ke folder Download
    directory = Directory('/storage/emulated/0/Download');
  } else if (Platform.isIOS) {
    // UNTUK iOS: Gunakan Application Documents agar muncul di aplikasi "Files"
    directory = await getApplicationDocumentsDirectory();
  }

  if (directory != null) {
    final String filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Berhasil disimpan ke: $filePath")),
    );
  }
}

  Future<void> _shareQr() async {
    if (_qrData == null || _qrData!.isEmpty) return;

    await Future.delayed(const Duration(milliseconds: 200));

    final Uint8List? imageBytes = await _screenshotController.capture(
      pixelRatio: MediaQuery.of(context).devicePixelRatio,
    );

    if (imageBytes == null) return;

    await Share.shareXFiles([
      XFile.fromData(imageBytes, name: 'qr_$DateTime.timestamp().png', mimeType: 'image/png'),
    ]);
  }

  Future<void> _downloadQr() async {
  if (_qrData == null) return;

  final Uint8List? imageBytes = await _screenshotController.capture();
  if (imageBytes == null) return;

  // Simpan ke Store
  QrStore.instance.lastQrImage = imageBytes;
  QrStore.instance.addHistory(_qrData!, _qrType, imageBytes);

  // PANGGIL LOGIKA SIMPAN SESUAI OS
  if (_qrType == 'PNG') {
    await _saveFile(imageBytes, 'qr_code_${DateTime.now().millisecondsSinceEpoch}.png');
  } else if (_qrType == 'PDF') {
    // ... (Logika generate PDF Anda tetap sama, lalu panggil _saveFile)
    // await _saveFile(pdfBytes, 'qr_code.pdf');
  }
}

}
