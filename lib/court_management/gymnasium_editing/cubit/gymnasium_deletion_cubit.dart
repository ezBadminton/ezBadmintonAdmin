import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

part 'gymnasium_deletion_state.dart';

class GymnasiumDeletionCubit
    extends CollectionQuerierCubit<GymnasiumDeletionState>
    with DialogCubit<GymnasiumDeletionState> {
  GymnasiumDeletionCubit({
    required Gymnasium gymnasium,
    required this.tournamentProgressGetter,
    required CollectionRepository<Gymnasium> gymnasiumRepository,
    required CollectionRepository<Court> courtRepository,
  }) : super(
          collectionRepositories: [
            gymnasiumRepository,
            courtRepository,
          ],
          GymnasiumDeletionState(gymnasium: gymnasium),
        );

  final TournamentProgressState Function() tournamentProgressGetter;

  void gymnasiumDeleted() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    TournamentProgressState progressState = tournamentProgressGetter();

    bool isGymInUse = progressState.occupiedCourts.keys
            .firstWhereOrNull((court) => court.gymnasium == state.gymnasium) !=
        null;

    if (isGymInUse) {
      requestDialogChoice<Error>();
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    List<Court> courts = querier.getCollection<Court>();

    List<Court> courtsOfGym =
        courts.where((c) => c.gymnasium == state.gymnasium).toList();

    bool userConfirmation = true;
    if (courtsOfGym.isNotEmpty) {
      userConfirmation = (await requestDialogChoice<bool>())!;
    }
    if (!userConfirmation) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.canceled));
      return;
    }

    bool gymDeleted = await querier.deleteModel(state.gymnasium);
    if (!gymDeleted) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  @override
  void onCollectionUpdate(List<List<Model>> collections,
      List<CollectionUpdateEvent<Model>> updateEvents) {}
}
