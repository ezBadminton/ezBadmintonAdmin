import 'package:ez_badminton_admin_app/competition_management/competition_sorter/comparators/competition_comparator.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/widgets/choice_chip_tab/choice_chip_tab.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/competition_selection_list/cubit/competition_selection_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompetitionSelectionList extends StatelessWidget {
  const CompetitionSelectionList({
    super.key,
    required this.noCompetitionsHint,
  }) : comparator = const CompetitionComparator();

  final String noCompetitionsHint;
  final CompetitionComparator comparator;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CompetitionSelectionCubit>();

    return BlocBuilder<CompetitionSelectionCubit, CompetitionSelectionState>(
      builder: (context, state) {
        List<Competition> competitions = state.getCollection<Competition>();

        if (competitions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 60.0,
              horizontal: 8.0,
            ),
            child: Text(
              noCompetitionsHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Theme.of(context).disabledColor,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (Competition competition in competitions) ...[
              ChoiceChipTab(
                onSelected: (_) {
                  cubit.competitionToggled(competition);
                },
                selected: state.selectedCompetition.value == competition,
                label: SizedBox(
                  width: 130,
                  child: CompetitionLabel(
                    competition: competition,
                    abbreviated: true,
                    playingLevelMaxWidth: 100,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}
