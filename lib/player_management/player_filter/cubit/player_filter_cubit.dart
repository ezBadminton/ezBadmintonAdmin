import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/predicate_filter/common_predicate_producers/agegroup_predicate_producer.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_consumer_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_consumer_state.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/predicate_consumer.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:meta/meta.dart';

part 'player_filter_state.dart';

class PlayerFilterCubit extends CollectionFetcherCubit<PlayerFilterState>
    with PredicateConsumer
    implements PredicateConsumerCubit<PlayerFilterState> {
  PlayerFilterCubit({
    required CollectionRepository<PlayingLevel> playingLevelRepository,
    required CollectionRepository<AgeGroup> ageGroupRepository,
    required AgeGroupPredicateProducer ageGroupPredicateProducer,
    required PlayingLevelPredicateProducer playingLevelPredicateProducer,
    required GenderCategoryPredicateProducer genderPredicateProducer,
    required CompetitionTypePredicateProducer competitionTypePredicateProducer,
    required StatusPredicateProducer statusPredicateProducer,
    required SearchPredicateProducer searchPredicateProducer,
  }) : super(
          const PlayerFilterState(),
          collectionRepositories: [
            playingLevelRepository,
            ageGroupRepository,
          ],
        ) {
    initPredicateProducers([
      ageGroupPredicateProducer,
      genderPredicateProducer,
      playingLevelPredicateProducer,
      competitionTypePredicateProducer,
      statusPredicateProducer,
      searchPredicateProducer,
    ]);
    loadCollections();
    subscribeToCollectionUpdates(
      ageGroupRepository,
      (_) => loadCollections(),
    );
    subscribeToCollectionUpdates(
      playingLevelRepository,
      (_) => loadCollections(),
    );
  }

  @override
  void onPredicateProduced(FilterPredicate predicate) {
    emit(state.copyWithPredicate(filterPredicate: predicate));
  }

  void loadCollections() async {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<PlayingLevel>(),
        collectionFetcher<AgeGroup>(),
      ],
      onSuccess: (updatedState) {
        emit(updatedState.copyWith(loadingStatus: LoadingStatus.done));
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

  @override
  Future<void> close() async {
    await closeProducerStreams();
    return super.close();
  }
}
