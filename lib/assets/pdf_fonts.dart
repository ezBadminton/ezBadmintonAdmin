import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

/// Font loader singleton
class PdfFonts {
  static PdfFonts? _instance;

  factory PdfFonts() {
    if (_instance == null) {
      throw Exception(
        "PdfFonts have not been initialized. Call PdfFonts.ensureInitialized() before accessing the singleton.",
      );
    }

    return _instance!;
  }

  static Future<void> ensureInitialized() {
    PdfFonts._instance ??= PdfFonts._();

    return PdfFonts._instance!._loaded;
  }

  PdfFonts._() {
    _loaded = Future.wait([
      _loadFont('fonts/Inter/Inter-Regular.ttf').then(
        (font) => interNormal = font,
      ),
      _loadFont('fonts/Inter/Inter-Bold.ttf').then(
        (font) => interBold = font,
      ),
    ]);
  }

  late final Future<void> _loaded;

  late final pw.Font interNormal;
  late final pw.Font interBold;

  Future<pw.Font> _loadFont(String assetKey) async {
    final ByteData binaryFont = await rootBundle.load(assetKey);
    final pw.Font font = pw.Font.ttf(binaryFont);

    return font;
  }
}
