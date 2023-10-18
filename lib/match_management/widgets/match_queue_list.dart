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

  final String title;

  final List<Widget>? list;
  final Map<String, List<Widget>>? sublists;

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
            SizedBox(
              height: 45,
              child: Container(
                alignment: Alignment.center,
                color: Theme.of(context).primaryColor.withOpacity(.45),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      _buildList(),
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

  List<Widget> _buildList() {
    if (list != null) {
      return _buildSublist(null, list!);
    } else {
      return [
        for (String title in sublists!.keys)
          ..._buildSublist(title, sublists![title]!),
      ];
    }
  }

  List<Widget> _buildSublist(String? title, List<Widget> sublist) {
    return [
      if (title != null && sublist.isNotEmpty) ...[
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Center(
            child: Text(title),
          ),
        ),
        const Divider(height: 1),
      ],
      ...sublist,
    ];
  }
}
