import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/constants.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_delete_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_delete_state.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_status_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_status_state.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/club_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/creation_date_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/name_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/cubit/player_sorting_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_list_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/view/player_editing_page.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/view/player_filter.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/confirm_dialog.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/dialog_listener.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/view/registration_display_card.dart';
import 'package:ez_badminton_admin_app/widgets/sortable_column_header/sortable_column_header.dart';
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
            genderPredicateProducer: GenderCategoryPredicateProducer(),
            playingLevelPredicateProducer: PlayingLevelPredicateProducer(),
            competitionTypePredicateProducer:
                CompetitionTypePredicateProducer(),
            statusPredicateProducer: StatusPredicateProducer(),
            searchPredicateProducer: SearchPredicateProducer(),
            playingLevelRepository:
                context.read<CollectionRepository<PlayingLevel>>(),
            ageGroupRepository: context.read<CollectionRepository<AgeGroup>>(),
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
                loadingStatus: loadingStatusConjunction(
                  [listState.loadingStatus, filterState.loadingStatus],
                ),
                errorMessage: l10n.playerListLoadingError,
                retryButtonLabel: l10n.retry,
                onRetry: () {
                  if (listState.loadingStatus == LoadingStatus.failed) {
                    context.read<PlayerListCubit>().loadPlayerData();
                  }
                  if (filterState.loadingStatus == LoadingStatus.failed) {
                    context.read<PlayerFilterCubit>().loadCollections();
                  }
                },
                builder: (_) => const Column(
                  children: [
                    PlayerFilter(),
                    SizedBox(height: 20),
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
    int filteredLength = listState.filteredPlayers.length;
    int fullLength = listState.getCollection<Player>().length;
    return Column(
      children: [
        Text(
          '${l10n.nPlayersShown(filteredLength)} (${l10n.ofN(fullLength)})',
          style: TextStyle(
            color:
                Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(.4),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
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
                  _SortableColumnHeader<NameComparator>(
                    width: 190,
                    title: l10n.name,
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(),
                  ),
                  _SortableColumnHeader<ClubComparator>(
                    width: 190,
                    title: l10n.club,
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
                    child: Text(l10n.playingLevel(1)),
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
                  Flexible(
                    flex: 1,
                    child: Container(),
                  ),
                  SizedBox(
                    child: SizedBox(
                      width: 45,
                      child: Text(l10n.status),
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
            child: Column(
              children: [
                custom_expansion_panel.ExpansionPanelList.radio(
                  hasExpandIcon: false,
                  elevation: 0,
                  children: listState.filteredPlayers
                      .map((p) => PlayerExpansionPanel(p, listState, context))
                      .toList(),
                ),
                const SizedBox(height: 300),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SortableColumnHeader<
        ComparatorType extends ListSortingComparator<Player>>
    extends SortableColumnHeader<Player, ComparatorType, PlayerSortingCubit,
        PlayerListCubit, PlayerListState> {
  const _SortableColumnHeader({
    required super.width,
    required super.title,
  });
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
    bool needsPartner = _playerNeedsPartner(
      listState.competitionRegistrations[player]!,
    );
    return Row(
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
        Flexible(
          flex: 1,
          child: Container(),
        ),
        SizedBox(
          child: SizedBox(
            width: 45,
            child: Tooltip(
              message: _statusTooltip(l10n, player, needsPartner),
              child: Row(
                children: [
                  Icon(
                    playerStatusIcons[player.status],
                    size: 21,
                  ),
                  if (needsPartner)
                    const Icon(
                      partnerMissingIcon,
                      size: 21,
                    )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  static String _statusTooltip(
    AppLocalizations l10n,
    Player player,
    bool needsPartner,
  ) {
    String statusTooltip = l10n.playerStatus(player.status.name);
    if (needsPartner) {
      statusTooltip += '\n${l10n.partnerNeeded}';
    }
    return statusTooltip;
  }

  static String _competitionAbbreviations(
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
        String genderPrefix =
            competition.genderCategory == GenderCategory.female
                ? l10n.womenAbbreviated
                : l10n.menAbbreviated;
        abbreviations.add('$genderPrefix$competitionAbbreviation');
      }
    }
    abbreviations.sort();
    return abbreviations.join(', ');
  }

  static bool _playerNeedsPartner(
    Iterable<CompetitionRegistration> registrations,
  ) {
    for (CompetitionRegistration registration in registrations) {
      if (registration.team.players.length <
          registration.competition.teamSize) {
        return true;
      }
    }
    return false;
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
                      _PlayerRegistrations(registrations: registrations),
                      const SizedBox(width: 50),
                      _PlayerStatus(player: player),
                      const SizedBox(width: 50),
                      _PlayerNotes(player: player),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PlayerEditButton(player: player),
                      _PlayerDeleteMenu(player: player),
                    ],
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

class _PlayerDeleteMenu extends StatelessWidget {
  _PlayerDeleteMenu({
    required this.player,
  }) : super(key: ValueKey('${player.id}-delete-menu'));

  final Player player;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlayerDeleteCubit(
        player: player,
        playerRepository: context.read<CollectionRepository<Player>>(),
        competitionRepository:
            context.read<CollectionRepository<Competition>>(),
        teamRepository: context.read<CollectionRepository<Team>>(),
      ),
      child: const _PlayerDeleteButton(),
    );
  }
}

class _PlayerDeleteButton extends StatelessWidget {
  const _PlayerDeleteButton();

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    PlayerDeleteCubit cubit = context.read<PlayerDeleteCubit>();
    return DialogListener<PlayerDeleteCubit, PlayerDeleteState, bool>(
      builder: (context, state, reason) => ConfirmDialog(
        title: Text(l10n.reallyDeletePlayer),
        confirmButtonLabel: l10n.confirm,
        cancelButtonLabel: l10n.cancel,
      ),
      child: BlocBuilder<PlayerDeleteCubit, PlayerDeleteState>(
        buildWhen: (previous, current) =>
            previous.formStatus != current.formStatus,
        builder: (context, state) {
          return PopupMenuButton<VoidCallback>(
            onSelected: (callback) => callback(),
            tooltip: '',
            itemBuilder: (context) => [
              PopupMenuItem(
                value: () {
                  cubit.playerDeleted();
                },
                child: Text(
                  l10n.deletePlayer,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          );
        },
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit, size: 22),
            const SizedBox(width: 10),
            Text(l10n.editSubject(l10n.player(1))),
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
      flex: 6,
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
                    RegistrationDisplayCard(
                      r,
                      showPartnerInput: true,
                    ),
                ],
              ),
      ),
    );
  }
}

class _PlayerStatus extends StatelessWidget {
  _PlayerStatus({
    required this.player,
  }) : super(key: ValueKey('${player.id}-status-menu'));

  final Player player;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => PlayerStatusCubit(
        player: player,
        playerRepository: context.read<CollectionRepository<Player>>(),
      ),
      child: Expanded(
        flex: 2,
        child: _PlayerDetailsSection(
          title: l10n.status,
          child: Align(
            alignment: AlignmentDirectional.center,
            child: _PlayerStatusSwitcher(player: player),
          ),
        ),
      ),
    );
  }
}

class _PlayerStatusSwitcher extends StatelessWidget {
  const _PlayerStatusSwitcher({
    required this.player,
  });

  final Player player;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<PlayerStatusCubit>();
    return BlocBuilder<PlayerStatusCubit, PlayerStatusState>(
      builder: (context, state) {
        return Column(
          children: [
            if (state.player.status == PlayerStatus.notAttending)
              Tooltip(
                message: l10n.confirmAttendance,
                preferBelow: false,
                child: InkWell(
                  onTap: () {
                    cubit.statusChanged(PlayerStatus.attending);
                  },
                  customBorder: const CircleBorder(),
                  child: _statusIcon(context, state),
                ),
              )
            else
              _statusIcon(context, state),
            const SizedBox(height: 5),
            PopupMenuButton<PlayerStatus>(
              tooltip: l10n.changeStatus,
              onSelected: cubit.statusChanged,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.playerStatus(player.status.name),
                      style: const TextStyle(fontSize: 15),
                    ),
                    const Icon(Icons.arrow_drop_down_sharp),
                  ],
                ),
              ),
              itemBuilder: (context) => PlayerStatus.values
                  .map(
                    (s) => PopupMenuItem<PlayerStatus>(
                      value: s,
                      child: Text(l10n.playerStatus(s.name)),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _statusIcon(BuildContext context, PlayerStatusState state) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: player.status == PlayerStatus.attending
            ? Theme.of(context).primaryColorLight
            : Theme.of(context).highlightColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 40,
          height: 40,
          child: state.loadingStatus == LoadingStatus.loading
              ? const CircularProgressIndicator()
              : Icon(
                  playerStatusIcons[player.status],
                  size: 40,
                ),
        ),
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
      flex: 5,
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
