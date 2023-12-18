import 'dart:math';

import 'package:flutter/material.dart';

class BentLine extends StatelessWidget {
  /// Draws a line along two adjacent sides of the parent with a rounded
  /// bend connecting them. The given [bendCorner] dictates where the lines meet
  /// and form the bend.
  const BentLine({
    super.key,
    required this.bendCorner,
    required this.bendRadius,
    required this.thickness,
    required this.color,
  });

  final Corner bendCorner;
  final double bendRadius;

  final double thickness;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BentLinePainter(
        bendCorner: bendCorner,
        bendRadius: bendRadius,
        thickness: thickness,
        color: color,
      ),
    );
  }
}

class _BentLinePainter extends CustomPainter {
  _BentLinePainter({
    required this.bendCorner,
    required this.bendRadius,
    required this.thickness,
    required this.color,
  });

  final Corner bendCorner;
  final double bendRadius;

  final double thickness;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = thickness;

    Path linePath = Path();
    Corner lineStart = _getLineStart(bendCorner);
    if (lineStart == Corner.bottomLeft) {
      linePath.moveTo(0, size.height);
    }
    _drawLineInDirection(
      linePath,
      _getFirstLineDirection(bendCorner),
      bendRadius,
      size,
    );
    _drawBend(linePath, bendCorner, bendRadius, size);
    _drawLineInDirection(
      linePath,
      _getSecondLineDirection(bendCorner),
      bendRadius,
      size,
    );

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  void _drawLineInDirection(
    Path path,
    AxisDirection direction,
    double bendRadius,
    Size canvasSize,
  ) {
    double length = switch (direction) {
      AxisDirection.left ||
      AxisDirection.right =>
        canvasSize.width - bendRadius,
      AxisDirection.up || AxisDirection.down => canvasSize.height - bendRadius,
    };

    switch (direction) {
      case AxisDirection.left:
        path.relativeLineTo(-length, 0);
        break;
      case AxisDirection.right:
        path.relativeLineTo(length, 0);
        break;
      case AxisDirection.up:
        path.relativeLineTo(0, -length);
        break;
      case AxisDirection.down:
        path.relativeLineTo(0, length);
        break;
    }
  }

  void _drawBend(
    Path path,
    Corner bendCorner,
    double bendRadius,
    Size canvasSize,
  ) {
    // 90 degree angle
    double sweepAngle = 2 * pi / 4;
    switch (bendCorner) {
      case Corner.topLeft:
        path.addArc(
          Rect.fromCircle(
            center: Offset(
              bendRadius,
              bendRadius,
            ),
            radius: bendRadius,
          ),
          pi,
          sweepAngle,
        );
        break;
      case Corner.topRight:
        path.addArc(
          Rect.fromCircle(
            center: Offset(
              canvasSize.width - bendRadius,
              bendRadius,
            ),
            radius: bendRadius,
          ),
          3 * pi / 2,
          sweepAngle,
        );
        break;
      case Corner.bottomLeft:
        path.addArc(
          Rect.fromCircle(
            center: Offset(
              bendRadius,
              canvasSize.height - bendRadius,
            ),
            radius: bendRadius,
          ),
          pi,
          -sweepAngle,
        );
        break;
      case Corner.bottomRight:
        path.addArc(
          Rect.fromCircle(
            center: Offset(
              canvasSize.width - bendRadius,
              canvasSize.height - bendRadius,
            ),
            radius: bendRadius,
          ),
          pi / 2,
          -sweepAngle,
        );
        break;
    }
  }

  Corner _getLineStart(Corner bendCorner) {
    switch (bendCorner) {
      case Corner.topRight:
      case Corner.bottomLeft:
        return Corner.topLeft;
      case Corner.topLeft:
      case Corner.bottomRight:
        return Corner.bottomLeft;
    }
  }

  AxisDirection _getFirstLineDirection(Corner bendCorner) {
    switch (bendCorner) {
      case Corner.topLeft:
        return AxisDirection.up;
      case Corner.bottomLeft:
        return AxisDirection.down;
      case Corner.topRight:
      case Corner.bottomRight:
        return AxisDirection.right;
    }
  }

  AxisDirection _getSecondLineDirection(Corner bendCorner) {
    switch (bendCorner) {
      case Corner.topLeft:
      case Corner.bottomLeft:
        return AxisDirection.right;
      case Corner.topRight:
        return AxisDirection.down;
      case Corner.bottomRight:
        return AxisDirection.up;
    }
  }
}

enum Corner {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}
