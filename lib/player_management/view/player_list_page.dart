import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/team_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/cubit/unique_competition_filter_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/widgets/player_list.dart';
import 'package:ez_badminton_admin_app/predicate_filter/common_predicate_producers/agegroup_predicate_producer.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/club_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/creation_date_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/name_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/cubit/player_sorting_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_list_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/view/player_editing_page.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/view/player_filter.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:ez_badminton_admin_app/widgets/tab_navigation_back_button/tab_navigation_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlayerListPage extends StatelessWidget {
  const PlayerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PredicateFilterCubit()),
        BlocProvider(
          create: (_) => PlayerFilterCubit(
            ageGroupPredicateProducer: AgeGroupPredicateProducer(),
            genderPredicateProducer: GenderCategoryPredicateProducer(),
            playingLevelPredicateProducer: PlayingLevelPredicateProducer(),
            competitionTypePredicateProducer:
                CompetitionTypePredicateProducer(),
            statusPredicateProducer: StatusPredicateProducer(),
            searchPredicateProducer: SearchPredicateProducer(),
            playingLevelRepository:
                context.read<CollectionRepository<PlayingLevel>>(),
            ageGroupRepository: context.read<CollectionRepository<AgeGroup>>(),
            tournamentRepository:
                context.read<CollectionRepository<Tournament>>(),
          ),
        ),
        BlocProvider(
          create: (context) => PlayerSortingCubit(
            defaultComparator: const CreationDateComparator(),
            nameComparator: NameComparator(),
            clubComparator: ClubComparator(
              secondaryComparator: NameComparator()
                  .copyWith(ComparatorMode.ascending)
                  .comparator,
            ),
          ),
        ),
        BlocProvider(
          create: (context) => UniqueCompetitionFilterCubit(
            tournamentRepository:
                context.read<CollectionRepository<Tournament>>(),
            competitionRepository:
                context.read<CollectionRepository<Competition>>(),
          ),
        ),
        BlocProvider(
          create: (_) => PlayerListCubit(
            playerRepository: context.read<CollectionRepository<Player>>(),
            competitionRepository:
                context.read<CollectionRepository<Competition>>(),
            playingLevelRepository:
                context.read<CollectionRepository<PlayingLevel>>(),
            ageGroupRepository: context.read<CollectionRepository<AgeGroup>>(),
            clubRepository: context.read<CollectionRepository<Club>>(),
          ),
        )
      ],
      child: const _PlayerListPageScaffold(),
    );
  }
}

class _PlayerListPageScaffold extends StatelessWidget {
  const _PlayerListPageScaffold();

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;

    return TabNavigationBackButtonBuilder(
      builder: (context, backButton) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.playerManagement),
          leading: backButton,
        ),
        body: const Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: _PlayerListWithFilter(),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 80, bottom: 40),
          child: FloatingActionButton.extended(
            onPressed: () {
              var listCubit = context.read<PlayerListCubit>();
              if (listCubit.state.loadingStatus == LoadingStatus.done) {
                Navigator.of(context).push(PlayerEditingPage.route());
              }
            },
            icon: const Icon(Icons.person_add_alt_1),
            label: Text(l10n.add),
            heroTag: 'player_add_button',
          ),
        ),
      ),
    );
  }
}

class _PlayerListWithFilter extends StatelessWidget {
  const _PlayerListWithFilter();

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;

    return BlocListener<PredicateFilterCubit, PredicateFilterState>(
      listener: (context, state) {
        context.read<PlayerListCubit>().filterChanged(state.filters);
        context.read<UniqueCompetitionFilterCubit>().filterPredicatesChanged(
              state.filterPredicates,
              state.filters,
            );
      },
      child: BlocListener<UniqueCompetitionFilterCubit,
          UniqueCompetitionFilterState>(
        listener: _toggleTeamSorting,
        child: BlocBuilder<PlayerListCubit, PlayerListState>(
          buildWhen: (previous, current) =>
              previous.loadingStatus != current.loadingStatus,
          builder: (context, listState) {
            return BlocBuilder<PlayerFilterCubit, PlayerFilterState>(
              buildWhen: (previous, current) =>
                  previous.loadingStatus != current.loadingStatus,
              builder: (context, filterState) {
                return LoadingScreen(
                  loadingStatus: loadingStatusConjunction(
                    [listState.loadingStatus, filterState.loadingStatus],
                  ),
                  errorMessage: l10n.playerListLoadingError,
                  builder: (_) => const Column(
                    children: [
                      PlayerFilter(),
                      SizedBox(height: 20),
                      PlayerList(),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _toggleTeamSorting(
    BuildContext context,
    UniqueCompetitionFilterState state,
  ) {
    if (state.competition.value != null) {
      _enableTeamSorting(context, state.competition.value!);
    } else {
      _disableTeamSorting(context);
    }
  }

  /// Activates the [TeamComparator] for the currently filtered [Competition].
  void _enableTeamSorting(
    BuildContext context,
    Competition filteredCompetition,
  ) async {
    var sortingCubit = context.read<PlayerSortingCubit>();
    var listCubit = context.read<PlayerListCubit>();

    sortingCubit.resetComparator();
    await Future.delayed(Duration.zero);

    listCubit.comparatorChanged(TeamComparator(
      competition: filteredCompetition,
    ));
  }

  void _disableTeamSorting(BuildContext context) {
    var sortingCubit = context.read<PlayerSortingCubit>();
    var listCubit = context.read<PlayerListCubit>();
    if (listCubit.state.sortingComparator is TeamComparator) {
      sortingCubit.resetComparator();
      listCubit.comparatorChanged(sortingCubit.defaultComparator);
    }
  }
}
