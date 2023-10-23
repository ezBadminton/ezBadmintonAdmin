import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/round_robin_settings_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_assignment_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_settings_state.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/scoring_settings_widget.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/setting_card.dart';
import 'package:ez_badminton_admin_app/constants.dart' as constants;
import 'package:ez_badminton_admin_app/widgets/integer_stepper/integer_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RoundRobinSettingsWidget extends StatelessWidget {
  const RoundRobinSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var assignmentCubit = context.read<TournamentModeAssignmentCubit>();
    return BlocProvider(
      create: (context) => RoundRobinSettingsCubit(
        TournamentModeSettingsState(
          settings:
              assignmentCubit.state.modeSettings.value as RoundRobinSettings,
        ),
      ),
      child: BlocListener<RoundRobinSettingsCubit,
          TournamentModeSettingsState<RoundRobinSettings>>(
        listener: (context, state) {
          assignmentCubit.tournamentModeSettingsChanged(state.settings);
        },
        child: const Column(
          children: [
            _PassesInputStepper(),
            ScoringSettingsWidget<RoundRobinSettingsCubit,
                RoundRobinSettings>(),
          ],
        ),
      ),
    );
  }
}

class _PassesInputStepper extends StatelessWidget {
  const _PassesInputStepper();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<RoundRobinSettingsCubit>();

    return SettingCard(
      title: Text(l10n.passes),
      helpText: l10n.roundRobinPassesHelp,
      child: IntegerStepper(
        onChanged: cubit.passesChanged,
        initialValue: cubit.state.settings.passes,
        minValue: 1,
        maxValue: constants.roundRobinMaxPasses,
      ),
    );
  }
}
