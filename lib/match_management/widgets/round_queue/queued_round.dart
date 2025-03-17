import 'package:ez_badminton_admin_app/match_management/widgets/queued_match.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/round_queue/cubit/round_selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model_repository/model_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/match_and_round_names.dart'
    as round_strings;

class QueuedRound extends StatelessWidget {
  const QueuedRound({
    required this.scheduledRound,
    super.key,
  });

  final ScheduledRound scheduledRound;

  @override
  Widget build(BuildContext context) {
    int numReady = 0;
    var waitingMatches = <ScheduledMatch>[];
    for (final match in scheduledRound.matches) {
      switch (match.status) {
        case ScheduleStatus.courtWait:
          numReady += 1;
          continue waiting;
        waiting:
        case ScheduleStatus.playerRest:
        case ScheduleStatus.playerWait:
        case ScheduleStatus.wait:
          waitingMatches.add(match);
        default:
      }
    }

    var nextMatch = waitingMatches.first;
    var nextMatchContext = MatchContext(
      tournamentPlan: scheduledRound.competition.tournamentPlan!,
      scheduledMatch: nextMatch,
    );
    int numTotal = waitingMatches.length;

    var l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7),
      child: Container(
        color: Colors.blueGrey[100],
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CompetitionLabel(
                        competition: scheduledRound.competition,
                        alignment: MainAxisAlignment.start,
                      ),
                      Text(round_strings.roundName(l10n, scheduledRound)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "$numReady / $numTotal",
                      style: TextStyle(fontSize: 17),
                    ),
                    Text(l10n.matchesReady(numTotal)),
                  ],
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 18),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -9,
                      left: -13,
                      right: -13,
                      bottom: -20,
                      child: Card(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                        color: const Color.fromARGB(247, 247, 247, 245),
                      ),
                    ),
                    Text(
                      l10n.nextMatch,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Expanded(child: const SizedBox()),
                TextButton(
                  onPressed: () {
                    context
                        .read<RoundSelectionCubit>()
                        .setSelectedRound(scheduledRound);
                  },
                  child: Text(l10n.showFullRound),
                )
              ],
            ),
            TournamentMatchContextSubtree.fromContext(
              key: ValueKey('WaitingMatch-${nextMatch.id}'),
              context: nextMatchContext,
              child: WaitingMatch(),
            ),
          ],
        ),
      ),
    );
  }
}
