import 'package:flutter/material.dart';

class LongTooltip extends StatelessWidget {
  /// A tooltip with the ability to constrain its width.
  ///
  /// Good for long tooltip messages that should wrap.
  const LongTooltip({
    super.key,
    this.maxWidth = 250,
    required this.message,
    required this.child,
    this.waitDuration,
  });

  final double maxWidth;
  final String message;
  final Duration? waitDuration;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      waitDuration: waitDuration,
      richMessage: WidgetSpan(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ),
      child: child,
    );
  }
}
