import 'package:ez_badminton_admin_app/widgets/animated_hover/animated_hover.dart';
import 'package:flutter/material.dart';

/// A [ChoiceChip] in the form of tab
/// (rounded top corners, sharp bottom corners).
///
/// The tab becomes underlined when it is selected.
class ChoiceChipTab extends StatelessWidget {
  const ChoiceChipTab({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.label,
  });

  final bool selected;
  final Function(bool selected) onSelected;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return AnimatedHover(
      duration: const Duration(milliseconds: 80),
      builder: (context, animation, child) {
        return IntrinsicWidth(
          child: Column(
            children: [
              child!,
              Transform.scale(
                scaleX: selected ? 1.0 : animation,
                child: Divider(
                  height: 0,
                  thickness: 2,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        );
      },
      child: ChoiceChip(
        selectedColor: Theme.of(context).primaryColor.withOpacity(.45),
        onSelected: onSelected,
        selected: selected,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 10,
        ),
        label: label,
      ),
    );
  }
}
