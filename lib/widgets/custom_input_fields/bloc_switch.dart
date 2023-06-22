import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocSwitch<B extends StateStreamable<S>, S> extends StatelessWidget {
  /// A switch that can change a boolean value in a state [S] and rebuild itself
  /// according state emissions from [B].
  ///
  /// The [valueGetter] Function returns a bool when being passed [S].
  /// When the Switch is flipped [onChanged] is called with the current bool.
  const BlocSwitch({
    super.key,
    required this.label,
    required this.valueGetter,
    required this.onChanged,
  });

  final String label;
  final bool Function(S state) valueGetter;
  final Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      buildWhen: (previous, current) =>
          valueGetter(previous) != valueGetter(current),
      builder: (context, state) {
        return Row(
          children: [
            Switch(
              value: valueGetter(state),
              onChanged: onChanged,
            ),
            Text(label),
          ],
        );
      },
    );
  }
}
