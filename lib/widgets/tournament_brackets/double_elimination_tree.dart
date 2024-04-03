import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/display_strings/match_names.dart';
import 'package:ez_badminton_admin_app/layout/elimination_tree/elimination_tree_layout.dart';
import 'package:ez_badminton_admin_app/widgets/match_label/match_label.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:flutter/material.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'bracket_sizes.dart' as bracket_sizes;

class DoubleEliminationTree extends StatelessWidget
    implements SectionedBracket {
  DoubleEliminationTree({
    super.key,
    required this.tournament,
    required this.competition,
    this.placeholderLabels = const {},
    this.isEditable = false,
    this.showResults = false,
  }) : _sections = getSections(tournament) {
    matchNodeSize =
        SingleEliminationTree.getMatchNodeSize(competition.teamSize);
    layoutSize = _getLayoutSize();
  }

  final BadmintonDoubleElimination tournament;
  final Competition competition;

  final Map<MatchParticipant, Widget> placeholderLabels;

  final bool isEditable;
  final bool showResults;

  late final Size matchNodeSize;
  late final Size layoutSize;

  final List<BracketSection> _sections;
  @override
  List<BracketSection> get sections => _sections;

  @override
  Widget build(BuildContext context) {
    Map<MatchParticipant, Widget> placeholderLabels =
        _createPlaceholderLabels(context);

    SingleEliminationTree winnerBracket = SingleEliminationTree(
      rounds: tournament.winnerBracket.rounds,
      competition: competition,
      isEditable: isEditable,
      showResults: showResults,
      placeholderLabels: this.placeholderLabels,
    );

    List<List<Widget>> matchNodes = [];

    List<EliminationRound<BadmintonMatch>> rounds = tournament.rounds
        .map((round) => round.loserRound)
        .whereType<EliminationRound<BadmintonMatch>>()
        .toList();

    rounds.add(tournament.rounds.last.winnerRound!);

    for (EliminationRound<BadmintonMatch> round in rounds) {
      List<Widget> roundMatchNodes = round.matches.map((match) {
        Widget matchCard = MatchupCard(
          match: match,
          showResult: showResults,
          width: matchNodeSize.width,
          placeholderLabels: placeholderLabels,
        );

        return matchCard;
      }).toList();

      matchNodes.add(roundMatchNodes);
    }

    return DoubleEliminationTreeLayout(
      winnerBracket: winnerBracket,
      winnerBracketSize: winnerBracket.layoutSize,
      matchNodes: matchNodes,
      layoutSize: layoutSize,
      matchNodeSize: matchNodeSize,
    );
  }

  Size _getLayoutSize() {
    int numRounds = tournament.rounds.length - 1;
    int firstRoundSize = tournament.rounds[1].loserRound!.length;

    return Size(
      numRounds * matchNodeSize.width +
          (numRounds - 1) * bracket_sizes.singleEliminationRoundGap,
      firstRoundSize * matchNodeSize.height +
          matchNodeSize.height * bracket_sizes.relativeIntakeRoundOffset,
    );
  }

  Map<MatchParticipant, Widget> _createPlaceholderLabels(
    BuildContext context,
  ) {
    var l10n = AppLocalizations.of(context)!;

    TextStyle placeholderStyle =
        TextStyle(color: Theme.of(context).disabledColor);

    Iterable<MatchParticipant> loserParticipants =
        tournament.matches.expand((match) => [match.a, match.b]).where(
              (participant) =>
                  participant.placement?.ranking is WinnerRanking &&
                  participant.placement?.place == 1,
            );

    Map<MatchParticipant, Widget> participantLabels = {};

    for (MatchParticipant loser in loserParticipants) {
      BadmintonMatch lostMatch =
          (loser.placement!.ranking as WinnerRanking).match as BadmintonMatch;

      String matchName = (lostMatch.round as DoubleEliminationRound)
          .getDoubleEliminationMatchName(l10n, lostMatch);

      Widget label = Text(
        l10n.loserOfMatch(matchName),
        style: placeholderStyle,
      );

      participantLabels.putIfAbsent(loser, () => label);
    }

    return participantLabels;
  }

  static List<BracketSection> getSections(
    BadmintonDoubleElimination tournament,
  ) {
    List<BracketSection> sections =
        SingleEliminationTree.getSections(tournament.winnerBracket.rounds);

    BracketSection upperFinalSection = sections.removeLast();
    upperFinalSection = BracketSection(
      tournamentDataObjects: upperFinalSection.tournamentDataObjects,
      labelBuilder: (context) => AppLocalizations.of(context)!.upperFinal,
    );

    BadmintonMatch finalMatch = tournament.matches.last;

    BracketSection finalSection = BracketSection(
      tournamentDataObjects: [finalMatch],
      labelBuilder: (context) => AppLocalizations.of(context)!.roundOfN('2'),
    );

    sections.add(upperFinalSection);
    sections.add(finalSection);

    return sections;
  }
}
