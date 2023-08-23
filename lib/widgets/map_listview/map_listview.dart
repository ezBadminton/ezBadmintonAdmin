import 'package:flutter/material.dart';

/// A ListView that takes a Map of `Widget->List<Widget>` and displays it as
/// a nested list view like this:
/// ```console
/// Key1
///   Value1
///   Value2
/// Key2
///   Value1
///   Value2
/// ```
class MapListView extends StatelessWidget {
  const MapListView({
    super.key,
    required this.itemMap,
    this.inset = 8.0,
    this.itemPadding = 10.0,
    this.keyPadding = 20.0,
    this.bottomPadding = 0.0,
    this.topPadding = 0.0,
    this.controller,
  });

  final Map<Widget, List<Widget>> itemMap;

  /// The inset width of the value items
  final double inset;

  /// The padding between the value-items
  final double itemPadding;

  /// The padding betweem the key-groups
  final double keyPadding;

  /// The padding between the end of the list and the end of the scrollable area
  final double bottomPadding;

  /// The padding between the start of the scrollable area and the start of the list
  final double topPadding;

  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (Widget key in itemMap.keys) ...[
            if (itemMap.keys.first == key) SizedBox(height: topPadding),
            _buildKeyItem(context, key),
            _buildValueItems(context, itemMap[key]!),
            if (itemMap.keys.last != key)
              SizedBox(height: keyPadding)
            else
              SizedBox(height: bottomPadding),
          ],
        ],
      ),
    );
  }

  Widget _buildKeyItem(BuildContext context, Widget item) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(context).style.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: item,
      ),
    );
  }

  Widget _buildValueItems(BuildContext context, List<Widget> items) {
    return Container(
      decoration: const BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(
            color: Colors.black26,
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          for (Widget item in items) ...[
            DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.copyWith(
                    fontSize: 16,
                  ),
              child: Padding(
                padding: EdgeInsetsDirectional.only(start: inset),
                child: item,
              ),
            ),
            if (items.last != item) SizedBox(height: itemPadding),
          ],
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
