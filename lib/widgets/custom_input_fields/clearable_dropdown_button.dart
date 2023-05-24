import 'package:flutter/material.dart';

class ClearableDropdownButton<T> extends StatelessWidget {
  ClearableDropdownButton({
    super.key,
    required this.value,
    required this.onChanged,
    required this.items,
    required this.label,
    this.showClearButton = true,
  });

  final T? value;
  final Function(T? value) onChanged;
  final List<DropdownMenuItem<T>> items;
  final Widget label;
  final bool showClearButton;

  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        label: label,
        counterText: ' ',
        suffixIcon: value == null || !showClearButton
            ? null
            : IconButton(
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                onPressed: () {
                  onChanged(null);
                  _focusNode.unfocus();
                },
                icon: const Icon(Icons.highlight_remove),
              ),
      ),
    );
  }
}
