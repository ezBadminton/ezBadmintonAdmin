import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/cubit/competition_selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/tournament_bracket_explorer_controller_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/tournament_bracket_explorer.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/group_knockout_results.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/round_robin_results.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResultExplorer extends StatelessWidget {
  const ResultExplorer({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => TournamentBracketExplorerControllerCubit(),
      child: BlocBuilder<CompetitionSelectionCubit, CompetitionSelectionState>(
        builder: (context, state) {
          if (state.selectedCompetition.value == null) {
            return Center(
              child: Text(
                l10n.noResultCompetitionSelected,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(.25),
                  fontSize: 25,
                ),
              ),
            );
          }

          Competition selectedCompetition = state.selectedCompetition.value!;

          bool hasStarted = selectedCompetition.matches.isNotEmpty;

          if (!hasStarted) {
            return Center(
              child: Text(
                l10n.noResultsYet,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(.65),
                  fontSize: 25,
                ),
              ),
            );
          }

          return _InteractiveResultExplorer(competition: selectedCompetition);
        },
      ),
    );
  }
}

class _InteractiveResultExplorer extends StatelessWidget {
  const _InteractiveResultExplorer({
    required this.competition,
  });

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    TournamentProgressState progressState =
        context.read<TournamentProgressCubit>().state;

    BadmintonTournamentMode tournament =
        progressState.runningTournaments[competition]!;

    Widget resultView = switch (tournament) {
      BadmintonSingleElimination tournament => SingleEliminationTree(
          rounds: tournament.rounds,
          competition: competition,
          showResults: true,
        ),
      BadmintonRoundRobin tournament => RoundRobinResults(
          tournament: tournament,
        ),
      BadmintonGroupKnockout tournament => GroupKnockoutResults(
          tournament: tournament,
        ),
      _ => const Text('No View implemented yet'),
    };

    return TournamentBracketExplorer(
      key: ValueKey('ResultExplorer-${competition.id}'),
      competition: competition,
      tournamentBracket: resultView,
      controlBarOptionsBuilder: (_) => const SizedBox(),
    );
  }
}
