import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/view/tournament_mode_assignment_page.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/draw_deletion_cubit.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/draw_editing_cubit.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/drawing_cubit.dart';
import 'package:ez_badminton_admin_app/draw_management/widgets/tournament_mode_card.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/tournament_mode_hydration.dart';
import 'package:ez_badminton_admin_app/utils/confirmation_cubit/confirmation_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/cubit/competition_selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/dialog_listener.dart';
import 'package:ez_badminton_admin_app/widgets/dialogs/confirm_dialog.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/tournament_bracket_explorer_controller_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/tournament_bracket_explorer.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/group_knockout_plan.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/round_robin_plan.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DrawEditor extends StatelessWidget {
  const DrawEditor({super.key});

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
                  competitionRepository:
                      context.read<CollectionRepository<Competition>>(),
                ),
              ),
              BlocProvider(
                key: ValueKey('DrawDeletionCubit-${selectedCompetition.id}'),
                create: (context) => DrawDeletionCubit(
                  competition: selectedCompetition,
                  competitionRepository:
                      context.read<CollectionRepository<Competition>>(),
                ),
              ),
              BlocProvider(
                key: ValueKey<String>(
                    'DrawEditingCubit${selectedCompetition.id}'),
                create: (context) => DrawEditingCubit(
                  competition: selectedCompetition,
                  competitionRepository:
                      context.read<CollectionRepository<Competition>>(),
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
    BadmintonTournamentMode tournament = createTournamentMode(competition);
    hydrateTournament(competition, tournament, null);

    tournament.freezeRankings();

    Widget drawView = switch (tournament) {
      BadmintonSingleElimination tournament => SingleEliminationTree(
          rounds: tournament.rounds,
          competition: competition,
          isEditable: true,
        ),
      BadmintonRoundRobin tournament => RoundRobinPlan(
          tournament: tournament,
        ),
      BadmintonGroupKnockout tournament => GroupKnockoutPlan(
          tournament: tournament,
        ),
      _ => const Text('No View implemented yet'),
    };

    return TournamentBracketExplorer(
      key: ValueKey('DrawEditor-${competition.id}'),
      competition: competition,
      tournamentBracket: drawView,
      controlBarOptionsBuilder: (bool compact) =>
          _ControlBarDrawOptions(compact: compact),
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

class _ControlBarDrawOptions extends StatelessWidget {
  const _ControlBarDrawOptions({
    required this.compact,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    var drawingCubit = context.read<DrawingCubit>();
    var drawDeletionCubit = context.read<DrawDeletionCubit>();

    return BlocProvider(
      create: (context) => ConfirmationCubit(),
      child: DialogListener<ConfirmationCubit, ConfirmationState, bool>(
        builder: (context, state, reason) {
          String title = switch (reason as _ConfirmReason) {
            _ConfirmReason.undoManualDraw => l10n.undoManualDraw,
            _ConfirmReason.redraw => l10n.redraw,
            _ConfirmReason.deleteDraw => l10n.deleteSubject(l10n.draw(1)),
          };

          String body = switch (reason) {
            _ConfirmReason.undoManualDraw => l10n.undoManualDrawWarning,
            _ConfirmReason.redraw => l10n.redrawWarning,
            _ConfirmReason.deleteDraw => l10n.deleteDrawWarning,
          };

          return ConfirmDialog(
            title: Text(title),
            content: Text(body),
            confirmButtonLabel: l10n.confirm,
            cancelButtonLabel: l10n.cancel,
          );
        },
        child: Builder(builder: (context) {
          var confirmationCubit = context.read<ConfirmationCubit>();

          undoManualDraw() => confirmationCubit.executeWithConfirmation(
                drawingCubit.makeDraw,
                reason: _ConfirmReason.undoManualDraw,
              );

          redraw() => confirmationCubit.executeWithConfirmation(
                drawingCubit.redraw,
                reason: _ConfirmReason.redraw,
              );

          deleteDraw() => confirmationCubit.executeWithConfirmation(
                drawDeletionCubit.deleteDraw,
                reason: _ConfirmReason.deleteDraw,
              );

          if (compact) {
            return PopupMenuButton<VoidCallback>(
              onSelected: (callback) => callback(),
              tooltip: '',
              splashRadius: 19,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: undoManualDraw,
                  child: Text(l10n.undoManualDraw),
                ),
                PopupMenuItem(
                  value: redraw,
                  child: Text(l10n.redraw),
                ),
                PopupMenuItem(
                  value: deleteDraw,
                  child: Text(
                    l10n.deleteSubject(l10n.draw(1)),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Tooltip(
                  message: l10n.undoManualDraw,
                  waitDuration: const Duration(milliseconds: 500),
                  child: TextButton(
                    onPressed: undoManualDraw,
                    child: const Icon(Icons.restore),
                  ),
                ),
                Tooltip(
                  message: l10n.redraw,
                  waitDuration: const Duration(milliseconds: 500),
                  child: TextButton(
                    onPressed: redraw,
                    child: const Icon(Icons.casino_outlined),
                  ),
                ),
                Tooltip(
                  message: l10n.deleteSubject(l10n.draw(1)),
                  waitDuration: const Duration(milliseconds: 500),
                  child: TextButton(
                    onPressed: deleteDraw,
                    child: const Icon(Icons.delete),
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}

enum _ConfirmReason {
  undoManualDraw,
  redraw,
  deleteDraw,
}
