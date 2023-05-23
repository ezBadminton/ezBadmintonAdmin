import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producer/cubit/predicate_producer_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:meta/meta.dart';

part 'player_filter_state.dart';

class PlayerFilterCubit extends PredicateProducerCubit<PlayerFilterState> {
  PlayerFilterCubit({
    required CollectionRepository<PlayingLevel> playingLevelRepository,
    required AgePredicateProducer agePredicateProducer,
    required GenderPredicateProducer genderPredicateProducer,
    required PlayingLevelPredicateProducer playingLevelPredicateProducer,
    required CompetitionTypePredicateProducer competitionTypePredicateProducer,
    required SearchPredicateProducer searchPredicateProducer,
  })  : _playingLevelRepository = playingLevelRepository,
        super(
          producers: [
            agePredicateProducer,
            genderPredicateProducer,
            playingLevelPredicateProducer,
            competitionTypePredicateProducer,
            searchPredicateProducer,
          ],
          const PlayerFilterState(),
        ) {
    loadPlayingLevels();
  }

  final CollectionRepository<PlayingLevel> _playingLevelRepository;

  @override
  void onPredicateProduced(FilterPredicate predicate) {
    emit(state.copyWithPredicate(filterPredicate: predicate));
  }

  void loadPlayingLevels() async {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    try {
      List<PlayingLevel> playingLevels =
          await _playingLevelRepository.getList();
      var newState = state.copyWith(
        allPlayingLevels: playingLevels,
        loadingStatus: LoadingStatus.done,
      );
      emit(newState);
    } on CollectionQueryException {
      emit(state.copyWith(loadingStatus: LoadingStatus.failed));
    }
  }
}
