import 'package:model_repository/model_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String roundName(AppLocalizations l10n, ScheduledRound round) {
  var tournament = round.competition.tournamentPlan!.tournament;
  int roundI = round.roundIndex;
  return roundNameByIndex(l10n, tournament, roundI);
}

String roundNameByIndex(
  AppLocalizations l10n,
  Tournament tournament,
  int roundI,
) {
  switch (tournament) {
    case RoundRobin _:
      return l10n.roundN(roundI + 1);
    case SingleElimination t:
      var tRound = t.rounds[roundI];
      return l10n.roundOfN((tRound.length * 2).toString());
    case SingleEliminationWithConsolation t:
      var tRound = t.mainBracket.rounds[roundI];
      return l10n.roundOfN((tRound.length * 2).toString());
    case DoubleElimination t:
      if (roundI == t.rounds.length - 1) {
        return l10n.roundOfN("2");
      }
      if (roundI == t.rounds.length - 2) {
        return l10n.upperFinal;
      }
      switch (roundI) {
        case int(isEven: true):
          var tRound = t.winnerRounds[roundI ~/ 2];
          return l10n.roundOfN((tRound.length * 2).toString());
        case int(isEven: false):
          var tRound = t.loserRounds[roundI];
          String baseRound = l10n.roundOfN((tRound.length * 2).toString());
          return l10n.loserRoundN(baseRound);
      }
      return "";
    case GroupKnockout t:
      int numGroupRounds = t.groupPhase.groups.last.rounds.length;
      if (roundI <= numGroupRounds - 1) {
        String baseRound = l10n.roundN((roundI + 1));
        return l10n.groupPhaseRoundN(baseRound);
      } else {
        int koRoundIndex = roundI - numGroupRounds;
        return roundNameByIndex(l10n, t.knockoutPhase, koRoundIndex);
      }
  }
}
