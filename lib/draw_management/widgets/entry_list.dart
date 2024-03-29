import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/assets/badminton_icons_icons.dart';
import 'package:ez_badminton_admin_app/constants.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/seeding_cubit.dart';
import 'package:ez_badminton_admin_app/draw_management/utils/team_status.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/team_comparator.dart';
import 'package:ez_badminton_admin_app/widgets/cross_fade_drawer/cross_fade_drawer_controller.dart';
import 'package:ez_badminton_admin_app/widgets/implicit_animated_list/reorderable_implicit_animated_list.dart';
import 'package:ez_badminton_admin_app/widgets/implicit_animated_list/reorderable_item_gap.dart';
import 'package:ez_badminton_admin_app/widgets/long_tooltip/long_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// List of registered Teams that are marked as attending (entries)
class EntryList extends StatelessWidget {
  const EntryList({
    super.key,
    required this.competition,
    required this.drawerController,
  });

  final Competition competition;
  final CrossFadeDrawerController drawerController;

  @override
  Widget build(BuildContext context) {
    bool seedsEditable = competition.draw.isEmpty;

    return BlocProvider(
      key: ValueKey('EntryListSeedingCubit-${competition.id}'),
      create: (context) => SeedingCubit(
        competition: competition,
        competitionRepository:
            context.read<CollectionRepository<Competition>>(),
      ),
      child: BlocBuilder<SeedingCubit, SeedingState>(
        builder: (context, state) {
          return _EntryList(
            drawerController: drawerController,
            competition: state.competition,
            entries: [
              ...state.competition.seeds,
              ..._getUnseededEntries(state.competition),
            ],
            numSeeds: state.competition.seeds.length,
            seedingMode: state.competition.tournamentModeSettings?.seedingMode,
            seedsEditable: seedsEditable,
          );
        },
      ),
    );
  }

  static List<Team> _getUnseededEntries(Competition competition) {
    return TeamComparator.sortTeams(
      competition,
      _filterUnseededTeams(competition),
    );
  }

  static List<Team> _filterUnseededTeams(Competition competition) {
    return competition.registrations
        .whereNot((t) => competition.seeds.contains(t))
        .toList();
  }
}

class _EntryList extends StatelessWidget {
  const _EntryList({
    required this.competition,
    required this.entries,
    required this.numSeeds,
    required this.seedingMode,
    required this.seedsEditable,
    this.drawerController,
  });

  final Competition competition;

  final List<Team> entries;
  final int numSeeds;
  final SeedingMode? seedingMode;

  final bool seedsEditable;

  final CrossFadeDrawerController? drawerController;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<SeedingCubit>();

