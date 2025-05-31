import 'package:ez_badminton_admin_app/list_selection/cubit/model_selection_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/bulk_player_status_cubit.dart';
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
    return BlocConsumer<PlayerListCubit, PlayerListState>(
      listenWhen: (previous, current) =>
          previous.filteredPlayers != current.filteredPlayers,
      listener: (context, state) {
        var selectionCubit = context.read<ModelSelectionCubit<Player>>();
        selectionCubit.displayModelsChanged(state.filteredPlayers);
      },
      builder: (context, listState) {
        int filteredLength = listState.filteredPlayers.length;
        int fullLength = listState.getCollection<Player>().length;
        return Expanded(
          child: SizedBox(
            width: 1150,
            child: Column(
              children: [
                PlayerSelectionOptions(
                  filteredLength: filteredLength,
                  fullLength: fullLength,
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

class PlayerSelectionOptions extends StatelessWidget {
  const PlayerSelectionOptions({
    super.key,
    required this.filteredLength,
    required this.fullLength,
  });

  final int filteredLength;
  final int fullLength;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var greyColor =
        Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: .4);
    return BlocBuilder<ModelSelectionCubit<Player>,
        ModelSelectionState<Player>>(
      builder: (context, state) {
        int numSelected = state.selectedModels.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: numSelected == 0 ? 0 : .25),
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5.0),
            child: Row(
              children: [
                Text(
                  '${l10n.nPlayersShown(filteredLength)} (${l10n.ofN(fullLength)})',
                  style: TextStyle(
                    color: greyColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  l10n.nSubjectsSelected(
                    numSelected,
                    l10n.player(numSelected),
                  ),
                  style: TextStyle(
                    color: numSelected == 0 ? greyColor : null,
                    fontSize: 12,
                  ),
                ),
                const Expanded(child: SizedBox()),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: numSelected == 0 ? 0.0 : 1.0,
                  child: ElevatedButton(
                    onPressed: numSelected == 0
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (_) => _BulkPlayerStatusDialog(
                                outerContext: context,
                              ),
                            );
                          },
                    child: Text(l10n.editSubject(l10n.status)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BulkPlayerStatusDialog extends StatelessWidget {
  const _BulkPlayerStatusDialog({
    required this.outerContext,
  });

  final BuildContext outerContext;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var selectionCubit = outerContext.read<ModelSelectionCubit<Player>>();
    var players = selectionCubit.state.selectedModels;
    return BlocProvider(
      create: (context) => BulkPlayerStatusCubit(
        bulkStatusEndpoint: context.read(),
        players: players,
      ),
      child: BlocBuilder<BulkPlayerStatusCubit, BulkPlayerStatusState>(
        builder: (context, state) {
          var editingCubit = context.read<BulkPlayerStatusCubit>();
          return AlertDialog(
            title: Text(l10n.bulkEditStatus(players.length)),
            content: DropdownButtonFormField(
              value: state.playerStatus.value,
              items: PlayerStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(l10n.playerStatus(status.name)),
                    ),
                  )
                  .toList(),
              decoration: InputDecoration(labelText: l10n.status),
              onChanged: editingCubit.statusChanged,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: state.playerStatus.value == null
                    ? null
                    : () {
                        editingCubit.submitBulkPlayerStatus();
                        Navigator.of(context).pop();
                      },
                child: Text(l10n.save),
              ),
            ],
          );
        },
      ),
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
              Transform.scale(
                scale: 1.2,
                child: BlocBuilder<ModelSelectionCubit<Player>,
                    ModelSelectionState<Player>>(
                  builder: (context, state) {
                    var selectionCubit =
                        context.read<ModelSelectionCubit<Player>>();
                    return Checkbox(
                      value: state.selectionTristate,
                      onChanged: (_) => selectionCubit.allModelsToggled(),
                      tristate: true,
                    );
                  },
                ),
              ),
              const SizedBox(width: 11),
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
