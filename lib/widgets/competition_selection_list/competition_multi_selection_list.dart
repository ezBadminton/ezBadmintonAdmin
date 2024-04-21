import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/cubit/competition_multi_selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompetitionMutliSelectionList extends StatelessWidget {
  const CompetitionMutliSelectionList({
    super.key,
    this.emptyListPlaceholder,
  });

  /// A widget that is being displayed when the list is empty
  final Widget? emptyListPlaceholder;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CompetitionMultiSelectionCubit>();

    return BlocBuilder<CompetitionMultiSelectionCubit,
        CompetitionMultiSelectionState>(
      builder: (context, state) {
        return LoadingScreen(
          loadingStatus: state.loadingStatus,
          builder: (BuildContext context) {
            List<Competition> competitions = state.getCollection<Competition>();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CompetitionMultiSelectionListHeader(),
                  if (competitions.isEmpty && emptyListPlaceholder != null) ...[
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: emptyListPlaceholder!,
                    ),
                  ],
                  for (Competition competition in competitions)
                    CheckboxListTile(
                      value: state.selectedCompetitions.contains(competition),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (_) => cubit.competitionToggled(competition),
                      title: CompetitionLabel(
                        competition: competition,
                        textStyle: const TextStyle(fontSize: 15),
                        alignment: MainAxisAlignment.start,
                        playingLevelMaxWidth: 100,
                      ),
                    )
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CompetitionMultiSelectionListHeader extends StatelessWidget {
  const _CompetitionMultiSelectionListHeader();

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CompetitionMultiSelectionCubit>();
    var l10n = AppLocalizations.of(context)!;

    return BlocBuilder<CompetitionMultiSelectionCubit,
        CompetitionMultiSelectionState>(
      builder: (context, state) {
        int numSelectable = state.getCollection<Competition>().length;
        int numSelected = state.selectedCompetitions.length;
        bool? tristate;
        if (numSelected == numSelectable) {
          tristate = true;
        } else if (numSelected == 0) {
          tristate = false;
        } else {
          tristate = null;
        }

        return Container(
          color: Theme.of(context).primaryColor.withOpacity(.2),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: tristate,
                    onChanged: (_) => cubit.allCompetitionsToggled(),
                    tristate: true,
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  l10n.competition(2),
                  style: const TextStyle(fontSize: 19),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
