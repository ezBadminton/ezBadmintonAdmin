import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_deletion_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_selection_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_starting_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/view/tournament_mode_assignment_page.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/dialog_listener.dart';
import 'package:ez_badminton_admin_app/widgets/dialogs/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';

class CompetitionSelectionOptions extends StatelessWidget {
  const CompetitionSelectionOptions({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CompetitionDeletionCubit(
            competitionRepository:
                context.read<CollectionRepository<Competition>>(),
            teamRepository: context.read<CollectionRepository<Team>>(),
          ),
        ),
        BlocProvider(
          create: (context) => CompetitionStartingCubit(
            competitionRepository:
                context.read<CollectionRepository<Competition>>(),
            matchRepository: context.read<CollectionRepository<Match>>(),
          ),
        ),
      ],
      child: BlocConsumer<CompetitionSelectionCubit, CompetitionSelectionState>(
        listener: (context, state) {
          var deletionCubit = context.read<CompetitionDeletionCubit>();
          var startingCubit = context.read<CompetitionStartingCubit>();

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
    var startingCubit = context.read<CompetitionStartingCubit>();
    var l10n = AppLocalizations.of(context)!;

    return DialogListener<CompetitionStartingCubit, CompetitionStartingState,
        bool>(
      builder: (context, state, reason) {
        return ConfirmDialog(
          title: Text(l10n.startTournament),
          content: Text(l10n.startTournamentInfo),
          confirmButtonLabel: l10n.confirm,
          cancelButtonLabel: l10n.cancel,
        );
      },
      child: DialogListener<CompetitionStartingCubit, CompetitionStartingState,
          Exception>(
        builder: (context, state, _) {
          return AlertDialog(
            title: Text(l10n.somethingWentWrong),
            content: Text(l10n.tournamentCouldNotStart),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.confirm),
              ),
            ],
          );
        },
        child: BlocBuilder<CompetitionStartingCubit, CompetitionStartingState>(
          builder: (context, state) {
            return ElevatedButton(
              onPressed: state.selectedCompetitions.isEmpty ||
                      !state.selectionIsStartable
                  ? null
                  : startingCubit.startCompetitions,
              child: Text(l10n.startTournament),
            );
          },
        ),
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
    return ElevatedButton(
      onPressed: selectedCompetitions.isEmpty
          ? null
          : () {
              Navigator.of(context).push(
                TournamentModeAssignmentPage.route(selectedCompetitions),
              );
            },
      child: Text(l10n.assignTournamentMode),
    );
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
          child: TextButton(
            onPressed: state.formStatus == FormzSubmissionStatus.inProgress ||
                    selectedCompetitions.isEmpty
                ? null
                : deletionCubit.deleteSelectedCompetitions,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context)
                  .colorScheme
                  .error
                  .withOpacity(.65), // Text Color
            ),
            child: Text(
              l10n.deleteSubject(l10n.competition(2)),
            ),
          ),
        );
      },
    );
  }
}
