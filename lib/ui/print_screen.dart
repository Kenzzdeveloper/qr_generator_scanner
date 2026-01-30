import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:permission_handler/permission_handler.dart';
import '../store/qr_store.dart';

const Color primaryColor = Color(0xFF3A2EC3);
const Color bgColor = Color(0xFFF6F7FB);

class PrintScreen extends StatefulWidget {
  const PrintScreen({super.key});

  @override
  State<PrintScreen> createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  Uint8List? _imageBytes;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _imageBytes = QrStore.instance.lastQrImage;
  }

  /// Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        _showSnack('Gallery permission denied');
        return;
      }

      final picker = ImagePicker();
      final XFile? file =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);

      if (file == null) return;

      final bytes = await file.readAsBytes();
      setState(() => _imageBytes = bytes);
    } catch (e) {
      _showSnack('Error: $e');
    }
  }

  /// Generate PDF
  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    final image =
        _imageBytes != null ? pw.MemoryImage(_imageBytes!) : null;

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (_) => pw.Center(
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                'QR S&G',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              if (image != null)
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  child: pw.Image(
                    image,
                    width: 200,
                    height: 200,
                    fit: pw.BoxFit.contain,
                  ),
                ),
              pw.SizedBox(height: 24),
              pw.Text(
                'Generated from Flutter',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );

    return pdf.save();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Print QR'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Preview Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _imageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              _imageBytes!,
                              fit: BoxFit.contain,
                            ),
                          )
                        : const Center(
                            child: Text(
                              'No image selected',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'QR Preview',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// Gallery Button (Secondary)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.image, color: primaryColor),
                label: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: primaryColor),
                ),
                onPressed: _pickImage,
              ),
            ),

            const SizedBox(height: 12),

            /// Print Button (Primary)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: primaryColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _imageBytes == null || _isPrinting
                    ? null
                    : () async {
                        setState(() => _isPrinting = true);
                        await Printing.layoutPdf(
                          onLayout: (format) =>
                              _generatePdf(format),
                        );
                        setState(() => _isPrinting = false);
                      },
                child: _isPrinting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.print),
                          SizedBox(width: 8),
                          Text(
                            'Print QR',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
