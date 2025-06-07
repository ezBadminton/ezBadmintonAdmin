import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/cubit/tournament_plan_context_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/view/tournament_mode_assignment_page.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/draw_deletion_cubit.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/drawing_cubit.dart';
import 'package:ez_badminton_admin_app/draw_management/widgets/tournament_mode_card.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/cubit/competition_selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/dialog_listener.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/bracket_explorer_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/tournament_bracket_explorer.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/consolation_elimination_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/double_elimination_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/group_knockout_plan.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/round_robin_plan.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';

class DrawEditor extends StatelessWidget {
  const DrawEditor({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => BracketExplorerCubit(),
      child: BlocBuilder<CompetitionSelectionCubit, CompetitionSelectionState>(
        builder: (context, state) {
          if (state.selectedCompetition.value == null) {
            return Center(
              child: Text(
                l10n.noDrawCompetitionSelected,
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

          Widget drawView;

          if (selectedCompetition.tournamentModeSettings == null) {
            drawView = _TournamentModeAssignmentMenu(
              selectedCompetition: selectedCompetition,
            );
          } else if (selectedCompetition.draw.isNotEmpty) {
            drawView = _InteractiveDraw(competition: selectedCompetition);
          } else {
            drawView = _DrawMenu(selectedCompetition: selectedCompetition);
          }

          return MultiBlocProvider(
            providers: [
              BlocProvider(
                key: ValueKey('DrawingCubit-${selectedCompetition.id}'),
                create: (context) => DrawingCubit(
                  competition: selectedCompetition,
                  drawEndpoint: context.read(),
                  redrawEndpoint: context.read(),
                  swapEndpoint: context.read(),
                ),
              ),
              BlocProvider(
                key: ValueKey('DrawDeletionCubit-${selectedCompetition.id}'),
                create: (context) => DrawDeletionCubit(
                  competition: selectedCompetition,
                  deleteEndpoint: context.read(),
                ),
              ),
            ],
            child: drawView,
          );
        },
      ),
    );
  }
}

class _InteractiveDraw extends StatelessWidget {
  const _InteractiveDraw({
    required this.competition,
  });

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    return TournamentPlanContextSubtree(
      key: ValueKey('DrawEditorContext-${competition.id}'),
      competition: competition,
      child:
          BlocBuilder<TournamentPlanContextCubit, TournamentPlanContextState>(
        builder: (context, state) {
          return LoadingScreen(
            loadingStatus: state.tournamentPlan == null
                ? LoadingStatus.loading
                : LoadingStatus.done,
            builder: (context) {
              TournamentPlan tPlan = state.tournamentPlan!;

              SectionedBracket drawView = switch (tPlan.tournament) {
                SingleElimination tournament => SingleEliminationTree(
                    rounds: tournament.rounds,
                    isEditable: !tPlan.started,
                  ),
                RoundRobin _ => RoundRobinPlan(
                    isEditable: !tPlan.started,
                  ),
                GroupKnockout t => GroupKnockoutPlan(
                    isEditable: !tPlan.started,
                    sections: GroupKnockoutPlan.getSections(t),
                  ),
                DoubleElimination t => DoubleEliminationTree(
                    isEditable: !tPlan.started,
                    sections: DoubleEliminationTree.getSections(t),
                  ),
                SingleEliminationWithConsolation t =>
                  ConsolationEliminationTree(
                    isEditable: !tPlan.started,
                    sections:
                        SingleEliminationTree.getSections(t.mainBracket.rounds),
                  ),
              };

              return TournamentBracketExplorer(
                key: ValueKey('DrawEditor-${competition.id}'),
                competition: competition,
                tournamentBracket: drawView,
              );
            },
          );
        },
      ),
    );
  }
}

class _DrawMenu extends StatelessWidget {
  const _DrawMenu({
    required this.selectedCompetition,
  });

  final Competition selectedCompetition;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Builder(builder: (context) {
      var cubit = context.read<DrawingCubit>();
      return DialogListener<DrawingCubit, DrawingState, void>(
        barrierDismissable: true,
        builder: (context, state, minParticipants) => AlertDialog(
          title: Text(l10n.notEnoughDrawParticipants),
          content: Text(l10n.notEnoughDrawParticipantsInfo(minParticipants)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.confirm),
            ),
          ],
        ),
        child: Center(
          child: TournamentModeCard(
            modeSettings: selectedCompetition.tournamentModeSettings!,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: cubit.makeDraw,
                  style: const ButtonStyle(
                    shape: MaterialStatePropertyAll(StadiumBorder()),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      l10n.makeDraw,
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                _TournamentModeAssignmentButton(
                  selectedCompetition: selectedCompetition,
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _TournamentModeAssignmentMenu extends StatelessWidget {
  const _TournamentModeAssignmentMenu({
    required this.selectedCompetition,
  });

  final Competition selectedCompetition;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.noTournamentMode,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(.25),
              fontSize: 25,
            ),
          ),
          const SizedBox(height: 30),
          _TournamentModeAssignmentButton(
            selectedCompetition: selectedCompetition,
          ),
        ],
      ),
    );
  }
}

class _TournamentModeAssignmentButton extends StatelessWidget {
  const _TournamentModeAssignmentButton({
    required this.selectedCompetition,
  });

  final Competition selectedCompetition;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    bool isEditButton = selectedCompetition.tournamentModeSettings != null;

    Text buttonLabel = Text(
      isEditButton ? l10n.changeTournamentMode : l10n.assignTournamentMode,
    );

    onPressed() {
      Navigator.push(
        context,
        TournamentModeAssignmentPage.route([selectedCompetition]),
      );
    }

    if (isEditButton) {
      return TextButton(
        onPressed: onPressed,
        child: buttonLabel,
      );
    } else {
      return ElevatedButton(
        onPressed: onPressed,
        child: buttonLabel,
      );
    }
  }
}
