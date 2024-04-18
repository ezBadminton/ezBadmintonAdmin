import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/cubit/competition_multi_selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompetitionMutliSelectionList extends StatelessWidget {
  const CompetitionMutliSelectionList({super.key});

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
