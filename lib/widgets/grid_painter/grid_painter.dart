import 'package:flutter/material.dart';

class DecorativeGrid extends StatelessWidget {
  const DecorativeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(
        lineSpacing: 80,
        backgroudColor: const Color.fromARGB(255, 52, 79, 148),
        lineColor: const Color.fromARGB(255, 63, 94, 173),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({
    required this.backgroudColor,
    required this.lineColor,
    required this.lineSpacing,
  });

  final Color backgroudColor;
  final Color lineColor;
  final int lineSpacing;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()..color = backgroudColor;

    final Paint thickLinePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2;

    final Paint thinLinePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    final Rect rect = Offset.zero & size;

    canvas.drawRect(rect, backgroundPaint);

    for (double i = 0; i < size.width; i += lineSpacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), thickLinePaint);
    }
    for (double i = 0; i < size.height; i += lineSpacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), thickLinePaint);
    }

    for (double i = lineSpacing * 0.5; i < size.width; i += lineSpacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), thinLinePaint);
    }
    for (double i = lineSpacing * 0.5; i < size.height; i += lineSpacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), thinLinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
