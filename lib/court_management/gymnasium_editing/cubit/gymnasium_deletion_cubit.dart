import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

part 'gymnasium_deletion_state.dart';

class GymnasiumDeletionCubit
    extends CollectionQuerierCubit<GymnasiumDeletionState>
    with DialogCubit<GymnasiumDeletionState> {
  GymnasiumDeletionCubit({
    required Gymnasium gymnasium,
    required CollectionRepository<Gymnasium> gymnasiumRepository,
    required CollectionRepository<Court> courtRepository,
  }) : super(
          collectionRepositories: [
            gymnasiumRepository,
            courtRepository,
          ],
          GymnasiumDeletionState(gymnasium: gymnasium),
        );

  void gymnasiumDeleted() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    List<Court>? courts = await querier.fetchCollection<Court>();
    if (courts == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

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

    Iterable<Future<bool>> courtDeletions =
        courtsOfGym.map((c) => querier.deleteModel(c));
    List<bool> courtsDeleted = await Future.wait(courtDeletions);
    if (courtsDeleted.contains(false)) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    bool gymDeleted = await querier.deleteModel(state.gymnasium);
    if (!gymDeleted) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }
}
