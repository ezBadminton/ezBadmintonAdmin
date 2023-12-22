import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

/// Draws a line from the top left corner of it's parent to the diagonal one in
/// an S-shaped swing.
///
/// It uses a cubic bezier segment with the control points at a thrid of the
/// parent's height.
class SLine extends StatelessWidget {
  const SLine({
    super.key,
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SLinePainter(color),
    );
  }
}

class _SLinePainter extends CustomPainter {
  _SLinePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = 2.0;

    path.cubicTo(
      0,
      size.height * 2 / 3,
      size.width,
      size.height * 1 / 3,
      size.width,
      size.height,
    );

    path = dashPath(path, dashArray: CircularIntervalList([17, 8]));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
