import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/player_editing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompetitionRegistrationForm extends StatelessWidget {
  const CompetitionRegistrationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CompetitionForm(registrationIndex: 0);
  }
}

class _CompetitionForm extends StatelessWidget {
  const _CompetitionForm({required this.registrationIndex});

  final int registrationIndex;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<PlayerEditingCubit>();
    return Row(
      children: [
        const Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: _CompetitionGenderInput(),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: _CompetitionTypeInput(
            onChanged: cubit.competitionTypeChanged,
          ),
        ),
        const SizedBox(width: 10),
        const Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: SizedBox(),
        ),
      ],
    );
  }
}

class _CompetitionTypeInput extends StatelessWidget {
  const _CompetitionTypeInput({
    required this.onChanged,
  });

  final void Function(CompetitionType? value) onChanged;

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return BlocBuilder<PlayerEditingCubit, PlayerEditingState>(
      buildWhen: (previous, current) =>
          previous.competitionType != current.competitionType,
      builder: (context, state) {
        return DropdownButtonFormField<CompetitionType>(
          hint: const Text('Disziplin wählen'),
          value: state.competitionType.value,
          onChanged: onChanged,
          items: [
            for (var competitionType in CompetitionType.values.sublist(0, 3))
              DropdownMenuItem(
                value: competitionType,
                child: Text(l10n.competitionType(competitionType.name)),
              )
          ],
          decoration: InputDecoration(
            label: Text(l10n.competition),
            counterText: ' ',
          ),
        );
      },
    );
  }
}

class _CompetitionGenderInput extends StatelessWidget {
  const _CompetitionGenderInput();

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return BlocBuilder<PlayerEditingCubit, PlayerEditingState>(
      buildWhen: (previous, current) =>
          previous.genderCategory != current.genderCategory ||
          previous.competitionType != current.competitionType,
      builder: (context, state) {
        if ([CompetitionType.doubles, CompetitionType.singles]
            .contains(state.competitionType.value)) {
          return DropdownButtonFormField<GenderCategory>(
            value: state.genderCategory.value,
            onChanged: (value) {},
            items: [
              for (var genderCategory in GenderCategory.values.sublist(0, 2))
                DropdownMenuItem(
                  value: genderCategory,
                  child: Text(l10n.genderCategory(genderCategory.name)),
                )
            ],
            decoration: const InputDecoration(
              label: Text(' '),
              counterText: ' ',
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
