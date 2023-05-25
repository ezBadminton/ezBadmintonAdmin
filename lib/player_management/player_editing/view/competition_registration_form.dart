import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/player_editing_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/custom_input_fields/age_group_input.dart';
import 'package:ez_badminton_admin_app/widgets/custom_input_fields/competition_type_input.dart';
import 'package:ez_badminton_admin_app/widgets/custom_input_fields/gender_category_input.dart';
import 'package:ez_badminton_admin_app/widgets/custom_input_fields/playing_level_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompetitionRegistrationForm extends StatelessWidget {
  const CompetitionRegistrationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerEditingCubit, PlayerEditingState>(
      builder: (context, state) {
        return Column(
          children: <Widget>[
            for (int i = 0; i < state.registrations.length; i++)
              _CompetitionForm(registrationIndex: i),
            const _RegistrationSubmitButton()
          ],
        );
      },
    );
  }
}

class _RegistrationSubmitButton extends StatelessWidget {
  const _RegistrationSubmitButton();

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<PlayerEditingCubit>();
    return ElevatedButton(
      onPressed: cubit.addRegistration,
      child: const Text('Neue Meldung'),
    );
  }
}

class _CompetitionForm extends StatelessWidget {
  const _CompetitionForm({required this.registrationIndex});

  final int registrationIndex;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<PlayerEditingCubit>();
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<PlayerEditingCubit, PlayerEditingState>(
      builder: (context, state) {
        var registration = state.registrations[registrationIndex];
        return Stepper(
          currentStep: registration.formStep,
          onStepContinue: () => cubit.formStepForward(registrationIndex),
          steps: [
            if (cubit.getAvailablePlayingLevels().isNotEmpty)
              Step(
                title: Text(l10n.playingLevel),
                content:
                    _PlayingLevelInput(registrationIndex: registrationIndex),
              ),
            if (cubit.getAvailableAgeGroups().isNotEmpty)
              Step(
                title: Text(l10n.ageGroup),
                content: _AgeGroupInput(registrationIndex: registrationIndex),
              ),
            Step(
              title: Text(l10n.competition),
              content: Row(
                children: [
                  _GenderCategoryInput(registrationIndex: registrationIndex),
                  const SizedBox(width: 10),
                  _CompetitionTypeInput(registrationIndex: registrationIndex),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CompetitionTypeInput extends StatelessWidget {
  const _CompetitionTypeInput({
    required this.registrationIndex,
  });

  final int registrationIndex;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<PlayerEditingCubit>();
    return Expanded(
      child: BlocBuilder<PlayerEditingCubit, PlayerEditingState>(
        buildWhen: (previous, current) =>
            previous.registrations[registrationIndex].competitionType !=
            current.registrations[registrationIndex].competitionType,
        builder: (context, state) {
          return CompetitionTypeInput(
            onChanged: (competitionType) => cubit.competitionTypeChanged(
                registrationIndex, competitionType),
            currentValue:
                state.registrations[registrationIndex].competitionType.value,
            competitionTypeOptions: cubit.getAvailableCompetitionTypes(),
          );
        },
      ),
    );
  }
}

class _GenderCategoryInput extends StatelessWidget {
  const _GenderCategoryInput({
    required this.registrationIndex,
  });

  final int registrationIndex;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<PlayerEditingCubit>();
    return Expanded(
      child: BlocBuilder<PlayerEditingCubit, PlayerEditingState>(
        buildWhen: (previous, current) =>
            previous.registrations[registrationIndex].genderCategory !=
            current.registrations[registrationIndex].genderCategory,
        builder: (context, state) {
          return GenderCategoryInput(
            onChanged: (genderCategory) =>
                cubit.genderCategoryChanged(registrationIndex, genderCategory),
            currentValue:
                state.registrations[registrationIndex].genderCategory.value,
            genderCategoryOptions: cubit.getAvailableGenderCategories(),
          );
        },
      ),
    );
  }
}

class _AgeGroupInput extends StatelessWidget {
  const _AgeGroupInput({
    required this.registrationIndex,
  });

  final int registrationIndex;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<PlayerEditingCubit>();
    return BlocBuilder<PlayerEditingCubit, PlayerEditingState>(
      buildWhen: (previous, current) =>
          previous.registrations[registrationIndex].ageGroup !=
          current.registrations[registrationIndex].ageGroup,
      builder: (context, state) {
        return AgeGroupInput(
          onChanged: (ageGroup) =>
              cubit.ageGroupChanged(registrationIndex, ageGroup),
          currentValue: state.registrations[registrationIndex].ageGroup.value,
          ageGroupOptions: cubit.getAvailableAgeGroups(),
        );
      },
    );
  }
}

class _PlayingLevelInput extends StatelessWidget {
  const _PlayingLevelInput({
    required this.registrationIndex,
  });

  final int registrationIndex;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<PlayerEditingCubit>();
    return BlocBuilder<PlayerEditingCubit, PlayerEditingState>(
      buildWhen: (previous, current) =>
          previous.registrations[registrationIndex].playingLevel !=
          current.registrations[registrationIndex].playingLevel,
      builder: (context, state) {
        return PlayingLevelInput(
          onChanged: (playingLevel) => cubit.competitionPlayingLevelChanged(
            registrationIndex,
            playingLevel,
          ),
          currentValue:
              state.registrations[registrationIndex].playingLevel.value,
          playingLevelOptions: cubit.getAvailablePlayingLevels(),
        );
      },
    );
  }
}
