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

    List<MatchParticipant<P>> realParticipants =
        _participants.where((participant) => !participant.isBye).toList();

    List<MatchParticipant<P>> byes =
        _participants.where((participant) => participant.isBye).toList();

    if (realParticipants.length.isOdd) {
      assert(byes.isNotEmpty);
      MatchParticipant<P> paddingParticipant = byes.removeAt(0);
      realParticipants.add(paddingParticipant);
    }

    List<MatchParticipant<P>> ranks = [];

    Iterable<List<MatchParticipant<P>>> pairs =
        realParticipants.slices(2).toList().reversed;

    for (List<MatchParticipant<P>> pair in pairs) {
      ranks.add(pair[1]);
      ranks.insert(0, pair[0]);
    }

    ranks.addAll(byes);

    return ranks;
  }
}
