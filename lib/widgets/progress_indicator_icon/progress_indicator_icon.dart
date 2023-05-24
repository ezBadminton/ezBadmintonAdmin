import 'package:flutter/material.dart';

class ProgressIndicatorIcon extends StatelessWidget {
  /// An icon sized CircularProgressIndicator
  const ProgressIndicatorIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: IconTheme.of(context).size,
      height: IconTheme.of(context).size,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.onPrimary,
          strokeWidth: 3.0,
        ),
      ),
    );
  }
}
