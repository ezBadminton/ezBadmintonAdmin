import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
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
            child: custom_expansion_panel.ExpansionPanelList.radio(
              hasExpandIcon: false,
              elevation: 0,
              children: listState.filteredPlayers
                  .map((p) => PlayerExpansionPanel(p, listState, context))
                  .toList(),
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
          body: _PlayerExpansionPanelBody(
            player: player,
            registrations: listState.competitionRegistrations[player]!,
          ),
          canTapOnHeader: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        );

  final Player player;
  final PlayerListState listState;

  static Widget _headerBuilder(
    Player player,
    PlayerListState listState,
    BuildContext context,
    bool isExpanded,
  ) {
    var l10n = AppLocalizations.of(context)!;
    return Tooltip(
      message: isExpanded ? '' : l10n.expand,
      waitDuration: const Duration(milliseconds: 600),
      child: Row(
        children: [
          const SizedBox(width: 20),
          SizedBox(
            width: 190,
            child: Text(
              display_strings.playerName(player),
              overflow: TextOverflow.fade,
              style: TextStyle(
                fontWeight: isExpanded ? FontWeight.w600 : FontWeight.normal,
              ),
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
}

class _PlayerExpansionPanelBody extends StatelessWidget {
  const _PlayerExpansionPanelBody({
    required this.player,
    required this.registrations,
  });

  final Player player;
  final List<CompetitionRegistration> registrations;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.05),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PlayerNotes(player: player),
                      const SizedBox(width: 50),
                      _PlayerStatus(player: player),
                      const SizedBox(width: 50),
                      _PlayerRegistrations(registrations: registrations),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _PlayerEditButton(player: player),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayerEditButton extends StatelessWidget {
  const _PlayerEditButton({
    required this.player,
  });

  final Player player;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(PlayerEditingPage.route(player));
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Theme.of(context).primaryColorLight.withOpacity(.14),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(60, 10, 60, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit, size: 22),
            const SizedBox(width: 10),
            Text(l10n.editPlayer),
          ],
        ),
      ),
    );
  }
}

class _PlayerRegistrations extends StatelessWidget {
  const _PlayerRegistrations({
    required this.registrations,
  });

  final List<CompetitionRegistration> registrations;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: _PlayerDetailsSection(
        title: l10n.registrations,
        child: registrations.isEmpty
            ? Text(
                '- ${l10n.none} -',
                style: TextStyle(color: Theme.of(context).disabledColor),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final r in registrations)
                    Text(
                      display_strings.competitionCategory(
                        l10n,
                        r.competition.type,
                        r.competition.genderCategory,
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _PlayerStatus extends StatelessWidget {
  const _PlayerStatus({
    required this.player,
  });

  final Player player;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: _PlayerDetailsSection(
        title: l10n.status,
        child: Text(player.status.name),
      ),
    );
  }
}

class _PlayerNotes extends StatelessWidget {
  const _PlayerNotes({
    required this.player,
  });

  final Player player;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: _PlayerDetailsSection(
        title: l10n.notes,
        child: player.notes == null
            ? Text(
                '- ${l10n.none} -',
                style: TextStyle(
                  color: Theme.of(context).disabledColor,
                ),
              )
            : SelectableText(
                player.notes!,
              ),
      ),
    );
  }
}

class _PlayerDetailsSection extends StatelessWidget {
  const _PlayerDetailsSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Theme.of(context).disabledColor),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 7.0),
          child: Divider(height: 1),
        ),
        child,
      ],
    );
  }
}
