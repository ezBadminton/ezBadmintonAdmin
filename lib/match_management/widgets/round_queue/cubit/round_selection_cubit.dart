import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/selection.dart';
import 'package:model_repository/model_repository.dart';

part 'round_selection_state.dart';

class RoundSelectionCubit extends CollectionQuerierCubit<RoundSelectionState> {
  RoundSelectionCubit({
    required ModelStore<ScheduledMatch> scheduledMatchStore,
  }) : super(
          modelStores: [scheduledMatchStore],
          RoundSelectionState(),
        );

  setSelectedRound(ScheduledRound round) {
    var waitingMatches = round.matches.where((m) {
      switch (m.status) {
        case ScheduleStatus.courtWait:
        case ScheduleStatus.playerRest:
        case ScheduleStatus.playerWait:
        case ScheduleStatus.wait:
          return true;
        default:
          return false;
      }
    }).toList();

    if (waitingMatches.isEmpty) {
      unsetSelectedRound();
    } else {
      emit(state.copyWith(
        showRound: true,
        roundSelection: SelectionInput.pure(value: round),
        waitingMatches: waitingMatches,
      ));
    }
  }

  unsetSelectedRound() {
    emit(state.copyWith(showRound: false));
    Future.delayed(
      Duration(milliseconds: 150),
      () {
        if (state.showRound) {
          return;
        }
        emit(state.copyWith(
          roundSelection: SelectionInput.pure(emptyAllowed: true),
          waitingMatches: const [],
        ));
      },
    );
  }

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>>? updateEvents,
  ) {
    if (updateEvents == null || state.round == null) {
      return;
    }
    setSelectedRound(state.round!);
  }
}
