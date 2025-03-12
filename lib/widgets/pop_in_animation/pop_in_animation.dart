import 'package:ez_badminton_admin_app/widgets/toggleable_tween_animation/toggleable_tween_animation_builder.dart';
import 'package:flutter/material.dart';

class PopInAnimation extends StatelessWidget {
  const PopInAnimation({
    this.poppedIn = false,
    required this.background,
    required this.foreground,
    super.key,
  });

  final bool poppedIn;
  final Widget background;
  final Widget foreground;

  @override
  Widget build(BuildContext context) {
    return ToggleableTweenAnimationBuilder(
      animationRunning: poppedIn,
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            _PopInTransform(
              backgroud: true,
              tweenValue: value,
              child: background,
            ),
            if (value != 0)
              _PopInTransform(
                backgroud: false,
                tweenValue: value,
                child: foreground,
              ),
          ],
        );
      },
      child: foreground,
    );
  }
}

class _PopInTransform extends StatelessWidget {
  const _PopInTransform({
    required this.backgroud,
    required this.tweenValue,
    required this.child,
  });

  final bool backgroud;
  final double tweenValue;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    double scale =
        backgroud ? 1.0 + (0.1 * tweenValue) : 0.9 + (0.1 * tweenValue);
    double alpha = backgroud ? 1.0 : tweenValue;
    return Opacity(
      opacity: alpha,
      child: Transform.scale(
        scale: scale,
        child: child,
      ),
    );
  }
}
