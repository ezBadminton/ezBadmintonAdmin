import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/view/tournament_mode_assignment_page.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/competition_draw_selection_cubit.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/drawing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          return _TournamentModeButton(
            selectedCompetition: selectedCompetition,
          );
        }

        return _DrawButton(selectedCompetition: selectedCompetition);
      },
    );
  }
}

class _DrawButton extends StatelessWidget {
  const _DrawButton({
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
          child: ElevatedButton(
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
        );
      }),
    );
  }
}

class _TournamentModeButton extends StatelessWidget {
  const _TournamentModeButton({
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
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                TournamentModeAssignmentPage.route([selectedCompetition]),
              );
            },
            child: Text(l10n.assignTournamentMode),
          ),
        ],
      ),
    );
  }
}
