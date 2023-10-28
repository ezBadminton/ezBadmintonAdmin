import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class WritingLine extends pw.StatelessWidget {
  WritingLine({
    required this.label,
    required this.width,
  });

  final String label;
  final double width;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text('$label:'),
        pw.SizedBox(width: 4),
        pw.Container(
          width: width,
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(
                color: PdfColor.fromHex('#B7B7B7'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
