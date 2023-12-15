import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/basic_settings_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_assignment_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_settings_state.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/scoring_settings_widget.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/seeding_mode_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BasicSettingsWidget<S extends TournamentModeSettings>
    extends StatelessWidget {
  const BasicSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var assignmentCubit = context.read<TournamentModeAssignmentCubit>();

    return BlocProvider(
      create: (context) => BasicSettingsCubit<S>(
        TournamentModeSettingsState(
          settings: assignmentCubit.state.modeSettings.value as S,
        ),
      ),
      child:
          BlocListener<BasicSettingsCubit<S>, TournamentModeSettingsState<S>>(
        listener: (context, state) {
          assignmentCubit.tournamentModeSettingsChanged(state.settings);
        },
        child: Column(
          children: [
            _SeedingModeSelector<S>(),
            ScoringSettingsWidget<BasicSettingsCubit<S>, S>(),
          ],
        ),
      ),
    );
  }
}

class _SeedingModeSelector<S extends TournamentModeSettings>
    extends StatelessWidget {
  const _SeedingModeSelector();

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<BasicSettingsCubit<S>>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SeedingModeSelector(
          onChanged: cubit.seedingModeChanged,
        ),
      ),
    );
  }
}
