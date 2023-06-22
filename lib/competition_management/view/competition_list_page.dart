// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection_repository/collection_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';

import 'package:ez_badminton_admin_app/competition_management/cubit/tournament_editing_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/tournament_editing_state.dart';
import 'package:ez_badminton_admin_app/widgets/custom_input_fields/bloc_switch.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:ez_badminton_admin_app/widgets/long_tooltip/long_tooltip.dart';

class CompetitionListPage extends StatelessWidget {
  const CompetitionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TournamentEditingCubit(
        tournamentRepository: context.read<CollectionRepository<Tournament>>(),
      ),
      child: const _CompetitionListPageScaffold(),
    );
  }
}

class _CompetitionListPageScaffold extends StatelessWidget {
  const _CompetitionListPageScaffold();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.competitionManagement)),
      body: BlocBuilder<TournamentEditingCubit, TournamentEditingState>(
        buildWhen: (previous, current) =>
            previous.loadingStatus != current.loadingStatus,
        builder: (context, state) {
          return LoadingScreen(
            loadingStatus: state.loadingStatus,
            builder: (context) {
              return const _CategorizationSwitches();
            },
          );
        },
      ),
    );
  }
}

class _CategorizationSwitches extends StatelessWidget {
  const _CategorizationSwitches();

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<TournamentEditingCubit>();
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<TournamentEditingCubit, TournamentEditingState>(
      buildWhen: (previous, current) =>
          previous.formStatus != current.formStatus,
      builder: (context, state) {
        return Row(
          children: [
            _TournamentSwitchWithHelpIcon(
              valueGetter: (state) => state.tournament!.useAgeGroups,
              onChanged: cubit.useAgeGroupsChanged,
              label: l10n.activateAgeGroups,
              helpMessage: l10n.categorizationHint(l10n.ageGroup(2)),
              enabled: state.formStatus != FormzSubmissionStatus.inProgress,
            ),
            _TournamentSwitchWithHelpIcon(
              valueGetter: (state) => state.tournament!.usePlayingLevels,
              onChanged: cubit.usePlayingLevelsChanged,
              label: l10n.activatePlayingLevels,
              helpMessage: l10n.categorizationHint(l10n.playingLevel(2)),
              enabled: state.formStatus != FormzSubmissionStatus.inProgress,
            ),
          ],
        );
      },
    );
  }
}

class _TournamentSwitchWithHelpIcon extends StatelessWidget {
  const _TournamentSwitchWithHelpIcon({
    this.enabled = true,
    required this.valueGetter,
    required this.onChanged,
    required this.label,
    required this.helpMessage,
  });

  final bool enabled;
  final bool Function(TournamentEditingState) valueGetter;
  final void Function(bool) onChanged;
  final String label;
  final String helpMessage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TournamentSwitch(
          label: label,
          valueGetter: valueGetter,
          onChanged: enabled ? onChanged : null,
        ),
        const SizedBox(width: 8),
        LongTooltip(
          message: helpMessage,
          child: Icon(
            Icons.help_outline,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.5),
            size: 21,
          ),
        ),
      ],
    );
  }
}

class _TournamentSwitch
    extends BlocSwitch<TournamentEditingCubit, TournamentEditingState> {
  const _TournamentSwitch({
    required super.label,
    required super.valueGetter,
    required super.onChanged,
  });
}
