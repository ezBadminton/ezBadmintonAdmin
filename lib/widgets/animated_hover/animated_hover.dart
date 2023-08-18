import 'package:ez_badminton_admin_app/widgets/mouse_hover_builder/mouse_hover_builder.dart';
import 'package:ez_badminton_admin_app/widgets/toggleable_tween_animation/toggleable_tween_animation_builder.dart';
import 'package:flutter/material.dart';

class AnimatedHover extends StatelessWidget {
  /// Animates forward when the cursor enters and backwards when it exits.
  ///
  /// The [builder] receives values between `0` and `1` over the [duration].
  const AnimatedHover({
    super.key,
    required this.builder,
    this.duration = const Duration(milliseconds: 100),
    this.reverseDuration,
    this.child,
  });

  final Widget Function(BuildContext context, double value, Widget? child)
      builder;
  final Duration duration;
  final Duration? reverseDuration;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return MouseHoverBuilder(
      builder: (context, isHovered) {
        return ToggleableTweenAnimationBuilder<double>(
          animationRunning: isHovered,
          tween: Tween(begin: 0.0, end: 1.0),
          duration: duration,
          reverseDuration: reverseDuration,
          builder: builder,
          child: child,
        );
      },
    );
  }
}
