import 'package:flutter/material.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_sorter/comparators/competition_comparator.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/list_sorting/cubit/list_sorting_cubit.dart';

class CompetitionSortingCubit extends ListSortingCubit<Competition> {
  CompetitionSortingCubit({
    required CompetitionComparator<AgeGroup> ageGroupComparator,
    required CompetitionComparator<PlayingLevel> playingLevelComparator,
    required CompetitionComparator<CompetitionDiscipline> categoryComparator,
    required CompetitionComparator<Team> registrationComparator,
    required CompetitionComparator<TournamentModeSettings> modeComparator,
  }) : super(
          comparators: [
            ageGroupComparator,
            playingLevelComparator,
            categoryComparator,
            registrationComparator,
            modeComparator,
          ],
          defaultComparator: const CompetitionComparator(),
        );

  factory CompetitionSortingCubit.withDefaultComparators(BuildContext context) {
    return CompetitionSortingCubit(
      ageGroupComparator: const CompetitionComparator<AgeGroup>(
        criteria: [
          AgeGroup,
          PlayingLevel,
          CompetitionDiscipline,
          TournamentModeSettings,
        ],
      ),
      playingLevelComparator: const CompetitionComparator<PlayingLevel>(
        criteria: [
          PlayingLevel,
          AgeGroup,
          CompetitionDiscipline,
          TournamentModeSettings,
        ],
      ),
      categoryComparator: const CompetitionComparator<CompetitionDiscipline>(
        criteria: [
          CompetitionDiscipline,
          AgeGroup,
          PlayingLevel,
          TournamentModeSettings,
        ],
      ),
      registrationComparator: const CompetitionComparator<Team>(
        criteria: [
          Team,
          AgeGroup,
          PlayingLevel,
          CompetitionDiscipline,
          TournamentModeSettings,
        ],
      ),
      modeComparator: const CompetitionComparator<TournamentModeSettings>(
        criteria: [
          TournamentModeSettings,
          AgeGroup,
          PlayingLevel,
          CompetitionDiscipline,
        ],
      ),
    );
  }
}
