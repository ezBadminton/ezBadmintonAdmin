import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_assignment_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/group_knockout_settings_widget.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/round_robin_settings_widget.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/single_elimination_settings_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TournamentModeSettingsWidget extends StatelessWidget {
  const TournamentModeSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TournamentModeAssignmentCubit,
        TournamentModeAssignmentState>(
      builder: (context, state) {
        return switch (state.modeType.value) {
          RoundRobinSettings => const RoundRobinSettingsWidget(),
          SingleEliminationSettings => const SingleEliminationSettingsWidget(),
          GroupKnockoutSettings => const GroupKnockoutSettingsWidget(),
          _ => const SizedBox(),
        };
      },
    );
  }
}
