import 'package:ez_badminton_admin_app/match_management/widgets/match_queue_list.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/queued_match.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/round_queue/cubit/round_selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/match_and_round_names.dart'
    as round_strings;

class RoundMatchQueueList extends StatelessWidget {
  const RoundMatchQueueList({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var state = context.read<RoundSelectionCubit>().state;
    var round = state.round;

    TextStyle queueTitleStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 16,
    );

    if (round == null) {
      return const SizedBox();
    }

    return TournamentPlanContextSubtree(
      key: ValueKey('RoundMatchQueue-${round.competition}-${round.roundIndex}'),
      competition: round.competition,
      child: MatchQueueList(
        width: 420,
        title: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CompetitionLabel(
                  competition: round.competition,
                  textStyle: queueTitleStyle,
                ),
                const SizedBox(height: 19),
                Center(
                  child: Text(round_strings.roundName(l10n, round)),
                )
              ],
            ),
            Positioned(
              left: 18,
              child: BackButton(
                onPressed: () {
                  context.read<RoundSelectionCubit>().unsetSelectedRound();
                },
              ),
            ),
          ],
        ),
        list: state.waitingMatches
            .map(
              (m) => ScheduledMatchContextSubtree(
                key: ValueKey('WaitingMatch-${m.id}'),
                match: m,
                child: WaitingMatch(),
              ),
            )
            .toList(),
      ),
    );
  }
}
