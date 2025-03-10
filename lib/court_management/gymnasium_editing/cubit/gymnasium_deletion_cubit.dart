import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/court_management/cubit/cubit/court_cubit.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

part 'gymnasium_deletion_state.dart';

class GymnasiumDeletionCubit
    extends CollectionQuerierCubit<GymnasiumDeletionState>
    with DialogCubit<GymnasiumDeletionState> {
  GymnasiumDeletionCubit({
    required Gymnasium gymnasium,
    required ModelStore<Gymnasium> gymnasiumRepository,
    required ModelStore<Court> courtRepository,
    required this.courtStateGetter,
  }) : super(
          modelStores: [
            gymnasiumRepository,
            courtRepository,
          ],
          GymnasiumDeletionState(gymnasium: gymnasium),
        );

  final CourtState Function() courtStateGetter;

  void gymnasiumDeleted() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    CourtState courtState = courtStateGetter();

    bool isGymInUse = courtState.occupied.keys
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
      CollectionUpdateEvent<Model>? updateEvent) {}
}
