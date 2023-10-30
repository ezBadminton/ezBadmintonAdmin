import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/constants.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/widgets.dart';

part 'match_scan_listener_state.dart';

const _inputBufferSize = matchQrPrefix.length;

/// This cubit keeps a buffer of the last few characters that came in via
/// keyboard events and detects certain start and end sequences that enclose
/// the ID of a [MatchData] model.
///
/// Whenever a complete sequence was parsed, the cubit looks up the ID and
/// emits the corresponding [MatchData] object if it exists.
///
/// This is used to enable the functionality of the QR codes on the printed
/// game sheets.
/// The QR code contains a string of this format: `$match:<MatchData ID>$`.
/// The begin sequence is `$match:` and the end sequence is `$`.
/// Now, using a standard scanner device that outputs the scanned data as
/// keyboard strokes, the QR code scan causes the match that the scanned
/// game sheet belongs to, to be emitted by this cubit.
/// The emission causes the match's result input dialog to pop up, making it
/// easy to record the score from the game sheet into the system.
class MatchScanListenerCubit
    extends CollectionFetcherCubit<MatchScanListenerState> {
  MatchScanListenerCubit({
    required CollectionRepository<MatchData> matchDataRepository,
  })  : _inputBuffer = Queue(),
        _parser = MatchScanParser(),
        super(
          collectionRepositories: [
            matchDataRepository,
          ],
          MatchScanListenerState(),
        ) {
    loadCollections();
    subscribeToCollectionUpdates(matchDataRepository, (_) => loadCollections());
  }

  final Queue<String> _inputBuffer;

  final MatchScanParser _parser;

  void loadCollections() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<MatchData>(),
      ],
      onSuccess: (updatedState) {
        emit(updatedState.copyWith(loadingStatus: LoadingStatus.done));
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

  void onKeyEvent(RawKeyEvent event) {
    if (event.character == null) {
      return;
    }

    _appendCharacter(event.character!);
  }

  void _appendCharacter(String character) {
    _inputBuffer.addLast(character);

    while (_inputBuffer.length > _inputBufferSize) {
      _inputBuffer.removeFirst();
    }

    MatchScanToken token = _tokenize();

    _parser.consumeToken(token);

    if (_parser.parsedId != null) {
      _onMatchIdParsed(_parser.parsedId!);
    }
  }

  MatchScanToken _tokenize() {
    String currentInput = _inputBuffer.join();

    MatchScanToken token;

    if (currentInput.endsWith(matchQrPrefix)) {
      token = MatchScanToken.begin();
    } else if (currentInput.endsWith(matchQrSuffix)) {
      token = MatchScanToken.end();
    } else {
      token = MatchScanToken.idCharacter(_inputBuffer.last);
    }

    return token;
  }

  void _onMatchIdParsed(String matchId) {
    if (state.loadingStatus == LoadingStatus.loading) {
      return;
    }

    MatchData? match = state
        .getCollection<MatchData>()
        .firstWhereOrNull((m) => m.id == matchId);

    if (match == null) {
      return;
    }

    emit(state.copyWith(
      scannedMatch: SelectionInput.dirty(value: match),
    ));
  }
}

class MatchScanParser {
  /// Is `true` when in between begin and end token
  bool _isInId = false;

  final StringBuffer _idBuffer = StringBuffer();

  String? _parsedId;

  /// The parsed ID becomes set when the parser cosumed a token sequence of
  /// `<begin>` `<idCharacter>` `<end>`.
  ///
  /// With one or more `<idCharacter>` tokens.
  String? get parsedId => _parsedId;

  void consumeToken(MatchScanToken token) {
    _parsedId = null;

    switch (token.tokenType) {
      case MatchScanTokenType.begin:
        _onBegin();
        break;
      case MatchScanTokenType.end:
        _onEnd();
        break;
      case MatchScanTokenType.idCharacter:
        _onIdChar(token.idCharacter);
        break;
    }
  }

  void _onBegin() {
    _isInId = true;
    _idBuffer.clear();
  }

  void _onEnd() {
    _isInId = false;
    if (_idBuffer.isNotEmpty) {
      _parsedId = _idBuffer.toString();
    }
    _idBuffer.clear();
  }

  void _onIdChar(String char) {
    if (_isInId) {
      _idBuffer.write(char);
    }
  }
}

class MatchScanToken {
  MatchScanToken.idCharacter(
    this.idCharacter,
  ) : tokenType = MatchScanTokenType.idCharacter;

  MatchScanToken.begin()
      : tokenType = MatchScanTokenType.begin,
        idCharacter = '';

  MatchScanToken.end()
      : tokenType = MatchScanTokenType.end,
        idCharacter = '';

  final String idCharacter;

  final MatchScanTokenType tokenType;
}

enum MatchScanTokenType {
  begin,
  idCharacter,
  end,
}
