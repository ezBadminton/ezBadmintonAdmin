import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_deletion_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_selection_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_start_stop_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/view/tournament_mode_assignment_page.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/dialog_listener.dart';
import 'package:ez_badminton_admin_app/widgets/dialogs/confirm_dialog.dart';
import 'package:ez_badminton_admin_app/widgets/long_tooltip/long_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';

class CompetitionSelectionOptions extends StatelessWidget {
  const CompetitionSelectionOptions({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => CompetitionDeletionCubit(
        competitionRepository:
            context.read<CollectionRepository<Competition>>(),
        teamRepository: context.read<CollectionRepository<Team>>(),
      ),
      child: BlocConsumer<CompetitionSelectionCubit, CompetitionSelectionState>(
        listener: (context, state) {
          var deletionCubit = context.read<CompetitionDeletionCubit>();
          var startingCubit = context.read<CompetitionStartStopCubit>();

          deletionCubit.selectedCompetitionsChanged(state.selectedCompetitions);
          startingCubit.selectedCompetitionsChanged(state.selectedCompetitions);
        },
        builder: (context, state) {
          int numSelected = state.selectedCompetitions.length;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(numSelected == 0 ? 0 : .25),
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 5.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.nSubjectsSelected(
                      numSelected,
                      l10n.competition(numSelected),
                    ),
                    style: TextStyle(
                      color: numSelected == 0
                          ? Theme.of(context).disabledColor
                          : null,
                    ),
                  ),
                  const SizedBox(width: 40),
                  const Expanded(child: _CompetitionSelectionOptionButtons()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompetitionSelectionOptionButtons extends StatelessWidget {
  const _CompetitionSelectionOptionButtons();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompetitionSelectionCubit, CompetitionSelectionState>(
      builder: (context, state) {
        int numSelected = state.selectedCompetitions.length;
        return AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: numSelected == 0 ? 0.0 : 1.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const _CompetitionStartButton(),
                const SizedBox(width: 20),
                _AssignTournamentModeButton(
                  selectedCompetitions: state.selectedCompetitions,
                ),
                const SizedBox(width: 60),
                _CompetitionDeleteButton(
                  selectedCompetitions: state.selectedCompetitions,
                ),
              ],
            ));
      },
    );
  }
}

class _CompetitionStartButton extends StatelessWidget {
  const _CompetitionStartButton();

  @override
  Widget build(BuildContext context) {
    var startingCubit = context.read<CompetitionStartStopCubit>();
    var l10n = AppLocalizations.of(context)!;

    return DialogListener<CompetitionStartStopCubit, CompetitionStartStopState,
        bool>(
      builder: (context, state, reason) {
        if (reason is Competition) {
          return ConfirmDialog(
            title: Text(l10n.cancelTournament),
            content: Text(l10n.cancelTournamentInfo),
            confirmButtonLabel: l10n.confirm,
            cancelButtonLabel: l10n.cancel,
          );
        } else {
          return ConfirmDialog(
            title: Text(l10n.startTournament),
            content: Text(l10n.startTournamentInfo),
            confirmButtonLabel: l10n.confirm,
            cancelButtonLabel: l10n.cancel,
          );
        }
      },
      child: BlocBuilder<CompetitionStartStopCubit, CompetitionStartStopState>(
        builder: (context, state) {
          return ElevatedButton(
            onPressed: state.selectedCompetitions.isEmpty ||
                    !state.selectionIsStartable
                ? null
                : startingCubit.competitionsStarted,
            child: Text(l10n.startTournament),
          );
        },
      ),
    );
  }
}

class _AssignTournamentModeButton extends StatelessWidget {
  const _AssignTournamentModeButton({
    required this.selectedCompetitions,
  });

  final List<Competition> selectedCompetitions;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    bool isModeAssignable = _isModeAssignable(selectedCompetitions);

    Widget button = ElevatedButton(
      onPressed: isModeAssignable
          ? () {
              Navigator.of(context).push(
                TournamentModeAssignmentPage.route(selectedCompetitions),
              );
            }
          : null,
      child: Text(l10n.assignTournamentMode),
    );

    if (isModeAssignable) {
      return button;
    } else {
      return LongTooltip(
        message: l10n.tournamentModeCantBeAssigned,
        child: button,
      );
    }
  }

  bool _isModeAssignable(List<Competition> competitions) {
    if (competitions.isEmpty) {
      return false;
    }

    bool areAllCompetitionsNotRunning = competitions.firstWhereOrNull(
          (competition) => competition.matches.isNotEmpty,
        ) ==
        null;

    return areAllCompetitionsNotRunning;
  }
}

class _CompetitionDeleteButton extends StatelessWidget {
  const _CompetitionDeleteButton({
    required this.selectedCompetitions,
  });

  final List<Competition> selectedCompetitions;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var deletionCubit = context.read<CompetitionDeletionCubit>();
    return BlocBuilder<CompetitionDeletionCubit, CompetitionDeletionState>(
      builder: (context, state) {
        Widget buttonWithTooltip;
        Widget button = TextButton(
          onPressed: state.formStatus != FormzSubmissionStatus.inProgress &&
                  state.isSelectionDeletable
              ? deletionCubit.deleteSelectedCompetitions
              : null,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context)
                .colorScheme
                .error
                .withOpacity(.65), // Text Color
          ),
          child: Text(
            l10n.deleteSubject(l10n.competition(2)),
          ),
        );

        if (state.isSelectionDeletable) {
          buttonWithTooltip = button;
        } else {
          buttonWithTooltip = LongTooltip(
            message: l10n.competitionCantBeDeleted,
            child: button,
          );
        }

        return DialogListener<CompetitionDeletionCubit,
            CompetitionDeletionState, bool>(
          builder: (context, state, reason) {
            bool teamsWillBeDeleted = reason as bool;

            String warningMessage =
                l10n.deleteCompetitionsWarning(selectedCompetitions.length);
            if (teamsWillBeDeleted) {
              warningMessage += '\n${l10n.deleteCompetitionsWithTeamsWarning}';
            }

            return ConfirmDialog(
              confirmButtonLabel: l10n.confirm,
              cancelButtonLabel: l10n.cancel,
              title: Text(l10n.deleteCompetitions),
              content: Text(warningMessage),
            );
          },
          child: buttonWithTooltip,
        );
      },
    );
  }
}
