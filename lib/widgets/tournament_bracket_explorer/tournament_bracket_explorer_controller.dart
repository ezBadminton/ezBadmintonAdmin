import 'dart:math';

import 'package:ez_badminton_admin_app/utils/animated_transformation_controller/animated_transformation_controller.dart';
import 'package:ez_badminton_admin_app/utils/aspect_ratios.dart'
    as aspect_ratios;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

// The controller uses this size when the tournament bracket has not been
// rendered and its size is not yet known
const Size _fallbackSceneSize = Size(1, 1);

class TournamentBracketExplorerController
    extends AnimatedTransformationController {
  TournamentBracketExplorerController(this.bracketViewKey);

  final GlobalKey bracketViewKey;

  @override
  Size get sceneSize =>
      (bracketViewKey.currentContext?.findRenderObject() as RenderBox?)?.size ??
      _fallbackSceneSize;

  @override
  EdgeInsets get boundaryMargin {
    Size view = viewConstraints!.biggest;
    Size scene = sceneSize;

    EdgeInsets minMargin = const EdgeInsets.all(250);

    Size minSize = Size(
      max(view.width, scene.width),
      max(view.height, scene.height),
    );
    minSize = minMargin.inflateSize(minSize);

    Size boundarySize = aspect_ratios.alignAspectRatios(view, minSize);

    return EdgeInsets.symmetric(
      horizontal: (boundarySize.width - scene.width) * 0.5,
      vertical: (boundarySize.height - scene.height) * 0.5,
    );
  }

  BoxConstraints? _viewConstraints;
  @override
  BoxConstraints? get viewConstraints => _viewConstraints;
  @override
  set viewConstraints(BoxConstraints? newConstraints) {
    if (newConstraints == _viewConstraints) {
      return;
    }
    _viewConstraints = newConstraints;
    if (sceneSize != _fallbackSceneSize) {
      fitToScreen();
    }
  }

  void focusGlobalKey(GlobalKey key) {
    RenderObject? viewRenderObject =
        bracketViewKey.currentContext?.findRenderObject();

    RenderBox? renderBox =
        (key.currentContext?.findRenderObject() as RenderBox?);

    if (viewRenderObject == null ||
        renderBox == null ||
        viewConstraints == null) {
      return;
    }

    Vector3 translation =
        renderBox.getTransformTo(viewRenderObject).getTranslation();

    Offset widgetCenter =
        renderBox.paintBounds.translate(translation.x, translation.y).center;
    Size widgetSize = renderBox.paintBounds.size;

    Size viewSize = viewConstraints!.biggest;

    double xScale = viewSize.width / widgetSize.width;
    double yScale = viewSize.height / widgetSize.height;

    double fittingScale = min(1.33, min(xScale, yScale));

    focusPoint(widgetCenter, fittingScale);
  }
}
