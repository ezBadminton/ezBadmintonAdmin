import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/mixins/match_canceling_mixin.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

part 'result_deletion_state.dart';

class ResultDeletionCubit extends CollectionQuerierCubit<ResultDeletionState>
    with DialogCubit<ResultDeletionState>, MatchCancelingMixin {
  ResultDeletionCubit({
    required this.match,
    required this.tournamentProgressGetter,
    required CollectionRepository<MatchData> matchDataRepository,
  }) : super(
          collectionRepositories: [
            matchDataRepository,
          ],
          ResultDeletionState(),
        );

  final BadmintonMatch match;

  final TournamentProgressState Function() tournamentProgressGetter;

  void resultDeleted() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    bool userConfirmation = (await requestDialogChoice<bool>())!;
    if (!userConfirmation) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.canceled));
      return;
    }

    MatchData matchDataWithoutScore = match.matchData!.copyWith(sets: []);

    MatchData? updatedMatchData =
        await querier.updateModel(matchDataWithoutScore);
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
