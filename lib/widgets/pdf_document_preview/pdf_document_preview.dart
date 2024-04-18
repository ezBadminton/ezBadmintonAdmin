import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfDocumentPreview extends StatelessWidget {
  const PdfDocumentPreview({
    super.key,
    this.document,
  });

  final pw.Document? document;

  @override
  Widget build(BuildContext context) {
    Future<Uint8List> pdfBytes =
        document != null ? document!.save() : pw.Document().save();

    return PdfPreview(
      allowPrinting: false,
      allowSharing: false,
      canChangeOrientation: false,
      canChangePageFormat: false,
      build: (format) => pdfBytes,
    );
  }
}
