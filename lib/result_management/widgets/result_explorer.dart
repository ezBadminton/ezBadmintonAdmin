import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_cubit.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_state.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/cubit/competition_selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/leaderboard/leaderboard.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/tournament_bracket_explorer_controller_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/tournament_bracket_explorer.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/consolation_elimination_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/double_elimination_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/group_knockout_results.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/round_robin_results.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/cubit/tournament_plan_context_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:model_repository/model_repository.dart';

class ResultExplorer extends StatelessWidget {
  const ResultExplorer({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => TournamentBracketExplorerControllerCubit(),
      child: BlocListener<TabNavigationCubit, TabNavigationState>(
        listenWhen: (previous, current) =>
            current.tabChangeReason != null && current.selectedIndex == 5,
        listener: (context, navigationState) => _handleTabChangeReason(
          context,
          navigationState.tabChangeReason!,
        ),
        child:
            BlocBuilder<CompetitionSelectionCubit, CompetitionSelectionState>(
          builder: (context, selectionState) {
            if (selectionState.selectedCompetition.value == null) {
              return Center(
                child: Text(
                  l10n.noResultCompetitionSelected,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(.25),
                    fontSize: 25,
                  ),
                ),
              );
            }

            Competition selectedCompetition =
                selectionState.selectedCompetition.value!;

            bool hasStarted = selectedCompetition.matches.isNotEmpty;

            if (!hasStarted) {
              return Center(
                child: Text(
                  l10n.noResultsYet,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(.65),
                    fontSize: 25,
                  ),
                ),
              );
            }

            return _InteractiveResultExplorer(competition: selectedCompetition);
          },
        ),
      ),
    );
  }

  void _handleTabChangeReason(
    BuildContext context,
    Object tabChangeReason,
  ) {
    Competition? competition = switch (tabChangeReason) {
      Competition competition => competition,
      List<MatchContext> matchList =>
        matchList.first.tournamentPlan.competition,
      _ => null,
    };

    if (competition == null) {
      return;
    }

    var selectionCubit = context.read<CompetitionSelectionCubit>();
    var controllerCubit =
        context.read<TournamentBracketExplorerControllerCubit>();

    selectionCubit.competitionSelected(competition);

    if (tabChangeReason is! List) {
      // When the tab change reason is a list it is a list of tournament
      // data objects which's bracket sections should be focused
      return;
    }

    Iterable<TournamentMatch> matches =
        tabChangeReason.map((mContext) => mContext.match);

    List<GlobalKey> keys = matches
        .map((tournamentDataObject) => GlobalObjectKey(tournamentDataObject))
        .toList();

    Future.delayed(
      const Duration(milliseconds: 100),
      () =>
          controllerCubit.getViewController(competition).focusGlobalKeys(keys),
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
    return TournamentPlanContextSubtree(
      key: ValueKey('ResultExplorer-${competition.id}'),
      competition: competition,
      child:
          BlocBuilder<TournamentPlanContextCubit, TournamentPlanContextState>(
        builder: (context, state) {
          return LoadingScreen(
              loadingStatus: state.tournamentPlan == null
                  ? LoadingStatus.loading
                  : LoadingStatus.done,
              builder: (context) {
                var l10n = AppLocalizations.of(context)!;

                TournamentPlan tPlan = state.tournamentPlan!;

                Widget resultView = switch (tPlan.tournament) {
                  SingleElimination tournament => SingleEliminationTree(
                      rounds: tournament.rounds,
                      showResults: true,
                    ),
                  RoundRobin _ => RoundRobinResults(),
                  GroupKnockout _ => GroupKnockoutResults(),
                  DoubleElimination _ =>
                    DoubleEliminationTree(showResults: true),
                  SingleEliminationWithConsolation _ =>
                    ConsolationEliminationTree(
                      showResults: true,
                    ),
                };

                return TournamentBracketExplorer(
                  competition: competition,
                  tournamentBracket: resultView,
                  controlBarOptionsBuilder: (compact) {
                    onPressed() {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return TournamentPlanContextSubtree(
                            key:
                                ValueKey('LeaderboardDialog-${competition.id}'),
                            competition: competition,
                            child: AlertDialog(
                              title: Text(l10n.leaderboard),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ProvisionalLeaderboardInfo(),
                                  Flexible(
                                    child: SingleChildScrollView(
                                      child: Leaderboard(),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(l10n.confirm),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }

                    if (compact) {
                      return Tooltip(
                        message: l10n.leaderboard,
                        child: SizedBox(
                          width: 40,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: onPressed,
                            child: const Icon(Icons.emoji_events),
                          ),
                        ),
                      );
                    }

                    return TextButton(
                      onPressed: onPressed,
                      child: SizedBox(
                        width: 160,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emoji_events),
                              const SizedBox(width: 7),
                              Text(l10n.leaderboard),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              });
        },
      ),
    );
  }
}
