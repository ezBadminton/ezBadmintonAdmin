import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/competition_draw_selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/choice_chip_tab/choice_chip_tab.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompetitionDrawSelectionList extends StatelessWidget {
  const CompetitionDrawSelectionList({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CompetitionDrawSelectionCubit>();
    var l10n = AppLocalizations.of(context)!;

    return BlocBuilder<CompetitionDrawSelectionCubit,
        CompetitionDrawSelectionState>(
      builder: (context, state) {
        List<Competition> competitions = state.getCollection<Competition>();

        if (competitions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 60.0,
              horizontal: 8.0,
            ),
            child: Text(
              l10n.noCompetitionsDrawHint,
              style: TextStyle(
                fontSize: 17,
                color: Theme.of(context).disabledColor,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              for (Competition competition in competitions) ...[
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
        );
      },
    );
  }
}
