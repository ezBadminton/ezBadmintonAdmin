import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/list_filter/cubit/list_filter_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_list_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/view/player_editing_form.dart';
import 'package:ez_badminton_admin_app/player_management/view/player_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlayerListPage extends StatelessWidget {
  const PlayerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => ListFilterCubit(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.playerManagement)),
        body: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: const [
              PlayerFilter(),
              _PlayerList(),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 80, 40),
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(PlayerEditingForm.route());
            },
            icon: const Icon(Icons.person_add_alt_1),
            label: Text(l10n.add),
          ),
        ),
      ),
    );
  }
}

class _PlayerList extends StatelessWidget {
  const _PlayerList();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      lazy: false,
      create: (_) => PlayerListCubit(
        playerRepository: context.read<CollectionRepository<Player>>(),
        competitionRepository:
            context.read<CollectionRepository<Competition>>(),
      ),
      child: BlocListener<ListFilterCubit, ListFilterState>(
        listener: (context, state) {
          context.read<PlayerListCubit>().filterChanged(state.filters);
        },
        child: BlocBuilder<PlayerListCubit, PlayerListState>(
          buildWhen: (previous, current) =>
              (previous.filteredPlayers != current.filteredPlayers ||
                  previous.playerCompetitions != current.playerCompetitions) &&
              current.allPlayers.length == current.playerCompetitions.length,
          builder: (context, state) {
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
              rows: state.filteredPlayers.map((player) {
                return DataRow(cells: [
                  DataCell(
                    SizedBox(
                      width: 190,
                      child: Text(
                        '${player.firstName} ${player.lastName}',
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 190,
                      child: Text(
                        player.club.name.isNotEmpty ? player.club.name : '-',
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 73,
                      child: Text(
                        _competitionAbbreviations(
                          state.playerCompetitions[player]!,
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
                        player.playingLevel.name.isNotEmpty
                            ? player.playingLevel.name
                            : '-',
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
                        player.eMail.isNotEmpty ? player.eMail : '-',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ]);
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  static String _competitionAbbreviations(
    List<Competition> competitions,
    AppLocalizations l10n,
  ) {
    List<String> abbreviations = [];
    for (var competition in competitions) {
      String competitionAbbreviation =
          l10n.competitionTypeAbbreviated(competition.getCompetitionType().id);
      if (competition.gender == GenderCategory.mixed ||
          competition.gender == GenderCategory.any) {
        abbreviations.add(competitionAbbreviation);
      } else {
        String genderPrefix = competition.gender == GenderCategory.female
            ? l10n.womenAbbreviated
            : l10n.menAbbreviated;
        abbreviations.add('$genderPrefix$competitionAbbreviation');
      }
    }
    abbreviations.sort();
    return abbreviations.join(', ');
  }
}
