import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension EliminationRoundNames on EliminationRound {
  String getEliminationRoundName(AppLocalizations l10n) {
    return l10n.roundOfN('$roundSize');
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
