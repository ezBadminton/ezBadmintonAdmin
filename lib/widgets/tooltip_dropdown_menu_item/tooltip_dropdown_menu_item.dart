import 'package:ez_badminton_admin_app/widgets/help_tooltip_icon/help_tooltip_icon.dart';
import 'package:flutter/material.dart';

class TooltipDropdownMenuItem<T> extends DropdownMenuItem<T> {
  TooltipDropdownMenuItem({
    super.key,
    required super.value,
    required String label,
    required String helpText,
  }) : super(
          child: _TooltipMenuLabel(
            label: label,
            helpText: helpText,
          ),
        );
}

class _TooltipMenuLabel extends StatelessWidget {
  const _TooltipMenuLabel({
    required this.label,
    required this.helpText,
  });

  final String label;
  final String helpText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label),
        ),
        HelpTooltipIcon(helpText: helpText),
      ],
    );
  }
}
