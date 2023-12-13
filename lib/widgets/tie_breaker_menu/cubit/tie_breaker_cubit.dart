import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/utils/list_extension/list_extension.dart';
import 'package:formz/formz.dart';

part 'tie_breaker_state.dart';

class TieBreakerCubit extends CollectionQuerierCubit<TieBreakerState> {
  TieBreakerCubit({
    required this.competition,
    required List<Team> tie,
    required CollectionRepository<Competition> competitionRepository,
    required CollectionRepository<TieBreaker> tieBreakerRepository,
  }) : super(
          collectionRepositories: [
            competitionRepository,
            tieBreakerRepository,
          ],
          TieBreakerState(tie: tie),
        );

  final Competition competition;

  void tieReordered(int from, int to) {
    List<Team> reorderedTie = state.tie.moveItem(from, to);

    emit(state.copyWith(tie: reorderedTie));
  }

  void tieBreakerSubmitted() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    TieBreaker tieBreaker = TieBreaker.newTiebreaker(state.tie);

    TieBreaker? newTieBreaker = await querier.createModel(tieBreaker);
    if (newTieBreaker == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    List<TieBreaker> competitionTieBreakers = List.of(competition.tieBreakers)
      ..add(newTieBreaker);

    Competition competitioWithNewTieBreaker =
        competition.copyWith(tieBreakers: competitionTieBreakers);

    Competition? updatedCompetition =
        await querier.updateModel(competitioWithNewTieBreaker);
    if (updatedCompetition == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }
}
