import 'package:ez_badminton_admin_app/widgets/help_tooltip_icon/help_tooltip_icon.dart';
import 'package:flutter/material.dart';

class SettingCard extends StatelessWidget {
  const SettingCard({
    super.key,
    required this.title,
    required this.child,
    required this.helpText,
  });

  final Widget title;

  final Widget child;

  final String helpText;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 25.0),
        child: Row(
          children: [
            Expanded(child: title),
            child,
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: HelpTooltipIcon(helpText: helpText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
