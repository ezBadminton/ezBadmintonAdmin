import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension EliminationRoundNames on EliminationRound {
  String getEliminationRoundName(AppLocalizations l10n, BadmintonMatch match) {
    String roundName = l10n.roundOfN('$roundSize');

    if (roundSize == 2) {
      // Final needs no round number
      return roundName;
    }

    int roundIndex = matches.indexOf(match);

    return l10n.roundN(roundName, '${roundIndex + 1}');
  }
}

extension RoundRobinRoundNames on RoundRobinRound {
  String getRoundRobinRoundName(AppLocalizations l10n) {
    return l10n.roundRobinMatchN(roundNumber + 1);
  }
}

extension GroupPhaseRoundNames on GroupPhaseRound<BadmintonMatch> {
  String getGroupRoundName(AppLocalizations l10n, BadmintonMatch match) {
    RoundRobinRound<BadmintonMatch> groupRound = nestedRounds.firstWhere(
      (roundRobin) => roundRobin.matches.contains(match),
    );

    int groupNumber = nestedRounds.indexOf(groupRound);

    return l10n.groupNMatchN(groupNumber + 1, roundNumber + 1);
  }
}

extension DoubleEliminationRoundNames on DoubleEliminationRound {
  String getDoubleEliminationRoundName(
    AppLocalizations l10n,
    BadmintonMatch match,
  ) {
    bool isInWinnerBracket = winnerRound?.matches.contains(match) ?? false;

    if (isInWinnerBracket) {
      bool isUpperFinal =
          winnerRound!.roundSize == 2 && this.loserRound != null;

      if (isUpperFinal) {
        return l10n.upperFinal;
      }

      return winnerRound!.getEliminationRoundName(l10n, match);
    }

    EliminationRound loserRound = this.loserRound!;

    String losersBracket = l10n.losersBracket;
    String roundName = l10n.roundOfN('${loserRound.roundSize}');

    int loserBracketRoundStage = winnerRound != null ? 1 : 2;

    String roundNumber;
    if (loserRound.roundSize == 2) {
      roundNumber = '$loserBracketRoundStage';
    } else {
      int matchIndex = loserRound.matches.indexOf(match);

      roundNumber = '$loserBracketRoundStage.${matchIndex + 1}';
    }

    return '$losersBracket\n$roundName $roundNumber';
  }
}
