import 'package:collection/collection.dart';
import 'package:tournament_mode/src/match_participant.dart';
import 'package:tournament_mode/src/ranking.dart';

class ConsolationRanking<P> extends Ranking<P> {
  ConsolationRanking(List<MatchParticipant<P>> participants)
      : _participants = participants;

  final List<MatchParticipant<P>> _participants;

  @override
  List<MatchParticipant<P>> createRanks() {
    int length = _participants.length;

    assert(
      (length & (length - 1)) == 0,
      'The participant list has to have a length that is a power of 2',
    );

    List<MatchParticipant<P>> ranks = [];

    Iterable<List<MatchParticipant<P>>> pairs =
        _participants.slices(2).toList().reversed;

    for (List<MatchParticipant<P>> pair in pairs) {
      ranks.add(pair[1]);
      ranks.insert(0, pair[0]);
    }

    return ranks;
  }
}
