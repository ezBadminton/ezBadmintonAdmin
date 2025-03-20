import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/list_sorting/comparator/list_sorting_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_list_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/club_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/name_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/cubit/player_sorting_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/widgets/player_expansion_panel.dart';
import 'package:ez_badminton_admin_app/widgets/sortable_column_header/sortable_column_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlayerList extends StatelessWidget {
  const PlayerList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerListCubit, PlayerListState>(
      builder: (context, listState) {
        var l10n = AppLocalizations.of(context)!;
        int filteredLength = listState.filteredPlayers.length;
        int fullLength = listState.getCollection<Player>().length;
        return Expanded(
          child: SizedBox(
            width: 1150,
            child: Column(
              children: [
                Text(
                  '${l10n.nPlayersShown(filteredLength)} (${l10n.ofN(fullLength)})',
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .color!
                        .withOpacity(.4),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                const _PlayerListHeader(),
                _PlayerListBody(listState: listState),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlayerListHeader extends StatelessWidget {
  const _PlayerListHeader();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Container(
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
                width: 100,
                child: Text(l10n.registrations),
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
    );
  }
}

class _PlayerListBody extends StatelessWidget {
  const _PlayerListBody({
    required this.listState,
  });

  final PlayerListState listState;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        itemCount: listState.filteredPlayers.length + 1,
        itemBuilder: (context, index) {
          if (index == listState.filteredPlayers.length) {
            return SizedBox(height: 260);
          }
          var player = listState.filteredPlayers[index];
          return PlayerExpansionPanel(
            player,
            listState,
            index,
            key: ValueKey('${player.id}-expansion-panel'),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(
            height: 0,
            thickness: 1,
          );
        },
      ),
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
