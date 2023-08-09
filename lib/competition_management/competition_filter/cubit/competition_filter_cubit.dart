import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_filter/competition_filter.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_consumer_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_consumer_state.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/predicate_consumer.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'competition_filter_state.dart';

class CompetitionFilterCubit
    extends CollectionFetcherCubit<CompetitionFilterState>
    with PredicateConsumer
    implements PredicateConsumerCubit<CompetitionFilterState> {
  CompetitionFilterCubit({
    required CollectionRepository<AgeGroup> ageGroupRepository,
    required CollectionRepository<PlayingLevel> playingLevelRepository,
    required CollectionRepository<Tournament> tournamentRepository,
    required AgeGroupPredicateProducer ageGroupPredicateProducer,
    required PlayingLevelPredicateProducer<Competition>
        playingLevelPredicateProducer,
    required RegistrationCountPredicateProducer
        registrationCountPredicateProducer,
    required CompetitionTypePredicateProducer competitionTypePredicateProducer,
    required GenderCategoryPredicateProducer genderCategoryPredicateProducer,
  }) : super(
          collectionRepositories: [
            ageGroupRepository,
            playingLevelRepository,
            tournamentRepository,
          ],
          CompetitionFilterState(),
        ) {
    initPredicateProducers([
      ageGroupPredicateProducer,
      playingLevelPredicateProducer,
      registrationCountPredicateProducer,
      competitionTypePredicateProducer,
      genderCategoryPredicateProducer,
    ]);
    loadCollections();
    subscribeToCollectionUpdates(
      tournamentRepository,
      (_) => loadCollections(),
    );
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

  void loadCollections() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<AgeGroup>(),
        collectionFetcher<PlayingLevel>(),
        collectionFetcher<Tournament>(),
      ],
      onSuccess: (updatedState) {
        emit(updatedState.copyWith(loadingStatus: LoadingStatus.done));
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }
}
