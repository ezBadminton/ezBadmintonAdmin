import 'package:ez_badminton_admin_app/widgets/line_painters/bent_line.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class BentLine extends pw.StatelessWidget {
  BentLine({
    required this.bendCorner,
    required this.bendRadius,
    required this.thickness,
    required this.color,
  });

  final Corner bendCorner;
  final double bendRadius;

  final double thickness;
  final PdfColor color;

  @override
  pw.Widget build(pw.Context context) {
    return pw.CustomPaint(
      painter: paintLine,
    );
  }

  void paintLine(PdfGraphics canvas, PdfPoint size) {
    (PdfPoint, PdfPoint, PdfPoint, PdfPoint) linePoints = _getLinePoints(size);
    (PdfPoint, PdfPoint) arcPoints = _getArcPoints(size);

    canvas
      ..setColor(color)
      ..setLineWidth(thickness)
      ..drawLine(
        linePoints.$1.x,
        linePoints.$1.y,
        linePoints.$2.x,
        linePoints.$2.y,
      )
      ..drawLine(
        linePoints.$3.x,
        linePoints.$3.y,
        linePoints.$4.x,
        linePoints.$4.y,
      )
      ..moveTo(
        arcPoints.$1.x,
        arcPoints.$1.y,
      )
      ..bezierArc(
        arcPoints.$1.x,
        arcPoints.$1.y,
        bendRadius,
        bendRadius,
        arcPoints.$2.x,
        arcPoints.$2.y,
      )
      ..strokePath();
  }

  (PdfPoint, PdfPoint, PdfPoint, PdfPoint) _getLinePoints(PdfPoint size) {
    switch (bendCorner) {
      case Corner.topLeft:
        return (
          PdfPoint.zero,
          PdfPoint(0, size.y - bendRadius),
          PdfPoint(bendRadius, size.y),
          size,
        );
      case Corner.topRight:
        return (
          PdfPoint(size.x, 0),
          PdfPoint(size.x, size.y - bendRadius),
          PdfPoint(size.x - bendRadius, size.y),
          PdfPoint(0, size.y),
        );
      case Corner.bottomLeft:
        return (
          PdfPoint(0, size.y),
          PdfPoint(0, bendRadius),
          PdfPoint(bendRadius, 0),
          PdfPoint(size.x, 0),
        );
      case Corner.bottomRight:
        return (
          PdfPoint.zero,
          PdfPoint(size.x - bendRadius, 0),
          PdfPoint(size.x, bendRadius),
          size,
        );
    }
  }

  (PdfPoint, PdfPoint) _getArcPoints(PdfPoint size) {
    switch (bendCorner) {
      case Corner.topLeft:
        return (
          PdfPoint(0, size.y - bendRadius),
          PdfPoint(bendRadius, size.y),
        );
      case Corner.topRight:
        return (
          PdfPoint(size.x - bendRadius, size.y),
          PdfPoint(size.x, size.y - bendRadius),
        );
      case Corner.bottomLeft:
        return (
          PdfPoint(bendRadius, 0),
          PdfPoint(0, bendRadius),
        );
      case Corner.bottomRight:
        return (
          PdfPoint(size.x, bendRadius),
          PdfPoint(size.x - bendRadius, 0),
        );
    }
  }
}
