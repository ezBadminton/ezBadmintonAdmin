import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/group_knockout_settings_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/cubit/tournament_mode_assignment_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/seeding_mode_selector.dart';
import 'package:ez_badminton_admin_app/constants.dart' as constants;
import 'package:ez_badminton_admin_app/widgets/integer_stepper/integer_stepper_card.dart';
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
        assignmentCubit.state.modeSettings.value as GroupKnockoutSettings,
      ),
      child: BlocListener<GroupKnockoutSettingsCubit, GroupKnockoutSettings>(
        listener: (context, state) {
          assignmentCubit.tournamentModeSettingsChanged(state);
        },
        child: const Column(
          children: [
            _NumGroupsInputStepper(),
            _QualificationsPerGroupInputStepper(),
            _SeedingModeSelector(),
          ],
        ),
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

    return IntegerStepperCard(
      onChanged: cubit.numGroupsChanged,
      initialValue: cubit.state.numGroups,
      minValue: constants.minGroups,
      maxValue: constants.maxGroups,
      title: Text(l10n.numGroups),
      helpText: l10n.numGroupsHelp,
    );
  }
}

class _QualificationsPerGroupInputStepper extends StatelessWidget {
  const _QualificationsPerGroupInputStepper();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<GroupKnockoutSettingsCubit>();

    return IntegerStepperCard(
      onChanged: cubit.qualificationsPerGroupChanged,
      initialValue: cubit.state.qualificationsPerGroup,
      minValue: constants.minQualificationsPerGroup,
      maxValue: constants.maxQualificationsPerGroup,
      title: Text(l10n.qualificationsPerGroup),
      helpText: l10n.qualificationsPerGroupHelp,
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
