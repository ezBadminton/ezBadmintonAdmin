import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'court_list_state.dart';

class CourtListCubit extends CollectionFetcherCubit<CourtListState> {
  CourtListCubit({
    required CollectionRepository<Court> courtRepository,
    required CollectionRepository<Gymnasium> gymnasiumRepository,
  }) : super(
          collectionRepositories: [
            courtRepository,
            gymnasiumRepository,
          ],
          CourtListState(),
        ) {
    loadCollections();
    subscribeToCollectionUpdates(
      courtRepository,
      (_) => loadCollections(),
    );
    subscribeToCollectionUpdates(
      gymnasiumRepository,
      (_) => loadCollections(),
    );
  }

  void loadCollections() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Court>(),
        collectionFetcher<Gymnasium>(),
      ],
      onSuccess: (updatedState) {
        List<Gymnasium> gymnasiums = updatedState.getCollection<Gymnasium>();
        List<Court> courts = updatedState.getCollection<Court>();
        Map<Gymnasium, List<Court>> courtMap = {
          for (Gymnasium gymnasium in gymnasiums)
            gymnasium: courts.where((c) => c.gymnasium == gymnasium).toList(),
        };
        updatedState = updatedState.copyWith(courtMap: courtMap);

        emit(updatedState.copyWith(loadingStatus: LoadingStatus.done));
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }
}
