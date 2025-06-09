import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';
import 'package:model_repository/model_repository.dart';

part 'info_screen_user_list_state.dart';

class InfoScreenUserListCubit
    extends CollectionQuerierCubit<InfoScreenUserListState> {
  InfoScreenUserListCubit({
    required ModelStore<InfoscreenUser> infoscreenUserStore,
  }) : super(
          modelStores: [
            infoscreenUserStore,
          ],
          InfoScreenUserListState(),
        );

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    CollectionUpdateEvent<Model>? updateEvent,
  ) {
    var updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    List<InfoscreenUser> infoscreenUsers =
        List.of(updatedState.getCollection());
    infoscreenUsers.sortBy((user) => user.username);
    updatedState.overrideCollection(infoscreenUsers);

    emit(updatedState);
  }

  void userDeleted(InfoscreenUser user) async {
    if (state.submissionStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));

    bool deleted = await querier.deleteModel(user);
    if (deleted) {
      emit(state.copyWith(submissionStatus: FormzSubmissionStatus.success));
    } else {
      emit(state.copyWith(submissionStatus: FormzSubmissionStatus.failure));
    }
  }
}
