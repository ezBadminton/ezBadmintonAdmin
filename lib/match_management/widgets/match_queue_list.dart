import 'package:flutter/material.dart';

class MatchQueueList extends StatelessWidget {
  const MatchQueueList({
    super.key,
    required this.width,
    required this.title,
    required this.list,
  });

  final double width;

  final Widget title;

  final List<Widget> list;

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
                      list,
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
}
