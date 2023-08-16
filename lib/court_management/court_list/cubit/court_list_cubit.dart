import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'court_list_state.dart';

class CourtListCubit extends CollectionFetcherCubit<CourtListState> {
  CourtListCubit({
    required CollectionRepository<Court> courtRepository,
  }) : super(
          collectionRepositories: [
            courtRepository,
          ],
          CourtListState(),
        ) {
    loadCollections();
  }

  void loadCollections() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Court>(),
      ],
      onSuccess: (updatedState) {
        Map<Gymnasium, List<Court>> courtMap = updatedState
            .getCollection<Court>()
            .groupListsBy((court) => court.gymnasium);
        updatedState = updatedState.copyWith(courtMap: courtMap);

        emit(updatedState.copyWith(loadingStatus: LoadingStatus.done));
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }
}
