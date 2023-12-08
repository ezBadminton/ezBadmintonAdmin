import 'dart:math';

import 'package:ez_badminton_admin_app/utils/animated_transformation_controller/animated_transformation_controller.dart';
import 'package:ez_badminton_admin_app/utils/aspect_ratios.dart'
    as aspect_ratios;
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:flutter/foundation.dart';
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

  void focusGlobalKeys(List<GlobalKey> keys) {
    if (keys.isEmpty) {
      return;
    }

    RenderObject? viewRenderObject =
        bracketViewKey.currentContext?.findRenderObject();

    if (viewRenderObject == null || viewConstraints == null) {
      return;
    }

    Rect? enclosingRect =
        BracketSection.getEnclosingRect(keys, viewRenderObject);

    if (enclosingRect == null) {
      return;
    }

    Offset widgetCenter = enclosingRect.center;
    Size widgetSize = enclosingRect.size;

    Size viewSize = viewConstraints!.biggest;

    double xScale = viewSize.width / widgetSize.width;
    double yScale = viewSize.height / widgetSize.height;

    double fittingScale = clampDouble(min(xScale, yScale), 0.01, 1.33);

    focusPoint(widgetCenter, fittingScale);
  }
}
