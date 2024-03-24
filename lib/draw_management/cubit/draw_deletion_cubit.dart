import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:formz/formz.dart';

part 'draw_deletion_state.dart';

class DrawDeletionCubit extends CollectionQuerierCubit<DrawDeletionState> {
  DrawDeletionCubit({
    required Competition competition,
    required CollectionRepository<Competition> competitionRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
          ],
          DrawDeletionState(competition: competition),
        ) {
    subscribeToCollectionUpdates(
      competitionRepository,
      _onCompetitionCollectionUpdate,
    );
  }

  void deleteDraw() async {
    if (state.competition.draw.isEmpty) {
      return;
    }

    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    Competition competitionWithoutDraw = state.competition.copyWith(draw: []);

    Competition? updatedCompetition =
        await querier.updateModel(competitionWithoutDraw);

    if (updatedCompetition == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  void _onCompetitionCollectionUpdate(
    List<CollectionUpdateEvent<Competition>> events,
  ) {
    CollectionUpdateEvent<Competition>? updateEvent =
        events.reversed.firstWhereOrNull((e) => e.model == state.competition);

    if (updateEvent == null) {
      return;
    }

    emit(state.copyWith(competition: updateEvent.model));
  }

  @override
  void onCollectionUpdate(List<List<Model>> collections,
      List<CollectionUpdateEvent<Model>> updateEvents) {}
}
