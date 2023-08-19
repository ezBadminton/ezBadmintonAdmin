import 'dart:math';

import 'package:collection_repository/collection_repository.dart';
import 'package:flutter/material.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/utils/gymnasium_court_view_utils.dart'
    as gym_court_utils;

class GymnasiumCourtViewController extends TransformationController {
  GymnasiumCourtViewController({
    required this.gymnasium,
  });

  final Gymnasium gymnasium;

  late Size _boundarySize;
  late Size _gymnasiumSize;

  BoxConstraints? _viewConstraints;

  /// Set this whenever the view constraints change (LayoutBuilder does this)
  set viewConstraints(BoxConstraints constraints) {
    bool initialFit = _viewConstraints == null;
    _boundarySize = gym_court_utils.getGymSize(
      constraints,
      gymnasium,
      withPadding: true,
      withBoundaryMargin: true,
    );
    _gymnasiumSize = gym_court_utils.getGymSize(
      constraints,
      gymnasium,
      withPadding: true,
    );

    _viewConstraints = constraints;

    if (initialFit) {
      fitToScreen();
    }
  }

  /// Set this whenever the GymnasiumCourtView gets initialized
  late AnimationController animationController;

  Animation<Matrix4>? _transformAnimation;

  /// The current view transform
  Matrix4 get currentTransform => super.value;
  set currentTransform(Matrix4 transform) => super.value = transform;

  /// Moves the view such that it is fully zoomed out and centered
  void fitToScreen() {
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
    if (_viewConstraints == null) {
      return;
    }
    Offset courtCenter = gym_court_utils.getCourtSlotCenter(
      row,
      column,
      _viewConstraints!,
      gymnasium,
    );

    Offset targetView = gym_court_utils.correctForBoundary(
      courtCenter,
      _viewConstraints!,
      gymnasium,
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
    _stopAnimation();
    animationController.reset();
    animationController.duration = duration;

    _transformAnimation = Matrix4Tween(
      begin: currentTransform,
      end: targetTransform,
    ).animate(
      CurvedAnimation(parent: animationController, curve: curve),
    );
    _transformAnimation!.addListener(_onAnimate);

    animationController.forward();
  }

  void _stopAnimation() {
    animationController.stop();
    _transformAnimation?.removeListener(_onAnimate);
    _transformAnimation = null;
    animationController.reset();
  }

  void _onAnimate() {
    currentTransform = _transformAnimation!.value;
    if (!animationController.isAnimating) {
      _stopAnimation();
    }
  }
}
