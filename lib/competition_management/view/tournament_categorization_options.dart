import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/age_group_editing/view/age_group_editing_popup.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_categorization_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_categorization_state.dart';
import 'package:ez_badminton_admin_app/competition_management/playing_level_editing/view/playing_level_editing_popup.dart';
import 'package:ez_badminton_admin_app/widgets/dialogs/confirm_dialog.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/dialog_listener.dart';
import 'package:ez_badminton_admin_app/widgets/custom_input_fields/bloc_switch.dart';
import 'package:ez_badminton_admin_app/widgets/help_tooltip_icon/help_tooltip_icon.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:ez_badminton_admin_app/widgets/long_tooltip/long_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';

class TournamentCategorizationOptions extends StatelessWidget {
  const TournamentCategorizationOptions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<CompetitionCategorizationCubit,
        CompetitionCategorizationState>(
      buildWhen: (previous, current) =>
          previous.loadingStatus != current.loadingStatus,
      builder: (context, state) {
        return LoadingScreen(
          loadingStatus: state.loadingStatus,
          builder: (context) {
            return DialogListener<CompetitionCategorizationCubit,
                CompetitionCategorizationState, bool>(
              builder: (context, _, mergeType) {
                String categorization =
                    _getCategorizationName(mergeType as Type, l10n);
                return ConfirmDialog(
                  title: Text(l10n.disableCategorization(categorization)),
                  content: SizedBox(
                    width: 500,
                    child: Text(l10n.mergeRegistrationsWarning(categorization)),
                  ),
                  confirmButtonLabel: l10n.confirm,
                  cancelButtonLabel: l10n.cancel,
                );
              },
              child: DialogListener<CompetitionCategorizationCubit,
                  CompetitionCategorizationState, Exception>(
                builder: (context, _, type) {
                  String categorization = _getCategorizationName(
                    type as Type,
                    l10n,
                  );
                  String category = _getCategorizationName(
                    type,
                    l10n,
                    plural: false,
                  );
                  return AlertDialog(
                    title: Text(l10n.noneOf(categorization)),
                    content: SizedBox(
                      width: 500,
                      child: Text(
                          l10n.noCategoryWarning(categorization, category)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, null);
                          showDialog(
                            context: context,
                            useRootNavigator: false,
                            builder: (context) => _getEditingPopup(type),
                          );
                        },
                        child: Text(l10n.editSubject(categorization)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, null),
                        child: Text(l10n.close),
                      ),
                    ],
                  );
                },
                child: const _CategorizationSwitches(),
              ),
            );
          },
        );
      },
    );
  }

  String _getCategorizationName(
    Type categorization,
    AppLocalizations l10n, {
    bool plural = true,
  }) {
    assert(categorization == AgeGroup || categorization == PlayingLevel);

    int num = plural ? 2 : 1;

    String categorizationName = switch (categorization) {
      AgeGroup => l10n.ageGroup(num),
      PlayingLevel => l10n.playingLevel(num),
      _ => throw Exception("Unknown Categorization")
    };

    return categorizationName;
  }

  Widget _getEditingPopup(Type categorization) {
    assert(categorization == AgeGroup || categorization == PlayingLevel);

    return switch (categorization) {
      AgeGroup => const AgeGroupEditingPopup(),
      PlayingLevel => const PlayingLevelEditingPopup(),
      _ => throw Exception("Unknown Categorization")
    };
  }
}

class _CategorizationSwitches extends StatelessWidget {
  const _CategorizationSwitches();

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CompetitionCategorizationCubit>();
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<CompetitionCategorizationCubit,
        CompetitionCategorizationState>(
      builder: (context, state) {
        bool areNoCompetitionsRunning =
            state.getCollection<Competition>().firstWhereOrNull(
                      (competition) => competition.matches.isNotEmpty,
                    ) ==
                null;

        bool switchesEnabled = areNoCompetitionsRunning &&
            state.formStatus != FormzSubmissionStatus.inProgress;

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _CategoryPanel(
                valueGetter: (state) => state.tournament.useAgeGroups,
                onChanged: cubit.useAgeGroupsChanged,
                label: l10n.activateAgeGroups,
                helpMessage: l10n.categorizationHint(l10n.ageGroup(2)),
                editButtonLabel: l10n.editSubject(l10n.ageGroup(2)),
                editWidget: const AgeGroupEditingPopup(),
                enabled: switchesEnabled,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CategoryPanel(
                valueGetter: (state) => state.tournament.usePlayingLevels,
                onChanged: cubit.usePlayingLevelsChanged,
                label: l10n.activatePlayingLevels,
                helpMessage: l10n.categorizationHint(l10n.playingLevel(2)),
                editButtonLabel: l10n.editSubject(l10n.playingLevel(2)),
                editWidget: const PlayingLevelEditingPopup(),
                enabled: switchesEnabled,
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
  final bool Function(CompetitionCategorizationState) valueGetter;
  final void Function(bool) onChanged;
  // Label next to the switch wigdet
  final String label;
  // Message being shown as a tooltip on a help icon
  final String helpMessage;
  final String editButtonLabel;
  final Widget editWidget;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompetitionCategorizationCubit,
        CompetitionCategorizationState>(
      buildWhen: (previous, current) =>
          valueGetter(previous) != valueGetter(current),
      builder: (context, state) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .background
                .withOpacity(valueGetter(state) ? .5 : .25),
            borderRadius: const BorderRadius.vertical(
              top: Radius.zero,
              bottom: Radius.circular(15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CategorySwitchWithHelpIcon(
                label: label,
                valueGetter: valueGetter,
                enabled: enabled,
                onChanged: onChanged,
                helpMessage: helpMessage,
              ),
              TextButton(
                onPressed: () => showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (context) => editWidget,
                ),
                child: Text(editButtonLabel),
              ),
            ],
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
  final bool Function(CompetitionCategorizationState p1) valueGetter;
  final bool enabled;
  final void Function(bool p1) onChanged;
  final String helpMessage;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    Widget switchWithTooltip;
    Widget categorySwitch = _CategorySwitch(
      label: label,
      valueGetter: valueGetter,
      onChanged: enabled ? onChanged : (_) {},
    );

    if (enabled) {
      switchWithTooltip = categorySwitch;
    } else {
      switchWithTooltip = LongTooltip(
        message: l10n.categorizationCantBeChanged,
        child: categorySwitch,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        switchWithTooltip,
        const SizedBox(width: 8),
        HelpTooltipIcon(helpText: helpMessage),
      ],
    );
  }
}

class _CategorySwitch extends BlocSwitch<CompetitionCategorizationCubit,
    CompetitionCategorizationState> {
  const _CategorySwitch({
    required super.label,
    required super.valueGetter,
    required super.onChanged,
  });
}
