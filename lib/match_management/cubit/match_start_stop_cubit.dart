import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/mixins/match_canceling_mixin.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

part 'match_start_stop_state.dart';

class MatchStartStopCubit extends CollectionQuerierCubit<MatchStartStopState>
    with DialogCubit<MatchStartStopState>, MatchCancelingMixin {
  MatchStartStopCubit({
    required this.tournamentProgressGetter,
    required CollectionRepository<MatchData> matchDataRepository,
  }) : super(
          collectionRepositories: [
            matchDataRepository,
          ],
          MatchStartStopState(),
        );

  final TournamentProgressState Function() tournamentProgressGetter;

  /// Called when a match that has a court assigned is started
  Future<void> matchStarted(MatchData matchData) async {
    assert(matchData.court != null && matchData.startTime == null);

    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    DateTime now = DateTime.now().toUtc();
    MatchData matchWithStartTime = matchData.copyWith(startTime: now);

    MatchData? updatedMatch = await querier.updateModel(matchWithStartTime);
    if (updatedMatch == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  /// Cancels a match before it has its score recorded.
  ///
  /// When the match already ended, it is attempted to restore the court
  /// assignment. Should the court already be assigned to a new match, the
  /// match gets no court and needs to be assigned again.
  void matchCanceled(MatchData matchData) async {
    assert(matchData.startTime != null && matchData.sets.isEmpty);

    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    bool userConfirmation = (await requestDialogChoice<bool>())!;

    if (!userConfirmation) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.canceled));
      return;
    }

    TournamentProgressState tournamentProgressState =
        tournamentProgressGetter();

    MatchData canceledMatchData =
        cancelMatch(matchData, tournamentProgressState);

    MatchData? updatedMatchData = await querier.updateModel(canceledMatchData);
    if (updatedMatchData == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  /// Ends a match without a score being recorded.
  ///
  /// This frees the court for the next match. The score can be entered later.
  void matchEnded(MatchData matchData) async {
    assert(matchData.court != null &&
        matchData.startTime != null &&
        matchData.endTime == null);

    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    DateTime now = DateTime.now().toUtc();

    MatchData matchDataWithEndTime = matchData.copyWith(endTime: now);

    MatchData? updatedMatchData =
        await querier.updateModel(matchDataWithEndTime);
    if (updatedMatchData == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  @override
  void onCollectionUpdate(List<List<Model>> collections,
      List<CollectionUpdateEvent<Model>> updateEvents) {}
}