    int numEntries = entries.length;
    int numReady = entries
        .where((team) => teamStatus(team) == PlayerStatus.attending)
        .where((team) => team.players.length == competition.teamSize)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: Theme.of(context).primaryColor.withOpacity(.45),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 12.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.entryList,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        l10n.teamsReady(numReady, numEntries),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (drawerController != null)
                  Tooltip(
                    message: l10n.collapse,
                    preferBelow: false,
                    child: InkResponse(
                      onTap: drawerController!.collapse,
                      radius: 21,
                      child: Icon(
                        Icons.keyboard_double_arrow_left,
                        size: 28,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const Divider(height: 0),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9.0),
            child: ReorderableImplicitAnimatedList(
              elements: entries,
              onReorder: cubit.seedsReordered,
              duration: const Duration(milliseconds: 120),
              itemBuilder: _itemBuilder,
              itemDragBuilder: _itemDragBuilder,
              itemReorderBuilder: _itemReorderBuilder,
              itemPlaceholderBuilder: _itemPlaceholderBuilder,
              elementsEqual: _entryListElementsEqual,
            ),
          ),
        ),
      ],
    );
  }

  bool _entryListElementsEqual(Team element1, Team element2) {
    bool hasSameMembers =
        element1 == element2 && element1.players.equals(element2.players);
    bool areMembersRenamed = false;
    bool hasSameStatus = teamStatus(element1) == teamStatus(element2);

    if (hasSameMembers) {
      for (int i = 0; i < element1.players.length; i += 1) {
        String nameA = display_strings.playerWithClub(element1.players[i]);
        String nameB = display_strings.playerWithClub(element2.players[i]);
        if (nameA != nameB) {
          areMembersRenamed = true;
        }
      }
    }

    return hasSameMembers && !areMembersRenamed && hasSameStatus;
  }

  Widget _itemBuilder(
    BuildContext context,
    Team team,
    Animation<double> animation,
    Draggable Function(BuildContext, Widget) draggableWrapper,
    int? hoveringIndex,
  ) {
    var l10n = AppLocalizations.of(context)!;
    int index = entries.indexOf(team);
    int? seed = index < numSeeds ? index : null;

    Widget dragIndicator = draggableWrapper(
      context,
      Tooltip(
        message: l10n.reorder,
        waitDuration: const Duration(milliseconds: 500),
        child: Icon(
          Icons.drag_indicator,
          color: Theme.of(context).disabledColor,
        ),
      ),
    );

    Widget teamItem = _Entry(
      team: team,
      competition: competition,
      seed: seed,
      index: index,
      hoveringIndex: hoveringIndex,
      seedingMode: seedingMode,
      seedEditable: seedsEditable,
      draggable: seed == null ? null : dragIndicator,
    );

    return teamItem;
  }

  Widget _itemReorderBuilder(
    BuildContext context,
    Team team,
    Animation<double> animation,
    Draggable Function(BuildContext, Widget) draggableWrapper,
    int indexDelta,
  ) {
    Widget teamItem = _itemBuilder(
      context,
      team,
      animation,
      draggableWrapper,
      null,
    );

    return SlideTransition(
      position: animation.drive(Tween<Offset>(
        begin: Offset(0, -indexDelta.toDouble()),
        end: Offset.zero,
      )),
      child: teamItem,
    );
  }

  Widget _itemDragBuilder(
    BuildContext context,
    Team team,
  ) {
    return Transform.translate(
      offset: const Offset(-10, -5),
      child: FractionalTranslation(
        translation: const Offset(-1, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (Player player in team.players)
              Text(display_strings.playerWithClub(player)),
          ],
        ),
      ),
    );
  }

  Widget _itemPlaceholderBuilder(
    BuildContext context,
    Team team,
    Animation<double> animation,
    Draggable Function(BuildContext, Widget) draggableWrapper,
    int? hoveringIndex,
  ) {
    int index = entries.indexOf(team);
    int? seed = index < numSeeds ? index : null;

    Widget dragIndicator = draggableWrapper(
      context,
      Icon(
        Icons.unfold_more,
        color: Theme.of(context).disabledColor,
      ),
    );

    Widget teamItem = _Entry(
      team: team,
      competition: competition,
      seed: seed,
      index: index,
      hoveringIndex: hoveringIndex,
      seedingMode: seedingMode,
      seedEditable: seedsEditable,
      draggable: seed == null ? null : dragIndicator,
      textStyle: TextStyle(color: Theme.of(context).disabledColor),
    );

    return teamItem;
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.team,
    required this.competition,
    required this.index,
    this.hoveringIndex,
    this.seed,
    this.seedingMode,
    required this.seedEditable,
    this.draggable,
    this.textStyle,
  });

  final Team team;
  final Competition competition;

  final int index;
  final int? hoveringIndex;

  final int? seed;
  final SeedingMode? seedingMode;
  final bool seedEditable;

  final Widget? draggable;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    Widget teamCard = _TeamCard(
      team: team,
      competition: competition,
      seed: seed,
      seedingMode: seedingMode,
      seedEditable: seedEditable,
      draggable: draggable,
      textStyle: textStyle,
    );

    if (seed == null || !seedEditable) {
      teamCard = _wrapWithNormalGaps(teamCard);
    } else {
      teamCard = _wrapWithReorderingGaps(teamCard);
    }

    return teamCard;
  }

  Widget _wrapWithReorderingGaps(Widget widget) {
    return Column(
      children: [
        ReorderableItemGap(
          elementIndex: index,
          hoveringIndex: hoveringIndex,
          top: true,
          height: 3,
        ),
        widget,
        ReorderableItemGap(
          elementIndex: index,
          hoveringIndex: hoveringIndex,
          top: false,
          height: 3,
        ),
      ],
    );
  }

  Widget _wrapWithNormalGaps(Widget widget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: widget,
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.team,
    required this.competition,
    required this.seed,
    this.seedingMode,
    this.draggable,
    required this.seedEditable,
    this.textStyle,
  });

  final Team team;
  final Competition competition;

  final int? seed;
  final SeedingMode? seedingMode;

  final Widget? draggable;
  final bool seedEditable;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<SeedingCubit>();
    var l10n = AppLocalizations.of(context)!;

    Widget? teamStatusIcon = _teamStatusIcon(l10n);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.4),
          width: 1,
        ),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (Player player in team.players) ...[
                          Text(
                            display_strings.playerWithClub(player),
                            overflow: TextOverflow.ellipsis,
                            style: textStyle,
                          ),
                          if (team.players.length == 2 &&
                              player == team.players.first)
                            const SizedBox(height: 7),
                        ],
                      ],
                    ),
                  ),
                  if (teamStatusIcon != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: teamStatusIcon,
                    ),
                ],
              ),
            ),
            if (seed != null)
              _SeedLabel(
                seed: seed!,
                seedingMode: seedingMode,
              ),
            if (draggable != null && seedEditable) draggable!,
            LongTooltip(
              message: seedEditable
                  ? (seed == null ? l10n.addToSeeds : l10n.removeFromSeeds)
                  : l10n.seedsNotEditable,
              waitDuration:
                  seedEditable ? null : const Duration(milliseconds: 500),
              child: IconButton(
                onPressed:
                    seedEditable ? () => cubit.seedingToggled(team) : null,
                splashRadius: 26,
                icon: Icon(
                  seed == null
                      ? BadmintonIcons.seedling
                      : BadmintonIcons.crossed_seedling,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _teamStatusIcon(AppLocalizations l10n) {
    if (team.players.length != competition.teamSize) {
      return LongTooltip(
        message: l10n.teamNotComplete,
        child: const Icon(
          partnerMissingIcon,
          size: 21,
        ),
      );
    }

    if (teamStatus(team) != PlayerStatus.attending) {
      return LongTooltip(
        message: l10n.teamNotAttending(competition.teamSize),
        child: Icon(
          playerStatusIcons[PlayerStatus.notAttending],
          size: 21,
        ),
      );
    }

    return null;
  }
}

/// The label of a seed
class _SeedLabel extends StatelessWidget {
  /// The [seed] index is displayed as the seeded rank according to
  /// [seedingMode].
  const _SeedLabel({
    required this.seed,
    SeedingMode? seedingMode,
  }) : seedingMode = seedingMode ?? SeedingMode.tiered;

  final int seed;
  final SeedingMode seedingMode;

  @override
  Widget build(BuildContext context) {
    String label = display_strings.seedLabel(seed, seedingMode);

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 2.0, end: 6.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }
}
