import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_sorter/comparators/competition_comparator.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_sorter/cubit/competition_sorting_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_list_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_selection_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_starting_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/view/tournament_mode_assignment_page.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_cubit.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:ez_badminton_admin_app/widgets/sortable_column_header/sortable_column_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class CompetitionList extends StatelessWidget {
  const CompetitionList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CompetitionSortingCubit(
        ageGroupComparator: const CompetitionComparator<AgeGroup>(
          criteria: [
            AgeGroup,
            PlayingLevel,
            CompetitionDiscipline,
            TournamentModeSettings,
          ],
        ),
        playingLevelComparator: const CompetitionComparator<PlayingLevel>(
          criteria: [
            PlayingLevel,
            AgeGroup,
            CompetitionDiscipline,
            TournamentModeSettings,
          ],
        ),
        categoryComparator: const CompetitionComparator<CompetitionDiscipline>(
          criteria: [
            CompetitionDiscipline,
            AgeGroup,
            PlayingLevel,
            TournamentModeSettings,
          ],
        ),
        registrationComparator: const CompetitionComparator<Team>(
          criteria: [
            Team,
            AgeGroup,
            PlayingLevel,
            CompetitionDiscipline,
            TournamentModeSettings,
          ],
        ),
        modeComparator: const CompetitionComparator<TournamentModeSettings>(
          criteria: [
            TournamentModeSettings,
            AgeGroup,
            PlayingLevel,
            CompetitionDiscipline,
          ],
        ),
      ),
      child: const _CompetitionList(),
    );
  }
}

