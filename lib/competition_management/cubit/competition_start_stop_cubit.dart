import 'package:collection/collection.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:formz/formz.dart';

import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';

part 'competition_start_stop_state.dart';

class CompetitionStartStopCubit
    extends CollectionQuerierCubit<CompetitionStartStopState> with DialogCubit {
  CompetitionStartStopCubit({
    required ModelStore<Competition> competitionRepository,
    required this.startEndpoint,
    required this.stopEndpoint,
  }) : super(
          modelStores: [
            competitionRepository,
          ],
          CompetitionStartStopState(),
        );

  final TournamentStartEndpoint startEndpoint;
  final TournamentStopEndpoint stopEndpoint;

  void competitionsStarted([List<Competition>? competitions]) async {
    competitions = competitions ?? state.selectedCompetitions;

    if (state.formStatus == FormzSubmissionStatus.inProgress ||
        !_areCompetitionsStartable(competitions)) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    bool userConfirmation = (await requestDialogChoice<bool>())!;
    if (!userConfirmation) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.canceled));
      return;
    }

    Iterable<Future<FormzSubmissionStatus>> competitionStarts =
        competitions.map(_startCompetition);
    List<FormzSubmissionStatus> starts = await Future.wait(competitionStarts);
    if (starts.contains(FormzSubmissionStatus.failure)) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  void competitionCanceled(Competition competition) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    assert(competition.matches.isNotEmpty);

    bool userConfirmation =
        (await requestDialogChoice<bool>(reason: competition))!;
    if (!userConfirmation) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.canceled));
      return;
    }

    var status = await _stopCompetition(competition);

    emit(state.copyWith(formStatus: status));
  }

  Future<FormzSubmissionStatus> _startCompetition(
    Competition competition,
  ) async {
    try {
      await startEndpoint.post(
        pathParams: {
          "competition": competition.id,
        },
      );
    } catch (e) {
      return FormzSubmissionStatus.failure;
    }
    return FormzSubmissionStatus.success;
  }

  Future<FormzSubmissionStatus> _stopCompetition(
    Competition competition,
  ) async {
    try {
      await stopEndpoint.post(
        pathParams: {
          "competition": competition.id,
        },
      );
    } catch (e) {
      return FormzSubmissionStatus.failure;
    }
    return FormzSubmissionStatus.success;
  }

  void selectedCompetitionsChanged(List<Competition> selection) {
    emit(state.copyWith(
      selectedCompetitions: selection,
      selectionIsStartable: _areCompetitionsStartable(selection),
    ));
  }

  static bool _areCompetitionsStartable(List<Competition> competitions) {
    return competitions.firstWhereOrNull(
          (c) => c.draw.isEmpty || c.matches.isNotEmpty,
        ) ==
        null;
  }

  @override
  void onCollectionUpdate(List<List<Model>> collections,
          CollectionUpdateEvent<Model>? updateEvent) =>
      {};
}
