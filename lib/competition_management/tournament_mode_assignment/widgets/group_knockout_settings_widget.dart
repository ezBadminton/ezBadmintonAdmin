import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/group_knockout_settings_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_assignment_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_settings_state.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/consolation_settings_widget.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/scoring_settings_widget.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/seeding_mode_selector.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/setting_card.dart';
import 'package:ez_badminton_admin_app/constants.dart' as constants;
import 'package:ez_badminton_admin_app/widgets/integer_stepper/integer_stepper.dart';
import 'package:ez_badminton_admin_app/widgets/tooltip_dropdown_menu_item/tooltip_dropdown_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GroupKnockoutSettingsWidget extends StatelessWidget {
  const GroupKnockoutSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var assignmentCubit = context.read<TournamentModeAssignmentCubit>();
    return BlocProvider(
      create: (context) => GroupKnockoutSettingsCubit(
        TournamentModeSettingsState(
          settings:
              assignmentCubit.state.modeSettings.value as GroupKnockoutSettings,
        ),
      ),
      child: BlocConsumer<GroupKnockoutSettingsCubit,
          TournamentModeSettingsState<GroupKnockoutSettings>>(
        listener: (context, state) {
          assignmentCubit.tournamentModeSettingsChanged(state.settings);
        },
        builder: (context, state) {
          List<Widget>? knockOutSettings =
              state.settings.knockOutMode == KnockOutMode.consolation
                  ? [
                      const NumConsolationRoundsStepper<
                          GroupKnockoutSettingsCubit>(),
                      const PlacesToPlayOutInput<GroupKnockoutSettingsCubit>(),
                    ]
                  : null;

          return Column(
            children: [
              const _NumGroupsInputStepper(),
              const _NumQualificationsInputStepper(),
              const _SeedingModeSelector(),
              const _KnockOutModeSelector(),
              if (knockOutSettings != null) ...knockOutSettings,
              const ScoringSettingsWidget<GroupKnockoutSettingsCubit,
                  GroupKnockoutSettings>(),
            ],
          );
        },
      ),
    );
  }
}

class _NumGroupsInputStepper extends StatelessWidget {
  const _NumGroupsInputStepper();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<GroupKnockoutSettingsCubit>();

    return SettingCard(
      title: Text(l10n.numGroups),
      helpText: l10n.numGroupsHelp,
      child: IntegerStepper(
        onChanged: cubit.numGroupsChanged,
        initialValue: cubit.state.settings.numGroups,
        minValue: constants.minGroups,
        maxValue: constants.maxGroups,
      ),
    );
  }
}

class _NumQualificationsInputStepper extends StatelessWidget {
  const _NumQualificationsInputStepper();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<GroupKnockoutSettingsCubit>();

    return SettingCard(
      title: Text(l10n.numQualifications),
      helpText: l10n.numQualificationsHelp,
      child: IntegerStepper(
        onChanged: cubit.numQualificationsChanged,
        initialValue: cubit.state.settings.numQualifications,
        minValue: constants.minQualificationsPerGroup,
        maxValue: constants.maxQualificationsPerGroup,
      ),
    );
  }
}

class _SeedingModeSelector extends StatelessWidget {
  const _SeedingModeSelector();

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<GroupKnockoutSettingsCubit>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 25.0),
        child: SeedingModeSelector(
          onChanged: cubit.seedingModeChanged,
        ),
      ),
    );
  }
}

class _KnockOutModeSelector extends StatelessWidget {
  const _KnockOutModeSelector();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<GroupKnockoutSettingsCubit>();

    return BlocBuilder<GroupKnockoutSettingsCubit,
        TournamentModeSettingsState<GroupKnockoutSettings>>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 25.0),
            child: DropdownButtonFormField(
              value: state.settings.knockOutMode,
              onChanged: (value) => cubit.knockOutModeChanged(value!),
              decoration: InputDecoration(labelText: l10n.knockOutMode),
              isExpanded: true,
              items: [
                TooltipDropdownMenuItem(
                  value: KnockOutMode.single,
                  label: l10n.singleElimination,
                  helpText: l10n.singleEliminationHelp,
                ),
                TooltipDropdownMenuItem(
                  value: KnockOutMode.double,
                  label: l10n.doubleElimination,
                  helpText: l10n.doubleEliminationHelp,
                ),
                TooltipDropdownMenuItem(
                  value: KnockOutMode.consolation,
                  label: l10n.consolationElimination,
                  helpText: l10n.consolationEliminationHelp,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