class _CompetitionList extends StatelessWidget {
  const _CompetitionList();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CompetitionListCubit, CompetitionListState>(
      listenWhen: (previous, current) =>
          previous.displayCompetitionList != current.displayCompetitionList,
      listener: (context, state) {
        var selectionCubit = context.read<CompetitionSelectionCubit>();
        selectionCubit.displayCompetitionsChanged(state.displayCompetitionList);
      },
      builder: (context, state) {
        bool useAgeGroups =
            state.getCollection<Tournament>().first.useAgeGroups;
        bool usePlayingLevels =
            state.getCollection<Tournament>().first.usePlayingLevels;

        return Column(
          children: [
            _CompetitionListHeader(
              useAgeGroups: useAgeGroups,
              usePlayingLevels: usePlayingLevels,
            ),
            Expanded(
              child: _CompetitionListBody(
                useAgeGroups: useAgeGroups,
                usePlayingLevels: usePlayingLevels,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CompetitionListHeader extends StatelessWidget {
  const _CompetitionListHeader({
    required this.useAgeGroups,
    required this.usePlayingLevels,
  });

  final bool useAgeGroups;
  final bool usePlayingLevels;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<CompetitionSelectionCubit, CompetitionSelectionState>(
      buildWhen: (previous, current) =>
          previous.selectionTristate != current.selectionTristate,
      builder: (context, state) {
        var selectionCubit = context.read<CompetitionSelectionCubit>();
        return DefaultTextStyle(
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.bold),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: const Border(
                bottom: BorderSide(
                  color: Colors.black26,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const SizedBox(width: 15),
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: state.selectionTristate,
                      onChanged: (_) => selectionCubit.allCompetitionsToggled(),
                      tristate: true,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: useAgeGroups ? 200 : 0,
                          child: _SortableColumnHeader<
                              CompetitionComparator<AgeGroup>>(
                            width: 0,
                            title: l10n.ageGroup(1),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: usePlayingLevels ? 200 : 0,
                          child: _SortableColumnHeader<
                              CompetitionComparator<PlayingLevel>>(
                            width: 0,
                            title: l10n.playingLevel(1),
                          ),
                        ),
                        _SortableColumnHeader<
                            CompetitionComparator<CompetitionDiscipline>>(
                          width: 150,
                          title: l10n.competition(1),
                        ),
                        Flexible(
                          flex: 1,
                          child: Container(),
                        ),
                        _SortableColumnHeader<CompetitionComparator<Team>>(
                          width: 110,
                          title: l10n.registrations,
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(),
                        ),
                        _SortableColumnHeader<
                            CompetitionComparator<TournamentModeSettings>>(
                          width: 150,
                          title: l10n.tournamentMode,
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(),
                        ),
                        const SizedBox(width: 34),
                        const SizedBox(width: 15),
                      ],
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

class _CompetitionListBody extends StatelessWidget {
  const _CompetitionListBody({
    required this.useAgeGroups,
    required this.usePlayingLevels,
  });

  final bool useAgeGroups;
  final bool usePlayingLevels;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompetitionListCubit, CompetitionListState>(
      builder: (context, state) {
        return Column(
          children: [
            const _MissingCategoriesHint(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (Competition competition
                        in state.displayCompetitionList) ...[
                      _CompetitionListItem(
                        competition: competition,
                        useAgeGroups: useAgeGroups,
                        usePlayingLevels: usePlayingLevels,
                      ),
                      if (state.displayCompetitionList.last != competition)
                        const Divider(
                          height: 1,
                          thickness: 0.0,
                        ),
                    ],
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

class _CompetitionListItem extends StatelessWidget {
  const _CompetitionListItem({
    required this.competition,
    required this.useAgeGroups,
    required this.usePlayingLevels,
  });

  final Competition competition;
  final bool useAgeGroups;
  final bool usePlayingLevels;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var selectionCubit = context.read<CompetitionSelectionCubit>();

    return BlocBuilder<CompetitionSelectionCubit, CompetitionSelectionState>(
      buildWhen: (previous, current) =>
          previous.selectedCompetitions != current.selectedCompetitions,
      builder: (context, state) {
        return CheckboxListTile(
          contentPadding: const EdgeInsetsDirectional.only(start: 16),
          controlAffinity: ListTileControlAffinity.leading,
          value: state.selectedCompetitions.contains(competition),
          onChanged: (_) => selectionCubit.competitionToggled(competition),
          title: DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 14),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: useAgeGroups ? 200 : 0,
                  child: Text(
                    competition.ageGroup != null
                        ? display_strings.ageGroup(l10n, competition.ageGroup!)
                        : '',
                    overflow: TextOverflow.clip,
                    softWrap: false,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: usePlayingLevels ? 200 : 0,
                  child: Text(
                    competition.playingLevel?.name ?? '',
                    overflow: TextOverflow.clip,
                    softWrap: false,
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: Text(
                    display_strings.competitionCategory(
                      l10n,
                      CompetitionDiscipline.fromCompetition(competition),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Container(),
                ),
                SizedBox(
                  width: 110,
                  child: _RegistrationCount(competition: competition),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                SizedBox(
                  width: 150,
                  child: _TournamentModeLabel(competition: competition),
                ),
                Expanded(
                  flex: 4,
                  child: Container(),
                ),
                SizedBox(
                  width: 34,
                  child: _CompetitionStartButton(competition: competition),
                ),
                const SizedBox(width: 15),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CompetitionStartButton extends StatelessWidget {
  const _CompetitionStartButton({
    required this.competition,
  });

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var startingCubit = context.read<CompetitionStartingCubit>();

    bool hasDraw = competition.draw.isNotEmpty;
    bool alreadyStarted = competition.matches.isNotEmpty;

    return Tooltip(
      message: competition.matches.isEmpty
          ? l10n.startTournament
          : l10n.tournamentIsStarted,
      child: ElevatedButton(
        onPressed: hasDraw && !alreadyStarted
            ? () => startingCubit.startCompetitions([competition])
            : null,
        style: ButtonStyle(
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          padding: const MaterialStatePropertyAll(EdgeInsets.zero),
        ),
        child: Icon(
          alreadyStarted ? Icons.check : Icons.play_arrow,
          size: 30,
        ),
      ),
    );
  }
}

class _RegistrationCount extends StatelessWidget {
  const _RegistrationCount({
    required this.competition,
  });

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    int registrationCount = competition.registrations.length;
    var l10n = AppLocalizations.of(context)!;
    var navigationCubit = context.read<TabNavigationCubit>();
    return Tooltip(
      message: registrationCount == 0 ? '' : l10n.showRegistrations,
      child: TextButton(
        onPressed: registrationCount == 0
            ? null
            : () => navigationCubit.tabChanged(
                  0,
                  reason: competition,
                  fromIndex: 1,
                ),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text('$registrationCount'),
        ),
      ),
    );
  }
}

class _TournamentModeLabel extends StatelessWidget {
  const _TournamentModeLabel({
    required this.competition,
  });

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    bool hasModeAssigned = competition.tournamentModeSettings != null;
    String label;

    if (hasModeAssigned) {
      label = display_strings.tournamentMode(
        l10n,
        competition.tournamentModeSettings!,
      );
    } else {
      label = l10n.assign;
    }

    return Tooltip(
      message: _getModeTooltip(l10n),
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(
            TournamentModeAssignmentPage.route([competition]),
          );
        },
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            label,
            style: TextStyle(
              color: hasModeAssigned
                  ? null
                  : Theme.of(context).primaryColor.withOpacity(.4),
            ),
          ),
        ),
      ),
    );
  }

  String _getModeTooltip(AppLocalizations l10n) {
    if (competition.tournamentModeSettings == null) {
      return l10n.assignTournamentMode;
    }

    StringBuffer modeDescription = StringBuffer(
      display_strings.tournamentMode(
        l10n,
        competition.tournamentModeSettings!,
      ),
    );
    modeDescription.writeln();
    modeDescription.writeln();

    List<String> modeSettingsStrings = display_strings
        .tournamentModeSettingsList(l10n, competition.tournamentModeSettings!);

    modeDescription.writeAll(modeSettingsStrings, '\n');

    return modeDescription.toString().trimRight();
  }
}

class _MissingCategoriesHint extends StatelessWidget {
  const _MissingCategoriesHint();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<CompetitionListCubit, CompetitionListState>(
      builder: (context, state) {
        bool missingAgeGroups = _areAgeGroupsMissing(state);
        bool missingPlayingLevels = _arePlayingLevelsMissing(state);

        bool showHint = missingAgeGroups || missingPlayingLevels;

        return DefaultTextStyle(
          style:
              Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 18),
          child: Column(
            children: [
              AnimatedContainer(
                height: showHint ? 30 : 0,
                duration: const Duration(milliseconds: 200),
              ),
              AnimatedContainer(
                height: missingAgeGroups ? 50 : 0,
                duration: const Duration(milliseconds: 100),
                child: Align(
                  alignment: AlignmentDirectional.center,
                  child: Text(l10n.createCategories(l10n.ageGroup(2))),
                ),
              ),
              AnimatedContainer(
                height: missingPlayingLevels ? 40 : 0,
                duration: const Duration(milliseconds: 100),
                child: Align(
                  alignment: AlignmentDirectional.center,
                  child: Text(l10n.createCategories(l10n.playingLevel(2))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static bool _areAgeGroupsMissing(CompetitionListState state) {
    bool useAgeGroups = state.getCollection<Tournament>().first.useAgeGroups;
    List<AgeGroup> ageGroups = state.getCollection<AgeGroup>();
    return useAgeGroups && ageGroups.isEmpty;
  }

  static bool _arePlayingLevelsMissing(CompetitionListState state) {
    bool usePlayingLevels =
        state.getCollection<Tournament>().first.usePlayingLevels;
    List<PlayingLevel> playingLevels = state.getCollection<PlayingLevel>();
    return usePlayingLevels && playingLevels.isEmpty;
  }
}

class _SortableColumnHeader<
        ComparatorType extends ListSortingComparator<Competition>>
    extends SortableColumnHeader<Competition, ComparatorType,
        CompetitionSortingCubit, CompetitionListCubit, CompetitionListState> {
  const _SortableColumnHeader({
    required super.width,
    required super.title,
  });
}
