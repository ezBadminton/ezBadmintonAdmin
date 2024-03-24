import 'dart:math';

import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/match_management/result_entering/input_validation/score_input_controller.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

part 'result_entering_state.dart';

class ResultEnteringCubit extends CollectionQuerierCubit<ResultEnteringState> {
  ResultEnteringCubit({
    required this.match,
    required this.winningPoints,
    required this.winningSets,
    required int maxPoints,
    required this.twoPointMargin,
    required CollectionRepository<MatchData> matchDataRepository,
    required CollectionRepository<MatchSet> matchSetRepository,
  })  : controllers = _createScoreInputControllers(match, winningSets),
        submitButtonFocusNode = FocusNode(),
        maxPoints = twoPointMargin ? maxPoints : winningPoints,
        super(
          collectionRepositories: [
            matchDataRepository,
            matchSetRepository,
          ],
          const ResultEnteringState(),
        ) {
    if (match.score != null && match.score!.isNotEmpty) {
      _updateWinnerState();
    }
  }

  final BadmintonMatch match;

  final int winningPoints;
  final int winningSets;

  final int maxPoints;
  final bool twoPointMargin;

  int get maxSets => 2 * winningSets - 1;
  int get winningMargin => twoPointMargin ? 2 : 1;

  final List<ScoreInputController> controllers;

  final FocusNode submitButtonFocusNode;
  VoidCallback? _submitButtonFocusRequest;

