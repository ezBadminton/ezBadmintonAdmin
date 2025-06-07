import 'dart:async';

import 'package:collection/collection.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/utils/sorting.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

part 'competition_selection_state.dart';

class CompetitionSelectionCubit
    extends CollectionQuerierCubit<CompetitionSelectionState> {
  CompetitionSelectionCubit({
    required ModelStore<Competition> competitionStore,
    required ModelStore<TournamentPlan> tPlanStore,
    required this.commandRepository,
    this.cyclingInterval = Duration.zero,
  }) : super(
          modelStores: [
            competitionStore,
            tPlanStore,
          ],
          CompetitionSelectionState(),
        ) {
    subscribeToCollectionUpdates(
      competitionStore,
      _onCompetitionCollectionUpdate,
    );
    _commandSubscription = commandRepository.messageStream.listen(
      (_) => pauseCycle(),
    );
  }

  final RealtimeRepository<InfoscreenCommand> commandRepository;
  late final StreamSubscription _commandSubscription;

  final Duration? cyclingInterval;
  Timer? _timer;

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    CollectionUpdateEvent<Model>? updateEvent,
  ) {
    CompetitionSelectionState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    List<Competition> sortedCompetitions = updatedState
        .getCollection<Competition>()
        .where((competition) => competition.tournamentPlan?.started ?? false)
        .sorted(compareCompetitions);

    updatedState.overrideCollection(sortedCompetitions);

    emit(updatedState);

    if (cyclingInterval != null && _timer == null) {
      cycleCompetition();
    }
  }

  void competitionToggled(Competition competition) {
    Competition? selectedCompetition = competition;
    if (state.selectedCompetition.value == competition) {
      selectedCompetition = null;
    }

    competitionSelected(selectedCompetition);
  }

  void competitionSelected(Competition? selectedCompetition) {
    emit(state.copyWith(
      selectedCompetition: SelectionInput.dirty(value: selectedCompetition),
    ));
    pauseCycle();
  }

  void cycleCompetition() {
    List<Competition> competitions = state.getCollection<Competition>();
    if (competitions.isEmpty) {
      return;
    }

    Competition? current = state.selectedCompetition.value;
    int nextIndex = 0;
    if (current != null) {
      nextIndex = (competitions.indexOf(current) + 1) % competitions.length;
    }
    Competition next = competitions[nextIndex];
    emit(state.copyWith(
      selectedCompetition: SelectionInput.dirty(value: next),
    ));

    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(cyclingInterval!, (_) => cycleCompetition());
    }
  }

  void pauseCycle() {
    if (_timer == null || cyclingInterval == null) {
      return;
    }
    _timer!.cancel();
    _timer = Timer(Duration(seconds: 40), cycleCompetition);
  }

  void _onCompetitionCollectionUpdate(
    CollectionUpdateEvent<Competition>? event,
  ) {
    if (event == null || event.model != state.selectedCompetition.value) {
      return;
    }

    switch (event.updateType) {
      case UpdateType.update:
        emit(state.copyWith(
          selectedCompetition: SelectionInput.dirty(
            value: event.model,
          ),
        ));
        break;
      case UpdateType.delete:
        emit(state.copyWith(
          selectedCompetition: const SelectionInput.dirty(value: null),
        ));
        break;
      case UpdateType.create:
        break;
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _commandSubscription.cancel();
    return super.close();
  }
}
