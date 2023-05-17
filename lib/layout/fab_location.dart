import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A floating action button location for hiding the fab off screen.
///
/// This can be used to animate the fab coming up when it's needed.
class EndOffscreenFabLocation extends StandardFabLocation
    with FabEndOffsetX, FabOffscreenOffsetY {
  const EndOffscreenFabLocation();
  @override
  String toString() => 'FloatingActionButtonLocation.endOffscreen';
}

mixin FabOffscreenOffsetY on StandardFabLocation {
  @override
  double getOffsetY(
    ScaffoldPrelayoutGeometry scaffoldGeometry,
    double adjustment,
  ) {
    final double contentBottom = scaffoldGeometry.contentBottom;
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;

    double fabY = contentBottom + fabHeight;

    return fabY + adjustment;
  }
}

class FabTranslationAnimator extends FloatingActionButtonAnimator {
  /// Animates between two floating action button locations by moving the fab
  /// between them.
  FabTranslationAnimator({this.speedFactor = 1.0});

  final double speedFactor;

  @override
  Offset getOffset(
      {required Offset begin, required Offset end, required double progress}) {
    return Tween<Offset>(begin: begin, end: end)
        .transform(math.min(1.0, progress * speedFactor));
  }

  @override
  Animation<double> getScaleAnimation({required Animation<double> parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
  }

  @override
  Animation<double> getRotationAnimation({required Animation<double> parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
  }

  // If the animation was just starting, we'll continue from where we left off.
  // If the animation was finishing, we'll treat it as if we were starting at that point in reverse.
  // This avoids a size jump during the animation.
  @override
  double getAnimationRestart(double previousValue) =>
      math.min(1.0 - previousValue, previousValue);
}
