import 'dart:typed_data';

class QrHistory {
  final String title;
  final String date;
  final String type;
  final Uint8List imageBytes;

  QrHistory({
    required this.title,
    required this.date,
    required this.type,
    required this.imageBytes,
  });
}

class QrStore {
  QrStore._privateConstructor();
  static final QrStore instance = QrStore._privateConstructor();

  // Simpan satu gambar terakhir (untuk fitur print langsung)
  Uint8List? lastQrImage;

  // Daftar history untuk ditampilkan di Setting Screen
  List<QrHistory> historyList = [];

  // Fungsi untuk menambah history baru
  void addHistory(String title, String type, Uint8List image) {
    historyList.insert(0, QrHistory(
      title: title,
      type: type,
      date: "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
      imageBytes: image,
    ));
  }
}
