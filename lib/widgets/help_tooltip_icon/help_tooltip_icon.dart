import 'package:ez_badminton_admin_app/widgets/long_tooltip/long_tooltip.dart';
import 'package:flutter/material.dart';

class HelpTooltipIcon extends StatelessWidget {
  const HelpTooltipIcon({
    super.key,
    required this.helpText,
    this.icon = Icons.help_outline,
    this.size = 21.0,
  });

  final String helpText;

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return LongTooltip(
      message: helpText,
      child: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(.5),
        size: size,
      ),
    );
  }
}
