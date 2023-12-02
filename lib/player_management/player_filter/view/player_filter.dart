import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_cubit.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_state.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
import 'package:ez_badminton_admin_app/predicate_filter/common_predicate_producers/agegroup_predicate_producer.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';
import 'package:ez_badminton_admin_app/widgets/filter_forms/filter_forms.dart';
import 'package:ez_badminton_admin_app/widgets/filter_menu/filter_chips.dart';
import 'package:ez_badminton_admin_app/widgets/filter_menu/filter_menu.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerFilter extends StatelessWidget {
  const PlayerFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 1150,
      child: Column(
        children: [
          PlayerFilterMenus(),
          SizedBox(height: 3),
          FilterChips<PlayerFilterCubit>(),
        ],
      ),
    );
  }
}

class PlayerFilterMenus extends StatelessWidget {
  const PlayerFilterMenus({
    super.key,
    this.useAgeGroupFilter = true,
    this.usePlayingLevelFilter = true,
    this.useGenderCategoryFilter = true,
    this.useCompetitionTypeFilter = true,
    this.useStatusFilter = true,
    this.useNameFilter = true,
  });

  final bool useAgeGroupFilter;
  final bool usePlayingLevelFilter;
  final bool useGenderCategoryFilter;
  final bool useCompetitionTypeFilter;
  final bool useStatusFilter;
  final bool useNameFilter;

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return BlocListener<TabNavigationCubit, TabNavigationState>(
      listenWhen: (_, current) =>
          current.selectedIndex == 0 && current.tabChangeReason is Competition,
      listener: (context, state) {
        Competition competition = state.tabChangeReason as Competition;
        _filterForCompetition(competition, context);
      },
      child: BlocConsumer<PlayerFilterCubit, PlayerFilterState>(
        listenWhen: (previous, current) {
          return current.filterPredicate != null;
        },
        listener: (context, state) {
          var listFilter = context.read<PredicateFilterCubit>();
          listFilter.consumePredicate(state.filterPredicate!);
        },
        buildWhen: (previous, current) =>
            previous.collections != current.collections,
        builder: (context, state) {
          Tournament tournament = state.getCollection<Tournament>().first;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (tournament.useAgeGroups && useAgeGroupFilter) ...[
                FilterPopoverMenu(
                  filterMenu:
                      AgeGroupFilterForm<PlayerFilterCubit, PlayerFilterState>(
                    backgroundContext: context,
                    ageGroups: state.getCollection<AgeGroup>(),
                  ),
                  buttonText: l10n.ageGroup(1),
                ),
                const SizedBox(width: 10),
              ],
              if (tournament.usePlayingLevels && usePlayingLevelFilter) ...[
                FilterPopoverMenu(
                  filterMenu: PlayingLevelFilterForm<PlayerFilterCubit,
                      PlayerFilterState>(
                    playingLevels: state.getCollection<PlayingLevel>(),
                    backgroudContext: context,
                  ),
                  buttonText: l10n.playingLevel(1),
                ),
                const SizedBox(width: 10),
              ],
              if (useGenderCategoryFilter) ...[
                FilterPopoverMenu(
                  filterMenu: GenderCategoryFilterForm<PlayerFilterCubit,
                      PlayerFilterState>(
                    backgroundContext: context,
                  ),
                  buttonText: l10n.category,
                ),
                const SizedBox(width: 10),
              ],
              if (useCompetitionTypeFilter) ...[
                FilterPopoverMenu(
                  filterMenu: CompetitionTypeFilterForm<PlayerFilterCubit,
                      PlayerFilterState>(
                    backgroudContext: context,
                  ),
                  buttonText: l10n.competition(1),
                ),
                const SizedBox(width: 10),
              ],
              if (useStatusFilter) ...[
                FilterPopoverMenu(
                  filterMenu: _StatusFilterForm(backgroudContext: context),
                  buttonText: l10n.status,
                ),
                const SizedBox(width: 30),
              ],
              if (useNameFilter) Expanded(child: _SearchField()),
            ],
          );
        },
      ),
    );
  }

  // Sets all filters so that only the [competition]
  static void _filterForCompetition(
    Competition competition,
    BuildContext context,
  ) {
    var filterCubit = context.read<PlayerFilterCubit>();
    var predicateCubit = context.read<PredicateFilterCubit>();

    List<FilterPredicate> predicates =
        predicateCubit.state.filterPredicates.values.expand((p) => p).toList();
    for (FilterPredicate predicate in predicates) {
      filterCubit.onPredicateRemoved(predicate);
    }

    var ageGroupPredicateProducer =
        filterCubit.getPredicateProducer<AgeGroupPredicateProducer>();
    var playingLevelPredicateProducer =
        filterCubit.getPredicateProducer<PlayingLevelPredicateProducer>();
    var genderCategoryPredicateProducer =
        filterCubit.getPredicateProducer<GenderCategoryPredicateProducer>();
    var competitionTypePredicateProducer =
        filterCubit.getPredicateProducer<CompetitionTypePredicateProducer>();

    if (competition.ageGroup != null) {
      ageGroupPredicateProducer.ageGroupToggled(
        competition.ageGroup!,
      );
    }
    if (competition.playingLevel != null) {
      playingLevelPredicateProducer.playingLevelToggled(
        competition.playingLevel!,
      );
    }
    genderCategoryPredicateProducer.categoryToggled(
      competition.genderCategory,
    );
    competitionTypePredicateProducer.competitionTypeToggled(
      competition.type,
    );
  }
}

