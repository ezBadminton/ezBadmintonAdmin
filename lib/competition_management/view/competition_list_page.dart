// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/age_group_editing/view/age_group_editing_popup.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_editing/view/competition_editing_page.dart';
import 'package:ez_badminton_admin_app/competition_management/playing_level_editing/view/playing_level_editing_popup.dart';
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 80, bottom: 40),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(CompetitionEditingPage.route());
          },
          icon: const Icon(Icons.add),
          label: Text(l10n.add),
          heroTag: 'competition_add_button',
        ),
      ),
      body: Align(
        alignment: AlignmentDirectional.topCenter,
        child: SizedBox(
          width: 1150,
          child: BlocBuilder<TournamentEditingCubit, TournamentEditingState>(
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
        ),
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _CategoryPanel(
                valueGetter: (state) => state.tournament!.useAgeGroups,
                onChanged: cubit.useAgeGroupsChanged,
                label: l10n.activateAgeGroups,
                helpMessage: l10n.categorizationHint(l10n.ageGroup(2)),
                editButtonLabel: l10n.editSubject(l10n.ageGroup(2)),
                editWidget: const AgeGroupEditingPopup(),
                enabled: state.formStatus != FormzSubmissionStatus.inProgress,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CategoryPanel(
                valueGetter: (state) => state.tournament!.usePlayingLevels,
                onChanged: cubit.usePlayingLevelsChanged,
                label: l10n.activatePlayingLevels,
                helpMessage: l10n.categorizationHint(l10n.playingLevel(2)),
                editButtonLabel: l10n.editSubject(l10n.playingLevel(2)),
                editWidget: const PlayingLevelEditingPopup(),
                enabled: state.formStatus != FormzSubmissionStatus.inProgress,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryPanel extends StatelessWidget {
  /// A panel with a switch to toggle playing level/age group categorization
  /// for competitions.
  ///
  /// When the switch is on, an edit button appears to add/remove categories.
  const _CategoryPanel({
    this.enabled = true,
    required this.valueGetter,
    required this.onChanged,
    required this.label,
    required this.helpMessage,
    required this.editButtonLabel,
    required this.editWidget,
  });

  final bool enabled;
  final bool Function(TournamentEditingState) valueGetter;
  final void Function(bool) onChanged;
  // Label next to the switch wigdet
  final String label;
  // Message being shown as a tooltip on a help icon
  final String helpMessage;
  final String editButtonLabel;
  final Widget editWidget;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TournamentEditingCubit, TournamentEditingState>(
      buildWhen: (previous, current) =>
          valueGetter(previous) != valueGetter(current),
      builder: (context, state) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: valueGetter(state) ? 120 : 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(15),
          ),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false,
            ),
            child: SingleChildScrollView(
              clipBehavior: Clip.hardEdge,
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  _CategorySwitchWithHelpIcon(
                    label: label,
                    valueGetter: valueGetter,
                    enabled: enabled,
                    onChanged: onChanged,
                    helpMessage: helpMessage,
                  ),
                  const SizedBox(height: 15),
                  AnimatedOpacity(
                    opacity: valueGetter(state) ? 1 : 0,
                    duration: const Duration(milliseconds: 100),
                    child: TextButton(
                      onPressed: valueGetter(state)
                          ? () => showDialog(
                                context: context,
                                useRootNavigator: false,
                                builder: (context) => editWidget,
                              )
                          : null,
                      child: Text(editButtonLabel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CategorySwitchWithHelpIcon extends StatelessWidget {
  const _CategorySwitchWithHelpIcon({
    required this.label,
    required this.valueGetter,
    required this.enabled,
    required this.onChanged,
    required this.helpMessage,
  });

  final String label;
  final bool Function(TournamentEditingState p1) valueGetter;
  final bool enabled;
  final void Function(bool p1) onChanged;
  final String helpMessage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CategorySwitch(
          label: label,
          valueGetter: valueGetter,
          onChanged: enabled ? onChanged : (_) {},
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

class _CategorySwitch
    extends BlocSwitch<TournamentEditingCubit, TournamentEditingState> {
  const _CategorySwitch({
    required super.label,
    required super.valueGetter,
    required super.onChanged,
  });
}
