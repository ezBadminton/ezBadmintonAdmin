import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_deletion_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_selection_cubit.dart';
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
    return BlocProvider(
      create: (context) => CompetitionDeletionCubit(
        competitionRepository:
            context.read<CollectionRepository<Competition>>(),
        teamRepository: context.read<CollectionRepository<Team>>(),
      ),
      child: BlocConsumer<CompetitionSelectionCubit, CompetitionSelectionState>(
        listener: (context, state) {
          var deletionCubit = context.read<CompetitionDeletionCubit>();
          deletionCubit.selectedCompetitionsChanged(state.selectedCompetitions);
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
                  const _CompetitionDeleteButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompetitionDeleteButton extends StatelessWidget {
  const _CompetitionDeleteButton();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var deletionCubit = context.read<CompetitionDeletionCubit>();
    return BlocBuilder<CompetitionSelectionCubit, CompetitionSelectionState>(
      builder: (context, state) {
        int numSelected = state.selectedCompetitions.length;
        return BlocBuilder<CompetitionDeletionCubit, CompetitionDeletionState>(
          builder: (context, state) {
            return DialogListener<CompetitionDeletionCubit,
                CompetitionDeletionState, bool>(
              builder: (context, state, reason) {
                bool teamsWillBeDeleted = reason as bool;

                String warningMessage =
                    l10n.deleteCompetitionsWarning(numSelected);
                if (teamsWillBeDeleted) {
                  warningMessage +=
                      '\n${l10n.deleteCompetitionsWithTeamsWarning}';
                }

                return ConfirmDialog(
                  confirmButtonLabel: l10n.confirm,
                  cancelButtonLabel: l10n.cancel,
                  title: Text(l10n.deleteCompetitions),
                  content: Text(warningMessage),
                );
              },
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: numSelected == 0 ? 0.0 : 1.0,
                child: TextButton(
                  onPressed:
                      state.formStatus == FormzSubmissionStatus.inProgress ||
                              numSelected == 0
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
              ),
            );
          },
        );
      },
    );
  }
}
