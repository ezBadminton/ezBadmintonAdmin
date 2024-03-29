import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:formz/formz.dart';

part 'draw_editing_state.dart';

class DrawEditingCubit extends CollectionQuerierCubit<DrawEditingState> {
  DrawEditingCubit({
    required Competition competition,
    required CollectionRepository<Competition> competitionRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
          ],
          DrawEditingState(competition: competition),
        ) {
    subscribeToCollectionUpdates(
      competitionRepository,
      _onCompetitionCollectionUpdate,
    );
  }

  void swapDrawMembers(Team a, Team b) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    List<Team> draw = List.of(state.competition.draw);

    int indexA = draw.indexOf(a);
    int indexB = draw.indexOf(b);

    draw[indexA] = b;
    draw[indexB] = a;

    Competition competitionWithDraw = state.competition.copyWith(draw: draw);

    Competition? updatedCompetition =
        await querier.updateModel(competitionWithDraw);
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