class _SearchField extends StatelessWidget {
  _SearchField();

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SearchPredicateProducer predicateProducer = context
        .read<PlayerFilterCubit>()
        .getPredicateProducer<SearchPredicateProducer>();
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<PlayerFilterCubit, PlayerFilterState>(
      buildWhen: (_, current) =>
          predicateProducer.producesDomain(current.filterPredicate?.domain),
      builder: (_, __) {
        if (predicateProducer.searchTerm.isEmpty) {
          _controller.text = '';
        }
        return TextField(
          controller: _controller,
          onChanged: (searchTerm) =>
              predicateProducer.searchTermChanged(searchTerm),
          decoration: InputDecoration(
            hintText: l10n.playerSearchHint,
            prefixIcon: AnimatedRotation(
              duration: const Duration(milliseconds: 120),
              turns: predicateProducer.searchTerm.isEmpty ? 0 : -0.25,
              child: const _SearchClearButton(),
            ),
          ),
        );
      },
    );
  }
}

class _SearchClearButton extends StatelessWidget {
  const _SearchClearButton();

  @override
  Widget build(BuildContext context) {
    SearchPredicateProducer predicateProducer = context
        .read<PlayerFilterCubit>()
        .getPredicateProducer<SearchPredicateProducer>();
    return BlocBuilder<PlayerFilterCubit, PlayerFilterState>(
      buildWhen: (_, current) =>
          current.filterPredicate?.domain == FilterGroup.playerSearch,
      builder: (_, state) {
        bool searchTermPresent = predicateProducer.searchTerm.isNotEmpty;

        if (searchTermPresent) {
          return IconButton(
            onPressed: () => predicateProducer.searchTermChanged(''),
            icon: const Icon(Icons.close),
            tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
          );
        } else {
          return const Icon(Icons.search);
        }
      },
    );
  }
}

class _StatusFilterForm extends StatelessWidget {
  const _StatusFilterForm({
    required this.backgroudContext,
  });

  final BuildContext backgroudContext;

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    PlayerFilterCubit cubit = backgroudContext.read<PlayerFilterCubit>();
    StatusPredicateProducer predicateProducer =
        cubit.getPredicateProducer<StatusPredicateProducer>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: PlayerStatus.values
          .map(
            (playerStatus) => FilterCheckbox<PlayerFilterCubit,
                PlayerFilterState, PlayerStatus>(
              backgroundContext: backgroudContext,
              checkboxValue: playerStatus,
              predicateProducer: predicateProducer,
              toggledValuesGetter: () => predicateProducer.statusList,
              onToggle: predicateProducer.statusToggled,
              label: l10n.playerStatus(playerStatus.name),
            ),
          )
          .toList(),
    );
  }
}
