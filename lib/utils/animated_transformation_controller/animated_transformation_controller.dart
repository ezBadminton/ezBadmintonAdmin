import 'dart:math';

import 'package:flutter/material.dart';

/// A [TransformationController] with animating capabilities. For usage with an
/// [InteractiveViewer].
///
/// After setting the [vsync], [viewConstraints], [boundarySize] and [sceneSize]
/// this controller can move and zoom the view around the scene.
class AnimatedTransformationController extends TransformationController {
  /// Set this when the TransformationController's owning state is initialized.
  ///
  /// Also set this to null when the state is disposed to free the animation
  /// resources. The transformation matrix is preserved so the vsync can be
  /// re-initialized on the same object to keep the transformation state between
  /// disposals of the TickerProvider.
  set vsync(TickerProvider? vsync) {
    if (_animationController != null) {
      stopAnimation();
      _animationController!.dispose();
      _animationController = null;
    }
    if (vsync != null) {
      _animationController = AnimationController(vsync: vsync);
    }
  }

  /// The current view transform
  Matrix4 get currentTransform => super.value;
  set currentTransform(Matrix4 transform) => super.value = transform;

  /// Set this initially and when the size of the view boundary changes
  late Size boundarySize;

  /// Set this initially and when the size of the widget inside the view changes
  late Size sceneSize;

  /// Set this initially and whenever the view constraints change (LayoutBuilder does this)
  BoxConstraints? viewConstraints;

  AnimationController? _animationController;
  Animation<Matrix4>? _transformAnimation;

  /// Moves the view such that it is fully zoomed out and centered on the scene
  void fitToScreen() {
    if (viewConstraints == null) {
      return;
    }

    double fullViewScale = max(
      viewConstraints!.maxHeight / boundarySize.height,
      viewConstraints!.maxWidth / boundarySize.width,
    );

    fullViewScale = min(1, fullViewScale);

    Matrix4 centered =
        _focusAndScale(sceneSize.center(Offset.zero), fullViewScale);

    animateTo(
      centered,
      curve: Curves.easeOutQuad,
    );
  }

  /// Move the view to the given [point] at the given zoom [scale].
  ///
  /// If this would move the view out of the boundary, the focus point is
  /// automatically corrected.
  ///
  /// If it is impossible to fit the view into the boundary, nothing happens.
  void focusPoint(Offset point, [double scale = 1.0]) {
    if (viewConstraints == null) {
      return;
    }

    Offset? correctedPoint = correctForBoundary(point, scale);
    if (correctedPoint == null) {
      return;
    }

    Matrix4 focused = _focusAndScale(correctedPoint, scale);

    animateTo(
      focused,
      curve: Curves.easeOutQuad,
    );
  }

  /// Zoom the current transform by the relative [scale].
  ///
  /// The minimum zoom is dictated by the boundary and the maximum can be set
  /// by [maxScale].
  ///
  /// If zooming out would move the view out of the [boundarySize], the
  /// focus point is automatically moved away from the boundary.
  void zoom(double scale, {double maxScale = 99999}) {
    if (viewConstraints == null) {
      return;
    }

    stopAnimation();

    Offset currentFocus = toScene(viewConstraints!.biggest.center(Offset.zero));

    // Scale clamping copied and adapted from
    // flutter/lib/src/widgets/interactive_viewer.dart
    final double currentScale = currentTransform.getMaxScaleOnAxis();
    final double totalScale = max(
      currentScale * scale,
      // Ensure that the scale cannot become so small that the view
      // is larger than the boundaries
      max(
        viewConstraints!.maxWidth / boundarySize.width,
        viewConstraints!.maxHeight / boundarySize.height,
      ),
    );
    final double clampedTotalScale = min(totalScale, maxScale);
    final double clampedScale = clampedTotalScale / currentScale;

    Matrix4 scaled = currentTransform.clone()..scale(clampedScale);
    currentTransform = scaled;

    Offset correctedFocus = correctForBoundary(
      currentFocus,
      clampedTotalScale,
    )!;

    Offset scaledFocus = toScene(viewConstraints!.biggest.center(Offset.zero));

    Offset focusCorrection = scaledFocus - correctedFocus;

    scaled.translate(focusCorrection.dx, focusCorrection.dy);

    currentTransform = scaled;
  }

