import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    this.width = 415,
    this.icon = const Icon(Icons.info_outline),
    required this.child,
  });

  final Widget child;

  final double width;

  final Icon icon;

  @override
  Widget build(BuildContext context) {
    const double infoWidth = 35;

    return Card(
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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: infoWidth,
              child: Container(
                color: Theme.of(context).primaryColor.withOpacity(.33),
                child: icon,
              ),
            ),
            Expanded(
              child: Container(
                width: width - infoWidth,
                color: Theme.of(context).primaryColor.withOpacity(.1),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
