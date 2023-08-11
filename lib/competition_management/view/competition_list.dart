import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_sorter/comparators/competition_comparator.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_sorter/cubit/competition_sorting_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_list_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/cubit/competition_selection_cubit.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_cubit.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:ez_badminton_admin_app/widgets/sortable_column_header/sortable_column_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/widgets/custom_expansion_panel_list/expansion_panel_list.dart'
    as custom_expansion_panel;
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class CompetitionList extends StatelessWidget {
  const CompetitionList({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CompetitionSortingCubit(
            ageGroupComparator: const CompetitionComparator<AgeGroup>(
              criteria: [
                AgeGroup,
                PlayingLevel,
                CompetitionDiscipline,
              ],
            ),
            playingLevelComparator: const CompetitionComparator<PlayingLevel>(
              criteria: [
                PlayingLevel,
                AgeGroup,
                CompetitionDiscipline,
              ],
            ),
            categoryComparator:
                const CompetitionComparator<CompetitionDiscipline>(
              criteria: [
                CompetitionDiscipline,
                AgeGroup,
                PlayingLevel,
              ],
            ),
            registrationComparator: const CompetitionComparator<Team>(
              criteria: [
                Team,
                AgeGroup,
                PlayingLevel,
                CompetitionDiscipline,
              ],
            ),
          ),
        ),
      ],
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
                  const SizedBox(width: 20),
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: state.selectionTristate,
                      onChanged: (_) => selectionCubit.allCompetitionsToggled(),
                      tristate: true,
                    ),
                  ),
                  const SizedBox(width: 30),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: useAgeGroups ? 200 : 0,
                    child:
                        _SortableColumnHeader<CompetitionComparator<AgeGroup>>(
                      width: 0,
                      title: l10n.ageGroup(1),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: usePlayingLevels ? 300 : 0,
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
                    width: 150,
                    title: l10n.registrations,
                  ),
                  Expanded(
                    flex: 7,
                    child: Container(),
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
                child: custom_expansion_panel.ExpansionPanelList.radio(
                  hasExpandIcon: false,
                  elevation: 0,
                  children: [
                    for (Competition competition
                        in state.displayCompetitionList)
                      _CompetitionExpansionPanel(
                        context: context,
                        competition: competition,
                        useAgeGroups: useAgeGroups,
                        usePlayingLevels: usePlayingLevels,
                      ),
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

class _CompetitionExpansionPanel extends ExpansionPanelRadio {
  _CompetitionExpansionPanel({
    required BuildContext context,
    required Competition competition,
    required bool useAgeGroups,
    required bool usePlayingLevels,
  }) : super(
          value: competition.id,
          headerBuilder: (context, _) => _headerBuilder(
            context,
            competition,
            useAgeGroups,
            usePlayingLevels,
          ),
          body: const Placeholder(),
          canTapOnHeader: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        );

  static Widget _headerBuilder(
    BuildContext context,
    Competition competition,
    bool useAgeGroups,
    bool usePlayingLevels,
  ) {
    var l10n = AppLocalizations.of(context)!;
    var selectionCubit = context.read<CompetitionSelectionCubit>();
    return BlocBuilder<CompetitionSelectionCubit, CompetitionSelectionState>(
      buildWhen: (previous, current) =>
          previous.selectedCompetitions != current.selectedCompetitions,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Checkbox(
                value: state.selectedCompetitions.contains(competition),
                onChanged: (_) =>
                    selectionCubit.competitionToggled(competition),
              ),
              const SizedBox(width: 30),
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
                width: usePlayingLevels ? 300 : 0,
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
                width: 150,
                child: _RegistrationCount(competition: competition),
              ),
              Expanded(
                flex: 7,
                child: Container(),
              ),
            ],
          ),
        );
      },
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
      message: l10n.showRegistrations,
      child: TextButton(
        onPressed: registrationCount == 0
            ? null
            : () => navigationCubit.tabChanged(0, reason: competition),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text('$registrationCount'),
        ),
      ),
    );
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
