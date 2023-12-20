import 'package:tournament_mode/tournament_mode.dart';

/// Filter the duplicate ranks of the match rankings.
///
/// Explanatory example: Each elimination round can be ranked independently.
/// The ranking of a semi-final round would look something like this:
///
/// ```console
/// [
///   [semi-winner1, semi-winner2],
///   [semi-loser1, semi-loser2],
/// ]
/// ```
///
/// Now combine that with the ranking of the final and you get this:
///
/// ```console
/// [
///   [final-winner],
///   [final-loser],
///   [semi-winner1, semi-winner2],
///   [semi-loser1, semi-loser2],
/// ]
/// ```
///
/// Since the final participants will be the two semi-winners they are now
/// represented twice in the overall ranking.
///
/// This method removes the duplicates and only keeps the highest rank of
/// each player. The filtered ranking looks like this:
///
/// ```console
/// [
///   [final-winner],
///   [final-loser],
///   [semi-loser1, semi-loser2],
/// ]
/// ```
///
/// This would not be necessary if only a final ranking of the elimination
/// tournament would be needed. In that case all the round winners excpept for
/// the final winner could be omitted from the ranking.
/// But this allows the ranking to show preliminary results before the final
/// has beed played.
List<List<MatchParticipant<P>>> filterHighestRanks<P>(
  List<List<MatchParticipant<P>>> ranks,
) {
  List<P> processedPlayers = [];
  List<List<MatchParticipant<P>>> filteredRanks = [];

  for (List<MatchParticipant<P>> rank in ranks) {
    List<MatchParticipant<P>> filteredRank = rank
        .where(
          (participant) =>
              !processedPlayers.contains(participant.resolvePlayer()),
        )
        .toList();

    processedPlayers.addAll(
      filteredRank.map((participant) => participant.resolvePlayer()!),
    );

    if (filteredRank.isNotEmpty) {
      filteredRanks.add(filteredRank);
    }
  }

  return filteredRanks;
}
