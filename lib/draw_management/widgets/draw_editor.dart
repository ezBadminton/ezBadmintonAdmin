import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/view/tournament_mode_assignment_page.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/competition_draw_selection_cubit.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/draw_editing_cubit.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/drawing_cubit.dart';
import 'package:ez_badminton_admin_app/draw_management/widgets/tournament_mode_card.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/group_knockout_plan.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/round_robin_plan.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:local_hero/local_hero.dart';
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

        if (selectedCompetition.draw.isNotEmpty) {
          return _InteractiveDraw(competition: selectedCompetition);
        }

        return _DrawMenu(selectedCompetition: selectedCompetition);
      },
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
    DrawSeeds<Team> entries = DrawSeeds(competition.draw);

    TournamentMode tournament = switch (competition.tournamentModeSettings!) {
      SingleEliminationSettings _ =>
        BadmintonSingleElimination(seededEntries: entries),
      RoundRobinSettings settings =>
        BadmintonRoundRobin(entries: entries, settings: settings),
      GroupKnockoutSettings settings =>
        BadmintonGroupKnockout(entries: entries, settings: settings),
    };

    Widget drawView = switch (tournament) {
      BadmintonSingleElimination tournament => SingleEliminationTree(
          rounds: tournament.rounds,
          competition: competition,
          isEditable: true,
        ),
      BadmintonRoundRobin tournament => RoundRobinPlan(
          tournament: tournament,
          competition: competition,
        ),
      BadmintonGroupKnockout tournament => GroupKnockoutPlan(
          tournament: tournament,
          competition: competition,
        ),
      _ => const Text('No View implemented yet'),
    };

    return BlocProvider(
      key: ValueKey<String>('DrawEditingCubit${competition.id}'),
      create: (context) => DrawEditingCubit(
        competition: competition,
        competitionRepository:
            context.read<CollectionRepository<Competition>>(),
      ),
      child: InteractiveViewer(
        constrained: false,
        minScale: .1,
        boundaryMargin: const EdgeInsets.all(400),
        scaleFactor: 1500,
        child: LocalHeroScope(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutQuad,
          onlyAnimateRemount: true,
          child: drawView,
        ),
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
