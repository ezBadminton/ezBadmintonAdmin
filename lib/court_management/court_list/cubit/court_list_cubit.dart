import 'package:collection/collection.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/court_management/court_list/utils/numbered_string.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'court_list_state.dart';

class CourtListCubit extends CollectionQuerierCubit<CourtListState> {
  CourtListCubit({
    required ModelStore<Court> courtRepository,
    required ModelStore<Gymnasium> gymnasiumRepository,
  }) : super(
          modelStores: [
            courtRepository,
            gymnasiumRepository,
          ],
          CourtListState(),
        );

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>>? updateEvents,
  ) {
    CourtListState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    List<Gymnasium> gymnasiums = updatedState
        .getCollection<Gymnasium>()
        .sortedBy((g) => NumberedString(g.name));
    List<Court> courts = updatedState.getCollection<Court>();

    Map<Gymnasium, List<Court>> courtMap = {
      for (Gymnasium gymnasium in gymnasiums)
        gymnasium: courts
            .where((c) => c.gymnasium == gymnasium)
            .sortedBy((c) => NumberedString(c.name)),
    };
    updatedState = updatedState.copyWith(courtMap: courtMap);

    emit(updatedState);
  }
}
