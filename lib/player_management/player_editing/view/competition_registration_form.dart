import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/competition_registration_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/competition_registration_state.dart';
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
      buildWhen: (previous, current) =>
          previous.registrations != current.registrations,
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
      onPressed: cubit.registrationAdded,
      child: const Text('Neue Meldung'),
    );
  }
}

class _CompetitionForm extends StatelessWidget {
  const _CompetitionForm({required this.registrationIndex});

  final int registrationIndex;

  @override
  Widget build(BuildContext context) {
    var editingCubit = context.read<PlayerEditingCubit>();

    return BlocProvider(
      create: (context) => CompetitionRegistrationCubit(
        editingCubit.state.registrations[registrationIndex],
        registrationIndex: registrationIndex,
        playerListCollections: editingCubit.collections,
      ),
      child: _CompetitionFormFields(
        registrationIndex: registrationIndex,
      ),
    );
  }
}

class _CompetitionFormFields extends StatelessWidget {
  const _CompetitionFormFields({
    required this.registrationIndex,
  });

  final int registrationIndex;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var registrationCubit = context.read<CompetitionRegistrationCubit>();
    return BlocBuilder<PlayerEditingCubit, PlayerEditingState>(
      builder: (context, state) {
        var registration = state.registrations[registrationIndex];
        return Stepper(
          currentStep: registration.formStep,
          onStepContinue: () =>
              registrationCubit.formStepForward(registrationIndex),
          stepIconBuilder: (stepIndex, stepState) {
            if (stepIndex < registration.formStep) {
              return const Icon(
                size: 16,
                Icons.check,
              );
            } else {
              return const Icon(
                size: 16,
                Icons.more_horiz,
              );
            }
          },
          steps: [
            if (registrationCubit.getAvailablePlayingLevels().isNotEmpty)
              Step(
                title: Text(l10n.playingLevel),
                subtitle: Text(
                  registration.playingLevel.value?.name ?? 'Bitte wählen',
                ),
                content:
                    _PlayingLevelInput(registrationIndex: registrationIndex),
              ),
            if (registrationCubit.getAvailableAgeGroups().isNotEmpty)
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
            Step(
              title: Text('Spielpartner'),
              subtitle: Text('Optional'),
              content: _AgeGroupInput(registrationIndex: registrationIndex),
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
    var registrationCubit = context.read<CompetitionRegistrationCubit>();
    return Expanded(
      child: BlocBuilder<CompetitionRegistrationCubit,
          CompetitionRegistrationState>(
        buildWhen: (previous, current) =>
            previous.competitionType != current.competitionType,
        builder: (context, state) {
          return CompetitionTypeInput(
            onChanged: (competitionType) => registrationCubit
                .competitionTypeChanged(registrationIndex, competitionType),
            currentValue: state.competitionType.value,
            competitionTypeOptions:
                registrationCubit.getAvailableCompetitionTypes(),
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
    var registrationCubit = context.read<CompetitionRegistrationCubit>();
    return Expanded(
      child: BlocBuilder<CompetitionRegistrationCubit,
          CompetitionRegistrationState>(
        buildWhen: (previous, current) =>
            previous.genderCategory != current.genderCategory,
        builder: (context, state) {
          return GenderCategoryInput(
            onChanged: (genderCategory) => registrationCubit
                .genderCategoryChanged(registrationIndex, genderCategory),
            currentValue: state.genderCategory.value,
            genderCategoryOptions:
                registrationCubit.getAvailableGenderCategories(),
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
    var registrationCubit = context.read<CompetitionRegistrationCubit>();
    return BlocBuilder<CompetitionRegistrationCubit,
        CompetitionRegistrationState>(
      buildWhen: (previous, current) => previous.ageGroup != current.ageGroup,
      builder: (context, state) {
        return AgeGroupInput(
          onChanged: (ageGroup) =>
              registrationCubit.ageGroupChanged(registrationIndex, ageGroup),
          currentValue: state.ageGroup.value,
          ageGroupOptions: registrationCubit.getAvailableAgeGroups(),
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
    var registrationCubit = context.read<CompetitionRegistrationCubit>();
    return BlocBuilder<CompetitionRegistrationCubit,
        CompetitionRegistrationState>(
      buildWhen: (previous, current) =>
          previous.playingLevel != current.playingLevel,
      builder: (context, state) {
        return PlayingLevelInput(
          onChanged: (playingLevel) =>
              registrationCubit.competitionPlayingLevelChanged(
            registrationIndex,
            playingLevel,
          ),
          currentValue: state.playingLevel.value,
          playingLevelOptions: registrationCubit.getAvailablePlayingLevels(),
        );
      },
    );
  }
}
