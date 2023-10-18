import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/tournament_mode_hydration.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:formz/formz.dart';

import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';

part 'competition_starting_state.dart';

class CompetitionStartingCubit
    extends CollectionQuerierCubit<CompetitionStartingState> with DialogCubit {
  CompetitionStartingCubit({
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<MatchData> matchDataRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
            matchDataRepository,
          ],
          CompetitionStartingState(),
        );

  void startCompetitions() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    if (!state.selectionIsStartable) {
      requestDialogChoice<Exception>(reason: false);
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    bool userConfirmation = (await requestDialogChoice<bool>())!;
    if (!userConfirmation) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.canceled));
      return;
    }

    Iterable<Future<FormzSubmissionStatus>> competitionStarts =
        state.selectedCompetitions.map(_startCompetition);
    List<FormzSubmissionStatus> starts = await Future.wait(competitionStarts);
    if (starts.contains(FormzSubmissionStatus.failure)) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  Future<FormzSubmissionStatus> _startCompetition(
    Competition competition,
  ) async {
    bool hasDraw = competition.draw.isNotEmpty;
    bool alreadyHasMatches = competition.matches.isNotEmpty;

    if (!hasDraw || alreadyHasMatches) {
      return FormzSubmissionStatus.failure;
    }

    BadmintonTournamentMode tournamentMode = createTournamentMode(competition);

    List<MatchData> matches = createMatchesFromTournament(tournamentMode);

    List<MatchData?> createdMatches = await querier.createModels(matches);
    if (createdMatches.contains(null)) {
      return FormzSubmissionStatus.failure;
    }

    Competition competitionWithMatches = competition.copyWith(
      matches: createdMatches.whereType<MatchData>().toList(),
    );

    Competition? updatedCompetition =
        await querier.updateModel(competitionWithMatches);
    if (updatedCompetition == null) {
      return FormzSubmissionStatus.failure;
    }

    return FormzSubmissionStatus.success;
  }

  void selectedCompetitionsChanged(List<Competition> selection) {
    emit(state.copyWith(
      selectedCompetitions: selection,
      selectionIsStartable: _isSelectionStartable(selection),
    ));
  }

  static bool _isSelectionStartable(List<Competition> selection) {
    return selection.firstWhereOrNull(
          (c) => c.draw.isEmpty || c.matches.isNotEmpty,
        ) ==
        null;
  }
}
