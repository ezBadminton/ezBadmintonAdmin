import 'package:flutter/material.dart';

class ReorderableItemGap extends StatelessWidget {
  /// A gap between reorderable items that highlights the position where a
  /// hovering item will land if dropped there.
  const ReorderableItemGap({
    super.key,
    required this.elementIndex,
    required this.hoveringIndex,
    required this.top,
    this.height = 8,
    this.indicatorIndent = 2,
    this.indicatorEndIndent = 2,
  });

  final int elementIndex;
  final int? hoveringIndex;

  final double height;
  final double indicatorIndent;
  final double indicatorEndIndent;

  /// Whether this [ReorderableItemGap] is above or below its item.
  ///
  /// Each item should be padded by two [ReorderableItemGap]s one above one
  /// below with [top] set accrodingly.
  final bool top;

  @override
  Widget build(BuildContext context) {
    if (hoveringIndex != null &&
        elementIndex != hoveringIndex &&
        elementIndex < hoveringIndex! == top) {
      return Padding(
        padding: top
            ? EdgeInsets.only(bottom: height - 2)
            : EdgeInsets.only(top: height - 2),
        child: _ReorderIndicator(
          indicatorIndent: indicatorIndent,
          indicatorEndIndent: indicatorEndIndent,
        ),
      );
    }

    return SizedBox(height: height);
  }
}

class _ReorderIndicator extends StatelessWidget {
  const _ReorderIndicator({
    required this.indicatorIndent,
    required this.indicatorEndIndent,
  });

  final double indicatorIndent;
  final double indicatorEndIndent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Theme.of(context).primaryColor,
      height: 2,
      thickness: 2,
      indent: indicatorIndent,
      endIndent: indicatorEndIndent,
    );
  }
}
