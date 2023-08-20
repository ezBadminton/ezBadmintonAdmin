import 'dart:math';

import 'package:collection_repository/collection_repository.dart';
import 'package:flutter/material.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/utils/gymnasium_court_view_utils.dart'
    as gym_court_utils;

class GymnasiumCourtViewController extends TransformationController {
  GymnasiumCourtViewController({
    required Gymnasium gymnasium,
  }) : _gymnasium = gymnasium;

  Gymnasium _gymnasium;

  set gymnasium(Gymnasium gymnasium) {
    bool updateSizes = _gymnasium.columns != gymnasium.columns ||
        _gymnasium.rows != gymnasium.rows;

    _gymnasium = gymnasium;

    if (updateSizes) {
      _updateSizes();
      fitToScreen();
    }
  }

  late Size _boundarySize;
  late Size _gymnasiumSize;

  BoxConstraints? _viewConstraints;

  /// Set this whenever the view constraints change (LayoutBuilder does this)
  set viewConstraints(BoxConstraints? constraints) {
    if (constraints == null) {
      _viewConstraints = null;
      return;
    }

    _viewConstraints = constraints;

    _updateSizes();

    // Fit the gym into the view when it is first loaded
    if (!hasInitializedView) {
      fitToScreen();
      hasInitializedView = true;
    }
  }

  AnimationController? _animationController;

  /// Set this whenever the GymnasiumCourtView gets initialized
  set animationController(AnimationController? controller) =>
      _animationController = controller;

  Animation<Matrix4>? _transformAnimation;

  bool hasInitializedView = false;

  /// The current view transform
  Matrix4 get currentTransform => super.value;
  set currentTransform(Matrix4 transform) => super.value = transform;

  /// Moves the view such that it is fully zoomed out and centered
  void fitToScreen() {
    if (_animationController == null || _viewConstraints == null) {
      return;
    }

    Matrix4 current = currentTransform;

    double fullViewScale = min(
      1,
      _viewConstraints!.maxWidth / _boundarySize.width,
    );
    Matrix4 scaled = Matrix4.identity().scaled(fullViewScale);
    // Temporarily scale the view without animation to figure out the translation
    currentTransform = scaled;

    Offset viewCenter = _viewConstraints!.biggest.center(Offset.zero);
    Offset viewFocus = toScene(viewCenter);
    Offset fromGymCenter = _gymnasiumSize.center(-viewFocus);

    Matrix4 centered = scaled..translate(-fromGymCenter.dx, -fromGymCenter.dy);

    // Go back to current view and start animation
    currentTransform = current;
    _animateTo(
      centered,
      curve: Curves.easeOutQuad,
    );
  }

  void focusCourtSlot(int row, int column) {
    if (_animationController == null || _viewConstraints == null) {
      return;
    }

    Offset courtCenter = gym_court_utils.getCourtSlotCenter(
      row,
      column,
      _viewConstraints!,
      _gymnasium,
    );

    Offset targetView = gym_court_utils.correctForBoundary(
      courtCenter,
      _viewConstraints!,
      _gymnasium,
    );

    Offset viewCenter = _viewConstraints!.biggest.center(Offset.zero);

    Offset viewTranslation = targetView - viewCenter;

    Matrix4 centered = Matrix4.identity()
      ..translate(
        -viewTranslation.dx,
        -viewTranslation.dy,
      );

    _animateTo(
      centered,
      curve: Curves.easeOutQuad,
    );
  }

  void zoom(double scale) {
    if (_animationController == null || _viewConstraints == null) {
      return;
    }

    _stopAnimation();

    Offset currentFocus =
        toScene(_viewConstraints!.biggest.center(Offset.zero));

    // Scale clamping copied and adapted from
    // flutter\lib\src\widgets\interactive_viewer.dart
    final double currentScale = currentTransform.getMaxScaleOnAxis();
    final double totalScale = max(
      currentScale * scale,
      // Ensure that the scale cannot become so small that the view
      // is larger than the boundaries
      max(
        _viewConstraints!.maxWidth / _boundarySize.width,
        _viewConstraints!.maxHeight / _boundarySize.height,
      ),
    );
    final double clampedTotalScale = min(
      totalScale,
      gym_court_utils.maxZoomScale,
    );
    final double clampedScale = clampedTotalScale / currentScale;

    Matrix4 scaled = currentTransform.clone()..scale(clampedScale);
    currentTransform = scaled;

    currentFocus = gym_court_utils.correctForBoundary(
      currentFocus,
      _viewConstraints!,
      _gymnasium,
      clampedTotalScale,
    );

    Offset scaledFocus = toScene(_viewConstraints!.biggest.center(Offset.zero));

    Offset focusCorrection = scaledFocus - currentFocus;

    scaled.translate(focusCorrection.dx, focusCorrection.dy);

    currentTransform = scaled;
  }

  /// Cancels the current animation when the user interacts with the view
  void onInteractionStart() {
    _stopAnimation();
  }

  /// Animates the view from the [currentTransform] to the [targetTransform]
  void _animateTo(
    Matrix4 targetTransform, {
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linear,
  }) {
    if (_animationController == null) {
      return;
    }
    _stopAnimation();
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

  void _stopAnimation() {
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
      _stopAnimation();
    }
  }

  void _updateSizes() {
    if (_viewConstraints == null) {
      return;
    }
    _boundarySize = gym_court_utils.getGymSize(
      _viewConstraints!,
      _gymnasium,
      withPadding: true,
      withBoundaryMargin: true,
    );
    _gymnasiumSize = gym_court_utils.getGymSize(
      _viewConstraints!,
      _gymnasium,
      withPadding: true,
    );
  }
}
