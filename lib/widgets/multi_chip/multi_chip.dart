import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class MultiChip extends StatelessWidget {
  const MultiChip({
    super.key,
    required this.title,
    required this.items,
    required this.onDeleted,
  }) : assert(items.length == onDeleted.length);

  final String title;
  final List<Widget> items;
  final List<VoidCallback> onDeleted;

  @override
  Widget build(BuildContext context) {
    List<Widget> chipItems = items
        .mapIndexed(
          (index, item) => Row(
            children: [
              Container(
                color: Theme.of(context).disabledColor.withOpacity(.08),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      item,
                      const SizedBox(width: 3),
                      Tooltip(
                        triggerMode: TooltipTriggerMode.manual,
                        message: MaterialLocalizations.of(context)
                            .deleteButtonTooltip,
                        child: InkResponse(
                          radius: 12,
                          onTap: onDeleted[index],
                          child: const Icon(
                            Icons.close,
                            size: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (index != items.length - 1) const SizedBox(width: 10),
            ],
          ),
        )
        .toList();

    return Container(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: Theme.of(context).disabledColor.withOpacity(.1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 10),
            ...chipItems
          ],
        ),
      ),
    );
  }
}
