import 'dart:ui';

import 'package:flutter/material.dart';

/// A depiction of a badminton court
class BadmintonCourt extends CustomPaint {
  /// Set the [lineWidthScale] to multiply the true to scale line width with.
  BadmintonCourt({
    super.key,
    super.child,
    super.size = const Size(61 * 4, 134 * 4),
    double lineWidthScale = 1.0,
    Color lineColor = Colors.green,
    Color netColor = Colors.black38,
  }) : super(
          painter: _BadmintonCourtPainter(
            lineWidthScale: lineWidthScale,
            lineColor: lineColor,
            netColor: netColor,
          ),
        );
}

class _BadmintonCourtPainter extends CustomPainter {
  const _BadmintonCourtPainter({
    required this.lineWidthScale,
    required this.lineColor,
    required this.netColor,
  });

  final double lineWidthScale;
  final Color lineColor;
  final Color netColor;

  // Real life badminton court measurements in millimeters
  // relative-to-line measurements always to line center
  final int _courtWidth = 6100; // length 13400
  final double _lineWidth = 40;

  // Net to front service line
  final int _frontServiceLine = 2000;
  // Doubles service line to back of court
  final int _doublesServiceLine = 780;
  // Singles side line to side of court
  final int _singlesSideLine = 480;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / _courtWidth;
    final double net = size.height / 2.0;

    final double lineWidth = _lineWidth * scale * lineWidthScale;
    final Paint linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = lineColor
      ..strokeWidth = lineWidth;

    // Draw outer lines of court
    final Offset lineWidthCorrection = Offset(lineWidth, lineWidth);
    final Rect outerRect =
        (lineWidthCorrection / 2) & ((size - lineWidthCorrection) as Size);
    canvas.drawRect(outerRect, linePaint);

    // Front service lines
    final double frontServiceLine = _frontServiceLine * scale;
    Offset linePoint1 = Offset(1, net + frontServiceLine);
    Offset linePoint2 = Offset(size.width - 1, net + frontServiceLine);
    canvas.drawLine(linePoint1, linePoint2, linePaint);
    linePoint1 = Offset(1, net - frontServiceLine);
    linePoint2 = Offset(size.width - 1, net - frontServiceLine);
    canvas.drawLine(linePoint1, linePoint2, linePaint);

    // Center lines
    final double center = size.width / 2.0;
    linePoint1 = Offset(center, size.height - 1);
    linePoint2 = Offset(center, net + frontServiceLine);
    canvas.drawLine(linePoint1, linePoint2, linePaint);
    linePoint1 = Offset(center, 1);
    linePoint2 = Offset(center, net - frontServiceLine);
    canvas.drawLine(linePoint1, linePoint2, linePaint);

    // Doubles service lines
    final double doublesServiceLine = _doublesServiceLine * scale;
    linePoint1 = Offset(1, doublesServiceLine);
    linePoint2 = Offset(size.width - 1, doublesServiceLine);
    canvas.drawLine(linePoint1, linePoint2, linePaint);
    linePoint1 = Offset(1, size.height - doublesServiceLine);
    linePoint2 = Offset(size.width - 1, size.height - doublesServiceLine);
    canvas.drawLine(linePoint1, linePoint2, linePaint);

    // Singles side lines
    final double singlesSideLine = _singlesSideLine * scale;
    linePoint1 = Offset(singlesSideLine, 1);
    linePoint2 = Offset(singlesSideLine, size.height - 1);
    canvas.drawLine(linePoint1, linePoint2, linePaint);
    linePoint1 = Offset(size.width - singlesSideLine, 1);
    linePoint2 = Offset(size.width - singlesSideLine, size.height - 1);
    canvas.drawLine(linePoint1, linePoint2, linePaint);

    // Net
    Paint netPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = netColor
      ..strokeWidth = lineWidth * 0.75;
    linePoint1 = Offset(0, net);
    linePoint2 = Offset(size.width, net);
    int lineSegments = 33;
    List<Offset> dashedLinePoints = List.generate(
      lineSegments + 1,
      (index) => Offset.lerp(linePoint1, linePoint2, index / lineSegments)!,
    ).toList();
    canvas.drawPoints(PointMode.lines, dashedLinePoints, netPaint);
  }

  @override
  bool shouldRepaint(_BadmintonCourtPainter oldDelegate) {
    return oldDelegate.lineWidthScale != lineWidthScale;
  }
}
