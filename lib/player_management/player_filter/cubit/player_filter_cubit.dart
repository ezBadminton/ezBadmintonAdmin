import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/predicate_consumer.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:meta/meta.dart';

part 'player_filter_state.dart';

class PlayerFilterCubit extends CollectionQuerierCubit<PlayerFilterState>
    with PredicateConsumer {
  PlayerFilterCubit({
    required CollectionRepository<PlayingLevel> playingLevelRepository,
    required AgePredicateProducer agePredicateProducer,
    required GenderPredicateProducer genderPredicateProducer,
    required PlayingLevelPredicateProducer playingLevelPredicateProducer,
    required CompetitionTypePredicateProducer competitionTypePredicateProducer,
    required StatusPredicateProducer statusPredicateProducer,
    required SearchPredicateProducer searchPredicateProducer,
  }) : super(
          const PlayerFilterState(),
          collectionRepositories: [playingLevelRepository],
        ) {
    initPredicateProducers([
      agePredicateProducer,
      genderPredicateProducer,
      playingLevelPredicateProducer,
      competitionTypePredicateProducer,
      statusPredicateProducer,
      searchPredicateProducer,
    ]);
    loadPlayingLevels();
  }

  @override
  void onPredicateProduced(FilterPredicate predicate) {
    emit(state.copyWithPredicate(filterPredicate: predicate));
  }

  void loadPlayingLevels() async {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    var playingLevels = await querier.fetchCollection<PlayingLevel>();
    if (playingLevels == null) {
      emit(state.copyWith(loadingStatus: LoadingStatus.failed));
    } else {
      emit(state.copyWith(
        loadingStatus: LoadingStatus.done,
        allPlayingLevels: playingLevels,
      ));
    }
  }

  @override
  Future<void> close() async {
    await closeProducerStreams();
    return super.close();
  }
}
