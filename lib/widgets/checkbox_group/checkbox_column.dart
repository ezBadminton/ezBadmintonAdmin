import 'package:ez_badminton_admin_app/widgets/checkbox_group/checkbox_group.dart';
import 'package:flutter/material.dart';

class CheckboxColumn<T extends Object> extends CheckboxWrap<T> {
  /// A simple column of checkboxes for use in a [CheckboxGroup]
  const CheckboxColumn({
    super.key,
    required super.children,
    required super.onToggle,
    required super.valueGetter,
    required super.displayStringFunction,
    super.isEnabled,
    super.tooltipFunction,
  }) : super(columns: 1);
}

class CheckboxWrap<T extends Object> extends StatelessWidget {
  /// A wrapping row of checkboxes for use in a [CheckboxGroup].
  ///
  /// It wraps after [columns] items per row.
  const CheckboxWrap({
    super.key,
    required this.children,
    required this.onToggle,
    required this.valueGetter,
    required this.displayStringFunction,
    this.isEnabled,
    required this.columns,
    this.tooltipFunction,
  });

  final List<T> children;
  final void Function(T) onToggle;
  final bool Function(T) valueGetter;
  final String Function(T) displayStringFunction;
  final bool Function(T)? isEnabled;
  final String Function(T)? tooltipFunction;

  final int columns;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        children: [
          for (T element in children)
            Tooltip(
              message: tooltipFunction == null ? '' : tooltipFunction!(element),
              child: FractionallySizedBox(
                widthFactor: 1.0 / columns,
                child: CheckboxListTile(
                  title: Text(displayStringFunction(element)),
                  controlAffinity: ListTileControlAffinity.leading,
                  visualDensity: const VisualDensity(vertical: -4),
                  value: valueGetter(element),
                  onChanged: (_) => onToggle(element),
                  enabled: isEnabled != null ? isEnabled!(element) : true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
