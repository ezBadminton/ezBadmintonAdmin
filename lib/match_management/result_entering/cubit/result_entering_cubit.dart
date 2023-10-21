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
    this.winningPoints = 21,
    this.winningSets = 2,
    this.maxPoints = 30,
    this.twoPointMargin = true,
    required CollectionRepository<MatchData> matchDataRepository,
    required CollectionRepository<MatchSet> matchSetRepository,
  })  : controllers = _createScoreInputControllers(winningSets),
        submitButtonFocusNode = FocusNode(),
        super(
          collectionRepositories: [
            matchDataRepository,
            matchSetRepository,
          ],
          const ResultEnteringState(),
        );

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

    List<MatchSet> sets = setResults
        .map((result) => MatchSet.newMatchSet(
              team1Points: result.$1,
              team2Points: result.$2,
            ))
        .toList();

    List<MatchSet?> createdSets = await querier.createModels(sets);
    if (createdSets.contains(null)) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    sets = createdSets.whereType<MatchSet>().toList();

    MatchData matchDataWithSets = match.matchData!.copyWith(
      sets: sets,
      endTime: DateTime.now().toUtc(),
    );

    MatchData? updatedMatchData = await querier.updateModel(matchDataWithSets);
    if (updatedMatchData == null) {
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

    if (winnerScore < winningPoints) {
      return null;
    }

    if (winnerScore == maxPoints && scoreDifference != 1) {
      return null;
    }

    if (scoreDifference < winningMargin && winnerScore != maxPoints) {
      return null;
    }

    if (winnerScore > winningPoints && scoreDifference > winningMargin) {
      return null;
    }

    if (scoreA > scoreB) {
      return 0;
    }
    if (scoreB > scoreA) {
      return 1;
    }

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
    int winningSets,
  ) {
    int maxSets = 2 * winningSets - 1;
    List<ScoreInputController> inputControllers = List.generate(
      maxSets * 2,
      (index) => ScoreInputController(
        participantIndex: index % 2,
        setIndex: index ~/ 2,
      ),
    );

    return inputControllers;
  }
}
