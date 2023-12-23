import 'package:collection/collection.dart';
import 'package:tournament_mode/tournament_mode.dart';

/// A ranking for [SingleElimination] modes that causes the first round to have
/// the given participants matched in order.
///
/// The ranking effectively neutralises the seeding mechanic of the
/// [SingleElimination].
///
/// For example with a list of 4 participants, the matches would be
/// * index 0 - index 1
/// * index 2 - index 3
///
/// Any bye participants are placed so that the real players meet as late as
/// possible in the tournament.
class OrderedRanking<P> extends Ranking<P> {
  /// Creates an [OrderedRanking] out of the [participants].
  ///
  /// The length of the [participants] list has to be a power of 2.
  OrderedRanking(List<MatchParticipant<P>> participants)
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
