import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:formz/formz.dart';
import 'package:model_repository/model_repository.dart';

part 'starting_fee_editing_state.dart';

/// This cubit controls the setting of the starting fee in the competitions
class StartingFeeEditingCubit
    extends CollectionQuerierCubit<StartingFeeEditingState> {
  StartingFeeEditingCubit({
    required List<Competition> competitions,
    required ModelStore<Competition> competitionStore,
    required this.startingFeeEndpoint,
  }) : super(
          modelStores: [competitionStore],
          StartingFeeEditingState(competitions: competitions),
        ) {
    subscribeToCollectionUpdates(
      competitionStore,
      _onCompetitionCollectionUpdate,
    );
  }

  final StartingFeeEndpoint startingFeeEndpoint;

  void feeAmountChanged(int amount) {
    final inProgress = state.formStatus == FormzSubmissionStatus.inProgress;
    if (inProgress) {
      return;
    }
    emit(state.copyWith(amount: amount));
  }

  void startingFeeSubmitted() async {
    final inProgress = state.formStatus == FormzSubmissionStatus.inProgress;
    final noCompetitions = state.competitions.isEmpty;
    if (inProgress || noCompetitions) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    final body = <String, dynamic>{
      "startingFee": state.amount,
      "competitions":
          state.competitions.map((competition) => competition.id).toList(),
    };
    try {
      await startingFeeEndpoint.post(body: body);
    } catch (_) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  void _onCompetitionCollectionUpdate(
    List<CollectionUpdateEvent<Competition>> updates,
  ) {
    List<Competition> updatedCompetitions = List.of(state.competitions);
    bool didUpdate = false;
    for (CollectionUpdateEvent<Competition> update in updates) {
      switch (update.updateType) {
        case UpdateType.delete:
          final didRemove = updatedCompetitions.remove(update.model);
          didUpdate = didUpdate || didRemove;
        case UpdateType.create:
        case UpdateType.update:
          continue;
      }
    }
    if (didUpdate) {
      emit(state.copyWith(competitions: updatedCompetitions));
    }
  }

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>>? updateEvents,
  ) {}
}
