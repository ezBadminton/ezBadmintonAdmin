import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/match_label.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/match_participant_label.dart';
import 'package:flutter/material.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RoundRobinPlan extends StatelessWidget {
  RoundRobinPlan({
    super.key,
    required List<MatchParticipant<Team>> participants,
    required this.rounds,
    required this.competition,
  }) : participants = participants.where((p) => !p.isBye).toList();

  final List<MatchParticipant<Team>> participants;
  final List<RoundRobinRound<Team, List<MatchSet>>> rounds;
  final Competition competition;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _RoundRobinTable(
          participants: participants,
          competition: competition,
          title: l10n.participant(2),
        ),
        const SizedBox(height: 5),
        _RoundRobinMatchList(
          rounds: rounds,
          competition: competition,
        ),
      ],
    );
  }
}

class _RoundRobinTable extends StatelessWidget {
  const _RoundRobinTable({
    required this.participants,
    required this.competition,
    this.title,
  });

  final List<MatchParticipant<Team>> participants;
  final Competition competition;

  final String? title;

  @override
  Widget build(BuildContext context) {
    double width = 440;
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
      child: Column(
        children: [
          if (title != null) ...[
            SizedBox(
              width: width,
              height: 45,
              child: Container(
                alignment: Alignment.center,
                color: Theme.of(context).primaryColor.withOpacity(.45),
                child: Text(
                  title!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: width,
              child: Divider(
                height: 0,
                thickness: 2,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.3),
              ),
            ),
          ],
          for (MatchParticipant<Team> participant in participants) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: MatchParticipantLabel(
                participant,
                teamSize: competition.teamSize,
                isEditable: false,
                width: width,
                showClub: true,
              ),
            ),
            if (participants.last != participant)
              SizedBox(
                width: width,
                child: const Divider(height: 0),
              ),
          ],
        ],
      ),
    );
  }
}

class _RoundRobinMatchList extends StatelessWidget {
  const _RoundRobinMatchList({
    required this.rounds,
    required this.competition,
  });

  final List<RoundRobinRound<Team, List<MatchSet>>> rounds;
  final Competition competition;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 5.0,
        ),
        child: Column(
          children: [
            for (RoundRobinRound<Team, List<MatchSet>> round in rounds) ...[
              Text(
                l10n.encounterNumber(round.roundNumber + 1),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              for (BadmintonMatch match in round.cast<BadmintonMatch>())
                MatchLabel(match: match, competition: competition),
              if (rounds.last != round) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
