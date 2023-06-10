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
import 'package:ez_badminton_admin_app/widgets/custom_expansion_panel_list/expansion_panel_list.dart'
    as custom_expansion_panel;
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
    return BlocBuilder<PlayerListCubit, PlayerListState>(
      buildWhen: (previous, current) =>
          previous.filteredPlayers != current.filteredPlayers,
      builder: (context, listState) {
        return Expanded(
          child: SizedBox(
            width: 1150,
            child: _panelList(context, listState),
          ),
        );
      },
    );
  }

  Widget _panelList(BuildContext context, PlayerListState listState) {
    var l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: const Border(
              bottom: BorderSide(
                color: Colors.black26,
              ),
            ),
          ),
          child: DefaultTextStyle(
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.bold),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 190,
                    child: Text(l10n.name),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(),
                  ),
                  SizedBox(
                    width: 190,
                    child: Text(l10n.club),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(l10n.registrations),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(),
                  ),
                  SizedBox(
                    width: 110,
                    child: Text(l10n.playingLevel),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(),
                  ),
                  SizedBox(
                    child: SizedBox(
                      width: 40,
                      child: Text(l10n.age),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            child: custom_expansion_panel.ExpansionPanelList.radio(
              children: listState.filteredPlayers
                  .map((p) => PlayerExpansionPanel(p, listState, context))
                  .toList(),
              hasExpandIcon: false,
              elevation: 0,
            ),
          ),
        ),
      ],
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

class PlayerExpansionPanel extends ExpansionPanelRadio {
  PlayerExpansionPanel(
    this.player,
    this.listState,
    BuildContext context,
  ) : super(
            value: player.id,
            headerBuilder: (BuildContext context, bool isExpanded) =>
                _headerBuilder(player, listState, context, isExpanded),
            body: const Placeholder(),
            canTapOnHeader: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor);

  static Widget _headerBuilder(
    Player player,
    PlayerListState listState,
    BuildContext context,
    bool isExpanded,
  ) {
    var l10n = AppLocalizations.of(context)!;
    return Tooltip(
      message: 'Ausklappen',
      waitDuration: const Duration(milliseconds: 600),
      child: Row(
        children: [
          const SizedBox(width: 20),
          SizedBox(
            width: 190,
            child: Text(
              display_strings.playerName(player),
              overflow: TextOverflow.fade,
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(),
          ),
          SizedBox(
            width: 190,
            child: Text(
              player.club?.name ?? '-',
              overflow: TextOverflow.fade,
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(),
          ),
          SizedBox(
            width: 80,
            child: Text(
              _competitionAbbreviations(
                listState.competitionRegistrations[player]!
                    .map((r) => r.competition),
                l10n,
              ),
              overflow: TextOverflow.fade,
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(),
          ),
          SizedBox(
            width: 110,
            child: Text(
              player.playingLevel?.name ?? '-',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(),
          ),
          SizedBox(
            child: SizedBox(
              width: 40,
              child: Text(
                player.dateOfBirth == null ? '-' : ('${player.calculateAge()}'),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  final Player player;

  final PlayerListState listState;
}
