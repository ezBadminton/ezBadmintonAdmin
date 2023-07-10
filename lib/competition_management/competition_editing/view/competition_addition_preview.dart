import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompetitionAdditionPreview extends StatelessWidget {
  // A widget for displaying the list of competitions that will be added upon
  // submitting the competition creation form in its current state.
  const CompetitionAdditionPreview({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _PreviewListHeader(),
      ],
    );
  }
}

class _PreviewListHeader extends StatelessWidget {
  const _PreviewListHeader();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return DefaultTextStyle(
      style: Theme.of(context)
          .textTheme
          .bodyMedium!
          .copyWith(fontWeight: FontWeight.bold),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: const Border(
            bottom: BorderSide(
              color: Colors.black26,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Row(
            children: [
              SizedBox(
                width: 200,
                child: Text(l10n.ageGroup(1)),
              ),
              Flexible(
                flex: 1,
                child: Container(),
              ),
              SizedBox(
                width: 200,
                child: Text(l10n.playingLevel(1)),
              ),
              Flexible(
                flex: 1,
                child: Container(),
              ),
              SizedBox(
                width: 500,
                child: Text(l10n.competition(2)),
              ),
              Flexible(
                flex: 4,
                child: Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
