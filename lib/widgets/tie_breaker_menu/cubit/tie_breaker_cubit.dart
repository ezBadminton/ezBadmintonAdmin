import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/utils/list_extension/list_extension.dart';
import 'package:formz/formz.dart';
import 'package:model_repository/model_repository.dart';

part 'tie_breaker_state.dart';

class TieBreakerCubit extends CollectionQuerierCubit<TieBreakerState> {
  TieBreakerCubit({
    required this.competition,
    required List<Team> tie,
    required ModelStore<Competition> competitionStore,
    required this.addEndpoint,
    required this.updateEndpoint,
  }) : super(
          modelStores: [competitionStore],
          TieBreakerState(
            tieBreaker: _getOrCreateTieBreaker(tie, competition),
          ),
        ) {
    subscribeToCollectionUpdates(competitionStore, handleCompetitionUpdate);
  }

  final AddTieBreakerEndpoint addEndpoint;
  final UpdateTieBreakerEndpoint updateEndpoint;

  final Competition competition;

  void tieReordered(int from, int to) {
    List<Team> currentTie = List.of(state.tiedTeams);
    List<Team> reorderedTie = currentTie.moveItem(from, to);
    TieBreaker updatedTie = state.tieBreaker.copyWith(
      tieBreakerRankingRel: MultiRelation.fromModels(reorderedTie),
    );

    emit(state.copyWith(tieBreaker: SelectionInput.dirty(value: updatedTie)));
  }

  void tieBreakerSubmitted() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    var teamIds = state.tiedTeams.map((t) => t.id).toList();

    if (state.tieBreaker.id.isEmpty) {
      try {
        await addEndpoint.post(
          pathParams: {"competition": competition.id},
          body: {"teams": teamIds},
        );
      } catch (_) {
        emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
        return;
      }
    } else {
      try {
        await updateEndpoint.patch(
          pathParams: {"tiebreaker": state.tieBreaker.id},
          body: {"teams": teamIds},
        );
      } catch (_) {
        emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
        return;
      }
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  void existingTieBreakerDeleted() async {
    if (state.tieBreaker.id.isEmpty) {
      return;
    }

    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    try {
      await updateEndpoint.delete(
        pathParams: {"tiebreaker": state.tieBreaker.id},
      );
      emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
      return;
    }
  }

  static SelectionInput<TieBreaker> _getOrCreateTieBreaker(
    List<Team> tie,
    Competition competition,
  ) {
    TieBreaker? existingTieBreaker = competition.tieBreakers.firstWhereOrNull(
      (tieBreaker) => tieBreaker.tieBreakerRanking.toSet().containsAll(tie),
    );
    TieBreaker tieBreaker = existingTieBreaker ?? TieBreaker.newTiebreaker(tie);

    SelectionInput<TieBreaker> tieBreakerSelection = existingTieBreaker == null
        ? SelectionInput.dirty(value: tieBreaker)
        : SelectionInput.pure(value: tieBreaker);

    return tieBreakerSelection;
  }

  void handleCompetitionUpdate(CollectionUpdateEvent<Competition> event) {
    if (event.model != competition) {
      return;
    }
    emit(state.copyWith(
      tieBreaker: _getOrCreateTieBreaker(state.tiedTeams, competition),
    ));
  }

  @override
  void onCollectionUpdate(List<List<Model>> collections,
      CollectionUpdateEvent<Model>? updateEvent) {}
}
