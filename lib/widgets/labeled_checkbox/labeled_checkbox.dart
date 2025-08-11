import 'package:flutter/material.dart';

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    super.key,
    required this.value,
    required this.label,
    this.onToggled,
  });

  final bool value;
  final Widget label;
  final VoidCallback? onToggled;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onToggled,
        behavior: HitTestBehavior.translucent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 0.85,
              child: Checkbox(
                value: value,
                onChanged: (_) => onToggled?.call(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                side: WidgetStateBorderSide.resolveWith(
                  (states) => BorderSide(width: 1.3, color: Colors.white),
                ),
              ),
            ),
            label,
          ],
        ),
      ),
    );
  }
}
