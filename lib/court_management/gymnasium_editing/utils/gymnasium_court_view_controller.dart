import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/utils/animated_transformation_controller/animated_transformation_controller.dart';
import 'package:flutter/material.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/utils/gymnasium_court_view_utils.dart'
    as gym_court_utils;

class GymnasiumCourtViewController extends AnimatedTransformationController {
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

  BoxConstraints? _viewConstraints;

  /// Set this whenever the view constraints change (LayoutBuilder does this)
  @override
  set viewConstraints(BoxConstraints? constraints) {
    _viewConstraints = constraints;
    if (constraints == null) {
      return;
    }

    _updateSizes();

    // Fit the gym into the view when it is first loaded
    if (!hasInitializedView) {
      fitToScreen();
      hasInitializedView = true;
    }
  }

  @override
  BoxConstraints? get viewConstraints => _viewConstraints;

  bool hasInitializedView = false;

  void focusCourtSlot(int row, int column) {
    if (viewConstraints == null) {
      return;
    }

    Offset courtCenter = gym_court_utils.getCourtSlotCenter(
      row,
      column,
      viewConstraints!,
      _gymnasium,
    );

    focusPoint(courtCenter);
  }

  /// Cancels the current animation when the user interacts with the view
  void onInteractionStart() {
    stopAnimation();
  }

  void _updateSizes() {
    sceneSize = gym_court_utils.getGymSize(
      viewConstraints!,
      _gymnasium,
      withPadding: true,
    );
    boundaryMargin = gym_court_utils.getGymBoundaryMargin(
      viewConstraints!,
      _gymnasium,
    );
  }
}