  void resultSubmitted() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress ||
        state.winningParticipantIndex == null) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    List<(int, int)> setResults = List.generate(
      maxSets,
      (setIndex) => getSetResult(setIndex),
    ).where((setResult) => _isSetResultComplete(setResult)).toList().cast();

    List<int> flatSetResults = setResults.expand((r) => [r.$1, r.$2]).toList();

    Map<String, dynamic> queryParams = {
      "match": match.matchData!.id,
      "endTime": DateTime.now().toUtc(),
    };

    Map<String, List<int>> body = {"results": flatSetResults};

    bool setsCreated = await querier.getRepository<MatchSet>().route(
          method: "PUT",
          query: queryParams,
          data: body,
        );

    if (!setsCreated) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  void scoreChanged(ScoreInputController controller) {
    _updateWinnerState();
  }

  void scoreSubmitted(ScoreInputController controller) {
    String scoreInput = controller.editingController.text;
    if (scoreInput.isEmpty) {
      return;
    }

    ScoreInputController opponentScoreController =
        _getOpponentScoreController(controller);

    int score = int.parse(scoreInput);

    int inferredWinnerScore = min(
      maxPoints,
      max(winningPoints, score + winningMargin),
    );

    if (score < maxPoints) {
      opponentScoreController.editingController.text = '$inferredWinnerScore';

      if (_getNumSetWins(0) > winningSets || _getNumSetWins(1) > winningSets) {
        controller.editingController.text = '';
        opponentScoreController.editingController.text = '';
      }
    }

    _updateWinnerState();

    if (_getMatchWinner() == null) {
      _focusFirstEmptyScoreInput();
    } else {
      _focusSubmitButton();
    }
  }

  void _updateWinnerState() {
    int? winner = _getMatchWinner();
    emit(state.copyWith(
      winningParticipantIndex: SelectionInput.dirty(value: winner),
    ));
  }

  int? _getMatchWinner() {
    List<(int?, int?)> setResults = List.generate(
      maxSets,
      (setIndex) => getSetResult(setIndex),
    );

    int winsA = 0;
    int winsB = 0;
    for ((int?, int?) setResult in setResults) {
      int? winner = getSetWinner(setResult);
      bool partialResult = _isSetResultPartial(setResult);
      if (partialResult && (winsA == winningSets || winsB == winningSets)) {
        // Extra set result despite winner already determined
        return null;
      }
      if (partialResult && winner == null) {
        // Set result that does not determine a winner
        return null;
      }

      if (winner == 0) {
        winsA += 1;
      }
      if (winner == 1) {
        winsB += 1;
      }
    }

    if (winsA == winningSets) {
      return 0;
    }
    if (winsB == winningSets) {
      return 1;
    }
    return null;
  }

  int _getNumSetWins(int participantIndex) {
    List<(int?, int?)> setResults = List.generate(
      maxSets,
      (setIndex) => getSetResult(setIndex),
    );

    return setResults.where((r) => getSetWinner(r) == participantIndex).length;
  }

  int? getSetWinner((int?, int?) result) {
    if (!_isSetResultComplete(result)) {
      return null;
    }

    int scoreA = result.$1!;
    int scoreB = result.$2!;

    int winnerScore = max(scoreA, scoreB);
    int loserScore = min(scoreA, scoreB);

    int scoreDifference = winnerScore - loserScore;

    // Incomplete score (e.g. 20-18)
    if (winnerScore < winningPoints) {
      return null;
    }

    // Winning margin too large (e.g. 24-20)
    if (winnerScore > winningPoints && scoreDifference > winningMargin) {
      return null;
    }

    // Winning margin too small (e.g. 21-20)
    if (winnerScore != maxPoints && scoreDifference < winningMargin) {
      return null;
    }

    if (scoreA > scoreB) {
      return 0;
    }
    if (scoreB > scoreA) {
      return 1;
    }

    // Undecided score (e.g. 30-30)
    return null;
  }

  bool _isSetResultComplete((int?, int?) setResult) {
    return setResult.$1 != null && setResult.$2 != null;
  }

  bool _isSetResultPartial((int?, int?) setResult) {
    return setResult.$1 != null || setResult.$2 != null;
  }

  (int?, int?) getSetResult(int setIndex) {
    return (_getScore(0, setIndex), _getScore(1, setIndex));
  }

  int? _getScore(int participantIndex, int setIndex) {
    TextEditingController? editingController = controllers
        .firstWhereOrNull(
          (c) =>
              c.setIndex == setIndex && c.participantIndex == participantIndex,
        )
        ?.editingController;

    return int.tryParse(editingController?.text ?? '');
  }

  ScoreInputController _getOpponentScoreController(
    ScoreInputController controller,
  ) {
    return controllers.firstWhere(
      (c) =>
          c.setIndex == controller.setIndex &&
          c.participantIndex != controller.participantIndex,
    );
  }

  void _focusSubmitButton() {
    _submitButtonFocusRequest = () {
      if (submitButtonFocusNode.canRequestFocus) {
        if (!_doInputFieldsHaveFocus()) {
          submitButtonFocusNode.requestFocus();
        }
        if (_submitButtonFocusRequest != null) {
          submitButtonFocusNode.removeListener(_submitButtonFocusRequest!);
          _submitButtonFocusRequest = null;
        }
      }
    };
    submitButtonFocusNode.addListener(_submitButtonFocusRequest!);
  }

  void _focusFirstEmptyScoreInput() {
    ScoreInputController? firstEmpty =
        controllers.firstWhereOrNull((c) => c.editingController.text.isEmpty);

    if (firstEmpty == null) {
      return;
    }

    firstEmpty.focusNode.requestFocus();
  }

  bool _doInputFieldsHaveFocus() {
    return controllers.firstWhereOrNull((c) => c.focusNode.hasFocus) != null;
  }

  static List<ScoreInputController> _createScoreInputControllers(
    BadmintonMatch match,
    int winningSets,
  ) {
    List<MatchSet> existingSets = match.score ?? [];
    int maxSets = 2 * winningSets - 1;
    List<ScoreInputController> inputControllers = List.generate(
      maxSets * 2,
      (index) {
        int participantIndex = index % 2;
        int setIndex = index ~/ 2;

        ScoreInputController controller = ScoreInputController(
          participantIndex: index % 2,
          setIndex: index ~/ 2,
        );

        MatchSet? existingSet = existingSets.elementAtOrNull(setIndex);

        if (existingSet != null) {
          int score = participantIndex == 0
              ? existingSet.team1Points
              : existingSet.team2Points;
          controller.editingController.text = '$score';
        }

        return controller;
      },
    );

    return inputControllers;
  }

  @override
  void onCollectionUpdate(List<List<Model>> collections,
      List<CollectionUpdateEvent<Model>> updateEvents) {}
}