  /// Returns a copy of [point] but if focusing that point at [scale] would move
  /// the view over the [boundarySize], the point is moved inwards until the
  /// view can safely focus there.
  ///
  /// If the view can't fit the boundary, null is returned.
  Offset? correctForBoundary(
    Offset point,
    double scale,
  ) {
    EdgeInsets distanceToBoundary = _getDistanceToBoundary(point);

    Offset minDistanceToBoundary = Offset(
      viewConstraints!.maxWidth * 0.5 * (1.0 / scale),
      viewConstraints!.maxHeight * 0.5 * (1.0 / scale),
    );

    double leftCorrection =
        max(0, minDistanceToBoundary.dx - distanceToBoundary.left);
    double rightCorrection =
        -1 * max(0, minDistanceToBoundary.dx - distanceToBoundary.right);
    double topCorrection =
        max(0, minDistanceToBoundary.dy - distanceToBoundary.top);
    double bottomCorrection =
        -1 * max(0, minDistanceToBoundary.dy - distanceToBoundary.bottom);

    if ((leftCorrection > 0 && rightCorrection < 0) ||
        (topCorrection > 0 && bottomCorrection < 0)) {
      // View is impossible to fit into boundary
      return null;
    }

    Offset boundaryCorrection = Offset(
      leftCorrection + rightCorrection,
      topCorrection + bottomCorrection,
    );

    return point + boundaryCorrection;
  }

  /// Returns the distance of the given [point] to the limits of the
  /// [boundarySize] in all four cardinal directions.
  EdgeInsets _getDistanceToBoundary(
    Offset point,
  ) {
    EdgeInsets boundaryMargins = _getBoundaryMargins();

    double leftDistance = point.dx + boundaryMargins.left;
    double rightDistance = sceneSize.width - point.dx + boundaryMargins.right;
    double topDistance = point.dy + boundaryMargins.top;
    double bottomDistance =
        sceneSize.height - point.dy + boundaryMargins.bottom;

    EdgeInsets distance = EdgeInsets.fromLTRB(
      leftDistance,
      topDistance,
      rightDistance,
      bottomDistance,
    );

    return distance;
  }

  /// Returns the distance of the scene's edges to the edge of the view boundary
  /// in all four cardinal directions.
  EdgeInsets _getBoundaryMargins() {
    double horizontal = (boundarySize.width - sceneSize.width) * 0.5;
    double vertical = (boundarySize.height - sceneSize.height) * 0.5;

    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  /// Returns the transform matrix that focuses the [point]
  /// at the given zoom [scale].
  Matrix4 _focusAndScale(Offset point, double scale) {
    Matrix4 current = currentTransform;
    Matrix4 scaled = Matrix4.identity().scaled(scale);

    // Temporarily scale the transform without animation to figure out the translation
    currentTransform = scaled;

    Offset viewCenter = viewConstraints!.biggest.center(Offset.zero);
    Offset scaledSceneFocus = toScene(viewCenter);
    Offset translation = scaledSceneFocus - point;

    // Go back to current transform
    currentTransform = current;

    return scaled..translate(translation.dx, translation.dy);
  }

  /// Animates from the [currentTransform] to the [targetTransform]
  @protected
  void animateTo(
    Matrix4 targetTransform, {
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linear,
  }) {
    if (_animationController == null) {
      return;
    }

    stopAnimation();
    _animationController!.reset();
    _animationController!.duration = duration;

    _transformAnimation = Matrix4Tween(
      begin: currentTransform,
      end: targetTransform,
    ).animate(
      CurvedAnimation(parent: _animationController!, curve: curve),
    );
    _transformAnimation!.addListener(_onAnimate);

    _animationController!.forward();
  }

  @protected
  void stopAnimation() {
    if (_animationController == null) {
      return;
    }

    _animationController!.stop();
    _transformAnimation?.removeListener(_onAnimate);
    _transformAnimation = null;
    _animationController!.reset();
  }

  void _onAnimate() {
    currentTransform = _transformAnimation!.value;
    if (!_animationController!.isAnimating) {
      stopAnimation();
    }
  }
}
