import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/assets/badminton_icons_icons.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/tournament_round_names.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/match_participant_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tournament_mode/tournament_mode.dart';

class QueuedMatch extends StatelessWidget {
  const QueuedMatch({
    super.key,
    required this.match,
  });

  final BadmintonMatch match;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    String? roundName = _getMatchRoundName(match, l10n);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.33),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CompetitionLabel(
                    competition: match.competition,
                    abbreviated: true,
                    playingLevelMaxWidth: 50,
                    textStyle: const TextStyle(fontSize: 12),
                    dividerPadding: 3,
                    dividerSize: 5,
                  ),
                  if (roundName != null) ...[
                    const SizedBox(height: 7),
                    Text(
                      roundName,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            _MatchLabel(match: match),
            if (match.isPlayable && match.court == null)
              Expanded(
                child: _CourtAssignmentButton(matchData: match.matchData!),
              )
            else
              const Expanded(child: Placeholder(fallbackHeight: 70)),
          ],
        ),
      ),
    );
  }

  String? _getMatchRoundName(BadmintonMatch match, AppLocalizations l10n) {
    return switch (match.round) {
      GroupPhaseRound<BadmintonMatch> round =>
        round.getGroupRoundName(l10n, match),
      RoundRobinRound round => round.getRoundRobinRoundName(l10n),
      EliminationRound round => round.getEliminationRoundName(l10n),
      _ => null,
    };
  }
}

class _MatchLabel extends StatelessWidget {
  const _MatchLabel({
    required this.match,
  });

  final BadmintonMatch match;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MatchParticipantLabel(
          match.a,
          teamSize: match.competition.teamSize,
          isEditable: false,
          width: 185,
          alignment: CrossAxisAlignment.center,
          placeholderLabel: Text(
            l10n.qualificationPending,
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
          useFullName: false,
        ),
        Text(
          '- ${l10n.versus} -',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).disabledColor,
          ),
        ),
        MatchParticipantLabel(
          match.b,
          teamSize: match.competition.teamSize,
          isEditable: false,
          width: 185,
          alignment: CrossAxisAlignment.center,
          placeholderLabel: Text(
            l10n.qualificationPending,
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
          useFullName: false,
        ),
      ],
    );
  }
}

class _CourtAssignmentButton extends StatelessWidget {
  const _CourtAssignmentButton({
    required this.matchData,
  });

  final MatchData matchData;

  @override
  Widget build(BuildContext context) {
    var navigationCubit = context.read<TabNavigationCubit>();
    var l10n = AppLocalizations.of(context)!;

    return Tooltip(
      message: l10n.assignCourt,
      child: ElevatedButton(
        onPressed: () => navigationCubit.tabChanged(
          2,
          reason: matchData,
        ),
        style:
            const ButtonStyle(shape: MaterialStatePropertyAll(CircleBorder())),
        child: const Padding(
          padding: EdgeInsets.all(10.0),
          child: Icon(
            BadmintonIcons.badminton_court_outline,
            size: 28,
          ),
        ),
      ),
    );
  }
}
