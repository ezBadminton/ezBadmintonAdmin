import 'package:ez_badminton_admin_app/widgets/help_tooltip_icon/help_tooltip_icon.dart';
import 'package:ez_badminton_admin_app/widgets/integer_stepper/integer_stepper.dart';
import 'package:flutter/material.dart';

class IntegerStepperCard extends StatelessWidget {
  const IntegerStepperCard({
    super.key,
    required this.onChanged,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    required this.title,
    this.helpText,
  });

  final Function(int value) onChanged;
  final int initialValue;
  final int minValue;
  final int maxValue;

  final Widget title;
  final String? helpText;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              child: title,
            ),
            IntegerStepper(
              initialValue: initialValue,
              onChanged: onChanged,
              minValue: minValue,
              maxValue: maxValue,
            ),
            if (helpText != null)
              Positioned(
                right: 0,
                child: HelpTooltipIcon(helpText: helpText!),
              ),
          ],
        ),
      ),
    );
  }
}
