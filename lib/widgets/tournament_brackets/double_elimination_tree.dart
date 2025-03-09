import 'package:ez_badminton_admin_app/layout/elimination_tree/elimination_tree_layout.dart';
import 'package:ez_badminton_admin_app/widgets/match_label/match_label.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:model_repository/model_repository.dart';
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

  final DoubleElimination tournament;
  final Competition competition;

  final Map<Slot, Widget> placeholderLabels;

  final bool isEditable;
  final bool showResults;

  late final Size matchNodeSize;
  late final Size layoutSize;

  final List<BracketSection> _sections;
  @override
  List<BracketSection> get sections => _sections;

  @override
  Widget build(BuildContext context) {
    Map<Slot, Widget> placeholderLabels = _createPlaceholderLabels(context);

    SingleEliminationTree winnerBracket = SingleEliminationTree(
      tournament: tournament,
      rounds: tournament.winnerRounds,
      competition: competition,
      isEditable: isEditable,
      showResults: showResults,
      placeholderLabels: this.placeholderLabels,
    );

    List<List<Widget>> matchNodes = [];

    List<List<TournamentMatch>> rounds = tournament.loserRounds;
    rounds.add([tournament.finalMatch]);

    for (List<TournamentMatch> round in rounds) {
      List<Widget> roundMatchNodes = round.map((match) {
        Widget matchCard = MatchupCard(
          tournament: tournament,
          match: match,
          competition: competition,
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
    int numRounds = tournament.loserRounds.length;
    int firstRoundSize = tournament.loserRounds.first.length;

    return Size(
      numRounds * matchNodeSize.width +
          (numRounds - 1) * bracket_sizes.singleEliminationRoundGap,
      firstRoundSize * matchNodeSize.height +
          matchNodeSize.height * bracket_sizes.relativeIntakeRoundOffset,
    );
  }

  Map<Slot, Widget> _createPlaceholderLabels(
    BuildContext context,
  ) {
    var l10n = AppLocalizations.of(context)!;

    Map<Slot, String> labelTexts = createPlaceholderLabels(tournament, l10n);

    Map<Slot, Widget> labels = wrapPlaceholderLabels(
      context,
      labelTexts,
    );

    return labels;
  }

  static Map<Slot, String> createPlaceholderLabels(
    DoubleElimination tournament,
    AppLocalizations l10n,
  ) {
    return <Slot, String>{};
    // TODO
    /*
    Iterable<Slot> loserParticipants =
        tournament.matches.expand((match) => [match.a, match.b]).where(
              (participant) =>
                  participant.placement?.ranking is WinnerRanking &&
                  participant.placement?.place == 1,
            );

    Map<Slot, String> participantLabels = {};

    for (Slot loser in loserParticipants) {
      BadmintonMatch lostMatch =
          (loser.placement!.ranking as WinnerRanking).match as BadmintonMatch;

      String matchName = (lostMatch.round as DoubleEliminationRound)
          .getDoubleEliminationMatchName(l10n, lostMatch);

      participantLabels.putIfAbsent(loser, () => l10n.loserOfMatch(matchName));
    }

    return participantLabels;
    */
  }

  static List<BracketSection> getSections(
    DoubleElimination tournament,
  ) {
    List<BracketSection> sections =
        SingleEliminationTree.getSections(tournament.winnerRounds);

    BracketSection upperFinalSection = sections.removeLast();
    upperFinalSection = BracketSection(
      tournamentDataObjects: upperFinalSection.tournamentDataObjects,
      labelBuilder: (context) => AppLocalizations.of(context)!.upperFinal,
    );

    TournamentMatch finalMatch = tournament.finalMatch;

    BracketSection finalSection = BracketSection(
      tournamentDataObjects: [finalMatch],
      labelBuilder: (context) => AppLocalizations.of(context)!.roundOfN('2'),
    );

    sections.add(upperFinalSection);
    sections.add(finalSection);

    return sections;
  }
}
