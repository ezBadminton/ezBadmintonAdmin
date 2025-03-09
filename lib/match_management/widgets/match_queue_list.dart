import 'package:flutter/material.dart';

class MatchQueueList extends StatelessWidget {
  const MatchQueueList({
    super.key,
    required this.width,
    required this.title,
    this.list,
    this.sublists,
  }) : assert((list == null) != (sublists == null));

  final double width;

  final Widget title;

  final List<Widget>? list;
  final Map<Widget, List<Widget>>? sublists;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              color: Theme.of(context).primaryColor.withOpacity(.45),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: title,
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      _buildList(context),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildList(BuildContext context) {
    if (list != null) {
      return _buildSublist(context, null, list!);
    } else {
      return [
        for (Widget title in sublists!.keys)
          ..._buildSublist(context, title, sublists![title]!),
      ];
    }
  }

  List<Widget> _buildSublist(
    BuildContext context,
    Widget? title,
    List<Widget> sublist,
  ) {
    return [
      if (title != null && sublist.isNotEmpty) title,
      ...sublist,
    ];
  }
}
