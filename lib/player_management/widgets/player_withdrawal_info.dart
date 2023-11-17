import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/map_listview/map_listview.dart';
import 'package:ez_badminton_admin_app/widgets/match_label/match_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class PlayerWithdrawalInfo extends StatelessWidget {
  const PlayerWithdrawalInfo({
    super.key,
    required this.player,
    required this.withdrawnMatches,
  });

  final Player player;
  final List<BadmintonMatch> withdrawnMatches;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    String playerName = display_strings.playerName(player);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.playerWithdrawalInfo(playerName)),
        const SizedBox(height: 30),
        MapListView(
          itemMap: _buildMatchList(context),
          inset: 12,
          itemPadding: 15,
        ),
      ],
    );
  }

  Map<Widget, List<Widget>> _buildMatchList(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    Map<Competition, List<BadmintonMatch>> withdrawnMatchGroups =
        withdrawnMatches.groupListsBy((match) => match.competition);

    Map<Widget, List<Widget>> matchList = withdrawnMatchGroups.map(
      (competition, matches) {
        return MapEntry(
          CompetitionLabel(
            competition: competition,
            textStyle: const TextStyle(fontSize: 18),
          ),
          [
            for (BadmintonMatch match in matches)
              Row(
                children: [
                  Text(
                    display_strings.matchRoundName(l10n, match) ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                  MatchupLabel(
                    match: match,
                    orientation: Axis.horizontal,
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    useFullName: true,
                    participantWidth: 270,
                  ),
                ],
              ),
          ],
        );
      },
    );

    return matchList;
  }
}
