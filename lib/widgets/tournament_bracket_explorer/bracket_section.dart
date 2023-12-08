import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class BracketSection {
  const BracketSection({
    required this.tournamentDataObjects,
    required this.labelBuilder,
  });

  final List<Object> tournamentDataObjects;
  final String Function(BuildContext context) labelBuilder;

  static Rect? getEnclosingRect(List<GlobalKey> keys, RenderObject referece) {
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
        Vector3 translation = box.getTransformTo(referece).getTranslation();

        return box.semanticBounds.translate(translation.x, translation.y);
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
