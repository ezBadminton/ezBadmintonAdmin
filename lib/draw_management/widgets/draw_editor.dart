import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/view/tournament_mode_assignment_page.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/competition_draw_selection_cubit.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/drawing_cubit.dart';
import 'package:ez_badminton_admin_app/draw_management/models/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/draw_management/widgets/tournament_mode_card.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tournament_mode/tournament_mode.dart';

class DrawEditor extends StatelessWidget {
  const DrawEditor({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocBuilder<CompetitionDrawSelectionCubit,
        CompetitionDrawSelectionState>(
      builder: (context, state) {
        if (state.selectedCompetition.value == null) {
          return Center(
            child: Text(
              l10n.noDrawCompetitionSelected,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.25),
                fontSize: 25,
              ),
            ),
          );
        }

        Competition selectedCompetition = state.selectedCompetition.value!;

        if (selectedCompetition.tournamentModeSettings == null) {
          return _TournamentModeAssignmentMenu(
            selectedCompetition: selectedCompetition,
          );
        }

        if (selectedCompetition.draw.isNotEmpty &&
            selectedCompetition.tournamentModeSettings
                is SingleEliminationSettings) {
          BadmintonSingleElimination tournament = BadmintonSingleElimination(
            seededEntries: DrawSeeds(selectedCompetition.draw),
          );

          return SingleEliminationTree(
            rounds: tournament.rounds,
            competition: selectedCompetition,
          );
        }

        return _DrawMenu(selectedCompetition: selectedCompetition);
      },
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

    return BlocProvider(
      create: (context) => DrawingCubit(
        competition: selectedCompetition,
        competitionRepository:
            context.read<CollectionRepository<Competition>>(),
      ),
      child: Builder(builder: (context) {
        var cubit = context.read<DrawingCubit>();
        return Center(
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
        );
      }),
    );
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
