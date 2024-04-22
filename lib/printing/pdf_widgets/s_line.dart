import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SLine extends pw.StatelessWidget {
  SLine({
    required this.color,
    this.thickness = 2,
  });

  final PdfColor color;
  final double thickness;

  @override
  pw.Widget build(pw.Context context) {
    return pw.CustomPaint(
      painter: _painLine,
    );
  }

  void _painLine(PdfGraphics canvas, PdfPoint size) {
    canvas
      ..setColor(color)
      ..setLineWidth(thickness)
      ..setLineDashPattern([17, 8])
      ..moveTo(0, size.y)
      ..curveTo(
        0,
        size.y * 1 / 3,
        size.x,
        size.y * 2 / 3,
        size.x,
        0,
      )
      ..strokePath();
  }
}
