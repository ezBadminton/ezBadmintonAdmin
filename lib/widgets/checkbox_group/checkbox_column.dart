import 'package:ez_badminton_admin_app/widgets/checkbox_group/checkbox_group.dart';
import 'package:flutter/material.dart';

class CheckboxColumn<T extends Object> extends StatelessWidget {
  /// A simple column of checkboxes for use in a [CheckboxGroup]
  const CheckboxColumn({
    super.key,
    required this.children,
    required this.onToggle,
    required this.valueGetter,
    required this.displayStringFunction,
    this.isEnabled,
  });

  final List<T> children;
  final void Function(T) onToggle;
  final bool Function(T) valueGetter;
  final String Function(T) displayStringFunction;
  final bool Function(T)? isEnabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          for (T element in children)
            CheckboxListTile(
              title: Text(displayStringFunction(element)),
              controlAffinity: ListTileControlAffinity.leading,
              visualDensity: const VisualDensity(vertical: -4),
              value: valueGetter(element),
              onChanged: (_) => onToggle(element),
              enabled: isEnabled != null ? isEnabled!(element) : true,
            ),
        ],
      ),
    );
  }
}
