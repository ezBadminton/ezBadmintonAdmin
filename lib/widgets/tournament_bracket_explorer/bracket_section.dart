import 'package:flutter/material.dart';

class BracketSection {
  const BracketSection({
    required this.tournamentDataObjects,
    required this.labelBuilder,
  });

  final List<Object> tournamentDataObjects;
  final String Function(BuildContext context) labelBuilder;

  static Rect? getEnclosingRect(List<GlobalKey> keys, RenderObject reference) {
    if (keys.isEmpty) {
      return null;
    }

    List<RenderBox> renderBoxes = keys
        .map(
          (key) {
            RenderBox? renderBox =
                (key.currentContext?.findRenderObject() as RenderBox?);

            bool hasSize = renderBox?.hasSize ?? false;

            return hasSize ? renderBox : null;
          },
        )
        .whereType<RenderBox>()
        .toList();

    if (renderBoxes.length < keys.length) {
      return null;
    }

    List<Rect> rects = renderBoxes.map(
      (box) {
        Matrix4 transform = box.getTransformTo(reference);

        return MatrixUtils.transformRect(transform, box.semanticBounds);
      },
    ).toList();

    Rect enclosingRect = _getEnclosingRect(rects);

    return enclosingRect;
  }

  static Rect _getEnclosingRect(List<Rect> rects) {
    Rect enclosing = rects.reduce(
      (currentEnclosing, rect) => currentEnclosing.expandToInclude(rect),
    );

    return enclosing;
  }
}
