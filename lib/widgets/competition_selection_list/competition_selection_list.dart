import 'package:ez_badminton_admin_app/l10n/l10n.dart';
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
  });

  final String noCompetitionsHint;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<CompetitionSelectionCubit>();

    return BlocBuilder<CompetitionSelectionCubit, CompetitionSelectionState>(
      builder: (context, state) {
        List<Competition> competitions = state.getCollection<Competition>();
        List<Competition> selectable = state.selectableCompetitions;

        if (selectable.isEmpty) {
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.grey[100],
              width: double.infinity,
              child: Column(
                children: [
                  const SizedBox(height: 7),
                  Text(
                    l10n.nCompetitionsShown(selectable.length),
                    style: TextStyle(fontSize: 13),
                  ),
                  Text(
                    l10n.ofN(competitions.length),
                    style: TextStyle(fontSize: 10),
                  ),
                  const SizedBox(height: 7),
                  const Divider(height: 0, indent: 5, endIndent: 5),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  for (Competition competition in selectable) ...[
                    ChoiceChipTab(
                      onSelected: (_) {
                        cubit.competitionToggled(competition);
                      },
                      selected: state.selectedCompetition.value == competition,
                      label: SizedBox(
                        width: 210,
                        child: CompetitionLabel(
                          competition: competition,
                          abbreviated: true,
                          playingLevelMaxWidth: 100,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                  const SizedBox(height: 200),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
