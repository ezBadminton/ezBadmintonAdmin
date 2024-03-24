import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/tournament_mode_hydration.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:formz/formz.dart';

import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';

part 'competition_start_stop_state.dart';

class CompetitionStartStopCubit
    extends CollectionQuerierCubit<CompetitionStartStopState> with DialogCubit {
  CompetitionStartStopCubit({
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<MatchData> matchDataRepository,
    required CollectionRepository<MatchSet> matchSetRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
            matchDataRepository,
            matchSetRepository,
          ],
          CompetitionStartStopState(),
        );

  void competitionsStarted([List<Competition>? competitions]) async {
    competitions = competitions ?? state.selectedCompetitions;

    if (state.formStatus == FormzSubmissionStatus.inProgress ||
        !_areCompetitionsStartable(competitions)) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    bool userConfirmation = (await requestDialogChoice<bool>())!;
    if (!userConfirmation) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.canceled));
      return;
    }

    Iterable<Future<FormzSubmissionStatus>> competitionStarts =
        competitions.map(_startCompetition);
    List<FormzSubmissionStatus> starts = await Future.wait(competitionStarts);
    if (starts.contains(FormzSubmissionStatus.failure)) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  void competitionCanceled(Competition competition) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    assert(competition.matches.isNotEmpty);

    bool userConfirmation =
        (await requestDialogChoice<bool>(reason: competition))!;
    if (!userConfirmation) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.canceled));
      return;
    }

    Competition stoppedCompetition = competition.copyWith(matches: []);

    Competition? updatedCompetition =
        await querier.updateModel(stoppedCompetition);
    if (updatedCompetition == null) {
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

    int numMatches = numMatchesFromTournament(tournamentMode);

    bool competitionStarted = await querier.getRepository<Competition>().route(
      method: "POST",
      data: {
        "competition": competition.id,
        "numMatches": numMatches,
      },
    );

    if (!competitionStarted) {
      return FormzSubmissionStatus.failure;
    }

    return FormzSubmissionStatus.success;
  }

  void selectedCompetitionsChanged(List<Competition> selection) {
    emit(state.copyWith(
      selectedCompetitions: selection,
      selectionIsStartable: _areCompetitionsStartable(selection),
    ));
  }

  static bool _areCompetitionsStartable(List<Competition> competitions) {
    return competitions.firstWhereOrNull(
          (c) => c.draw.isEmpty || c.matches.isNotEmpty,
        ) ==
        null;
  }

  @override
  void onCollectionUpdate(List<List<Model>> collections,
          List<CollectionUpdateEvent<Model>> updateEvents) =>
      {};
}
