import 'dart:math';

import 'package:ez_badminton_admin_app/utils/animated_transformation_controller/animated_transformation_controller.dart';
import 'package:ez_badminton_admin_app/utils/aspect_ratios.dart'
    as aspect_ratios;
import 'package:flutter/material.dart';

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

  void focusHorizontal(double horizontalOffset) {
    Offset point = Offset(horizontalOffset, currentSceneFocus.dy);

    focusPoint(point, 1.1);
  }
}
