import 'package:collection_repository/collection_repository.dart';
import 'package:flutter/material.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompetitionLabel extends StatelessWidget {
  const CompetitionLabel({
    super.key,
    required this.competition,
    this.abbreviated = false,
    this.playingLevelMaxWidth = 240,
  });

  final Competition competition;
  final bool abbreviated;
  final double playingLevelMaxWidth;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    var divider = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Icon(
        Icons.circle,
        size: 7,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(.5),
      ),
    );

    return Tooltip(
      message: display_strings.competitionLabel(l10n, competition),
      waitDuration: const Duration(milliseconds: 500),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (competition.playingLevel != null) ...[
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: playingLevelMaxWidth),
              child: Text(
                competition.playingLevel!.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            divider,
          ],
          if (competition.ageGroup != null) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                display_strings.ageGroup(
                  l10n,
                  competition.ageGroup!,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            divider,
          ],
          Text(
            abbreviated
                ? display_strings.competitionGenderAndTypeAbbreviation(
                    l10n,
                    competition.genderCategory,
                    competition.type,
                  )
                : display_strings.competitionGenderAndType(
                    l10n,
                    competition.genderCategory,
                    competition.type,
                  ),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
