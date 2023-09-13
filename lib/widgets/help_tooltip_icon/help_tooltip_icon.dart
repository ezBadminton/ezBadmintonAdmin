import 'package:ez_badminton_admin_app/widgets/long_tooltip/long_tooltip.dart';
import 'package:flutter/material.dart';

class HelpTooltipIcon extends StatelessWidget {
  const HelpTooltipIcon({
    super.key,
    required this.helpText,
  });

  final String helpText;

  @override
  Widget build(BuildContext context) {
    return LongTooltip(
      message: helpText,
      child: Icon(
        Icons.help_outline,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(.5),
        size: 21,
      ),
    );
  }
}
