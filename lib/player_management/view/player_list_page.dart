import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_list_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/view/player_editing_page.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/view/player_filter.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class PlayerListPage extends StatelessWidget {
  const PlayerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PredicateFilterCubit()),
        BlocProvider(
          create: (_) => PlayerFilterCubit(
            agePredicateProducer: AgePredicateProducer(),
            genderPredicateProducer: GenderPredicateProducer(),
            playingLevelPredicateProducer: PlayingLevelPredicateProducer(),
            competitionTypePredicateProducer:
                CompetitionTypePredicateProducer(),
            searchPredicateProducer: SearchPredicateProducer(),
            playingLevelRepository:
                context.read<CollectionRepository<PlayingLevel>>(),
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.playerManagement)),
      body: const Align(
        alignment: Alignment.topCenter,
        child: _PlayerListWithFilter(),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 80, 40),
        child: FloatingActionButton.extended(
          onPressed: () {
            var listCubit = context.read<PlayerListCubit>();
            if (listCubit.state.loadingStatus == LoadingStatus.done) {
              Navigator.of(context).push(PlayerEditingPage.route());
            }
          },
          icon: const Icon(Icons.person_add_alt_1),
          label: Text(l10n.add),
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
      },
      child: BlocBuilder<PlayerListCubit, PlayerListState>(
        buildWhen: (previous, current) =>
            previous.loadingStatus != current.loadingStatus,
        builder: (context, listState) {
          return BlocBuilder<PlayerFilterCubit, PlayerFilterState>(
            buildWhen: (previous, current) =>
                previous.loadingStatus != current.loadingStatus,
            builder: (context, filterState) {
              return LoadingScreen(
                loadingStatusGetter: () => loadingStatusConjunction(
                  [listState.loadingStatus, filterState.loadingStatus],
                ),
                errorMessage: l10n.playerListLoadingError,
                retryButtonLabel: l10n.retry,
                onRetry: () {
                  if (listState.loadingStatus == LoadingStatus.failed) {
                    context.read<PlayerListCubit>().loadPlayerData();
                  }
                  if (filterState.loadingStatus == LoadingStatus.failed) {
                    context.read<PlayerFilterCubit>().loadPlayingLevels();
                  }
                },
                builder: (_) => const Column(
                  children: [
                    PlayerFilter(),
                    _PlayerList(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PlayerList extends StatelessWidget {
  const _PlayerList();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<PlayerListCubit, PlayerListState>(
      buildWhen: (previous, current) =>
          previous.filteredPlayers != current.filteredPlayers,
      builder: (context, listState) {
        return DataTable(
          columns: [
            DataColumn(label: Text(l10n.name)),
            DataColumn(label: Text(l10n.club)),
            DataColumn(label: Text(l10n.registrations)),
            DataColumn(label: Text(l10n.playingLevel)),
            DataColumn(label: Text(l10n.age)),
            DataColumn(label: Text(l10n.gender)),
            DataColumn(label: Text(l10n.eMail)),
          ],
          sortAscending: true,
          sortColumnIndex: 0,
          rows: listState.filteredPlayers.map((player) {
            return DataRow(cells: [
              DataCell(
                SizedBox(
                  width: 190,
                  child: Text(
                    display_strings.playerName(player),
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 190,
                  child: Text(
                    player.club?.name ?? '-',
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 73,
                  child: Text(
                    _competitionAbbreviations(
                      listState.competitionRegistrations[player]!
                          .map((r) => r.competition),
                      l10n,
                    ),
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 110,
                  child: Text(
                    player.playingLevel?.name ?? '-',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  child: SizedBox(
                    width: 32,
                    child: Text('${player.calculateAge()}'),
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 70,
                  child: Text(player.gender == Gender.male ? 'm' : 'w'),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 100,
                  child: Text(
                    player.eMail ?? '-',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ]);
          }).toList(),
        );
      },
    );
  }
}

String _competitionAbbreviations(
  Iterable<Competition> competitions,
  AppLocalizations l10n,
) {
  List<String> abbreviations = [];
  for (var competition in competitions) {
    String competitionAbbreviation =
        l10n.competitionTypeAbbreviated(competition.type.name);
    if (competition.genderCategory == GenderCategory.mixed ||
        competition.genderCategory == GenderCategory.any) {
      abbreviations.add(competitionAbbreviation);
    } else {
      String genderPrefix = competition.genderCategory == GenderCategory.female
          ? l10n.womenAbbreviated
          : l10n.menAbbreviated;
      abbreviations.add('$genderPrefix$competitionAbbreviation');
    }
  }
  abbreviations.sort();
  return abbreviations.join(', ');
}
