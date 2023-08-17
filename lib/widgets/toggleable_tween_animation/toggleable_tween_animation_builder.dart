import 'package:ez_badminton_admin_app/widgets/toggleable_tween_animation/cubit/tween_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/toggleable_tween_animation/cubit/tween_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Builder that animates towards a [Tween]'s end value when toggled on and
/// back towards the begin value when off.
class ToggleableTweenAnimationBuilder<T extends Object?>
    extends StatelessWidget {
  /// The animation starts running when [animationRunning] is changed to `true`.
  /// When it is set back to `false` it runs backwards. If the animation
  /// was not finished it turns around on the value that it was at.
  ///
  /// The values given to the [builder] are taken from the [tween].
  /// The animation takes [duration] to go from begin to end value.
  /// If [reverseDuration] is given, this duration is used instead when the
  /// animation runs backwards.
  ///
  /// The [child] is not rebuilt for the animation but can still be used in
  /// the builder to save rebuild performance cost.
  const ToggleableTweenAnimationBuilder({
    super.key,
    required this.animationRunning,
    required this.tween,
    required this.builder,
    this.duration = const Duration(milliseconds: 100),
    this.reverseDuration,
    this.curve = Curves.linear,
    this.child,
  });

  final bool animationRunning;
  final Tween<T> tween;
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Duration duration;
  final Duration? reverseDuration;
  final Curve curve;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TweenCubit(),
      child: _HoverTween(
        animationRunning: animationRunning,
        tween: tween,
        builder: builder,
        duration: duration,
        reverseDuration: reverseDuration ?? duration,
        curve: curve,
        child: child,
      ),
    );
  }
}

class _HoverTween<T> extends StatelessWidget {
  const _HoverTween({
    required this.animationRunning,
    required this.tween,
    required this.builder,
    required this.duration,
    required this.reverseDuration,
    required this.curve,
    this.child,
  });

  final bool animationRunning;
  final Tween<T> tween;
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Duration duration;
  final Duration reverseDuration;
  final Curve curve;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<TweenCubit>();
    cubit.tweenTargetChanged(animationRunning ? 1.0 : 0.0);

    return BlocBuilder<TweenCubit, TweenState>(
      buildWhen: (previous, current) =>
          previous.targetValue != current.targetValue,
      builder: (context, state) {
        bool forward = state.targetValue == 1.0;

        double previousProgression =
            (state.targetValue - state.currentValue).abs();
        Duration directionalDuration = forward ? duration : reverseDuration;
        Duration progressionCorrectedDuration =
            directionalDuration * previousProgression;

        Curve directionalCurve = forward ? curve : curve.flipped;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: state.currentValue, end: state.targetValue),
          curve: directionalCurve,
          duration: progressionCorrectedDuration,
          builder: (context, value, _) {
            cubit.currentValueChanged(value);
            return builder(context, tween.transform(value), child);
          },
        );
      },
    );
  }
}
