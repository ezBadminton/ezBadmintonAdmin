import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_delete_state.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

class PlayerDeleteCubit extends CollectionQuerierCubit<PlayerDeleteState>
    with DialogCubit<PlayerDeleteState> {
  PlayerDeleteCubit({
    required Player player,
    required CollectionRepository<Player> playerRepository,
  }) : super(
          collectionRepositories: [playerRepository],
          PlayerDeleteState(player: player),
        );

  void playerDeleted() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    bool deletionConfirmed = (await requestDialogChoice<bool>())!;
    if (!deletionConfirmed) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.canceled));
      return;
    }

    Player player = state.player;

    bool deletionSuccessful = await querier.deleteModel(player);
    if (!deletionSuccessful) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  @override
  void onCollectionUpdate(List<List<Model>> collections,
      List<CollectionUpdateEvent<Model>> updateEvents) {}
}
