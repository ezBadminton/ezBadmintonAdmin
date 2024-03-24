import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_filter/competition_filter.dart';
import 'package:ez_badminton_admin_app/utils/sorting.dart';
import 'package:ez_badminton_admin_app/predicate_filter/common_predicate_producers/agegroup_predicate_producer.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_consumer_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_consumer_state.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/predicate_consumer.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'competition_filter_state.dart';

class CompetitionFilterCubit
    extends CollectionQuerierCubit<CompetitionFilterState>
    with PredicateConsumer
    implements PredicateConsumerCubit<CompetitionFilterState> {
  CompetitionFilterCubit({
    required CollectionRepository<AgeGroup> ageGroupRepository,
    required CollectionRepository<PlayingLevel> playingLevelRepository,
    required CollectionRepository<Tournament> tournamentRepository,
    required AgeGroupPredicateProducer ageGroupPredicateProducer,
    required PlayingLevelPredicateProducer playingLevelPredicateProducer,
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
  }

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>> updateEvents,
  ) {
    CompetitionFilterState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    List<AgeGroup> sortedAgeGroups =
        updatedState.getCollection<AgeGroup>().sorted(compareAgeGroups);
    List<PlayingLevel> sortedPlayingLevels =
        updatedState.getCollection<PlayingLevel>().sorted(comparePlayingLevels);
    updatedState.overrideCollection(sortedAgeGroups);
    updatedState.overrideCollection(sortedPlayingLevels);

    emit(updatedState);
  }

  @override
  void onPredicateProduced(FilterPredicate predicate) {
    emit(state.copyWithPredicate(filterPredicate: predicate));
  }
}
