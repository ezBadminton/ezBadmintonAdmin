import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:pdf/widgets.dart' as pw;

final String fontDirPath = p.join(Directory.current.path, 'fonts');

/// Font loader singleton
class PdfFonts {
  static PdfFonts? _instance;

  factory PdfFonts() {
    _instance ??= PdfFonts._();

    return _instance!;
  }

  PdfFonts._()
      : interNormal =
            _loadFont(p.join(fontDirPath, 'Inter', 'Inter-Regular.ttf')),
        interBold = _loadFont(p.join(fontDirPath, 'Inter', 'Inter-Bold.ttf'));

  final pw.Font interNormal;
  final pw.Font interBold;

  static pw.Font _loadFont(String path) {
    final Uint8List fontData = File(path).readAsBytesSync();
    final pw.Font font = pw.Font.ttf(fontData.buffer.asByteData());

    return font;
  }
}
