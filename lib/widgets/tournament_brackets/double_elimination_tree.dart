import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/layout/elimination_tree/elimination_tree_layout.dart';
import 'package:ez_badminton_admin_app/widgets/match_label/match_label.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/utils.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:flutter/material.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'package:model_repository/model_repository.dart';
import 'bracket_sizes.dart' as bracket_sizes;

class DoubleEliminationTree extends StatelessWidget
    implements SectionedBracket {
  const DoubleEliminationTree({
    super.key,
    this.placeholderLabels = const {},
    this.sections = const [],
    this.onDragAndDrop,
    this.showResults = false,
  });

  final Map<Slot, Widget> placeholderLabels;

  final void Function(Team a, Team b)? onDragAndDrop;
  final bool showResults;

  @override
  final List<BracketSection> sections;

  @override
  Widget build(BuildContext context) {
    var tPlan = context.readTournamentPlan();
    var tournament = context.readTournament() as DoubleElimination;
    var competition = tPlan.competition;

    var matchNodeSize =
        SingleEliminationTree.getMatchNodeSize(competition.teamSize);
    var layoutSize = _getLayoutSize(tournament, matchNodeSize);

    Map<Slot, Widget> placeholderLabels =
        _createPlaceholderLabels(context, tournament);

    SingleEliminationTree winnerBracket = SingleEliminationTree(
      rounds: tournament.winnerRounds,
      onDragAndDrop: onDragAndDrop,
      showResults: showResults,
      placeholderLabels: this.placeholderLabels,
    );

    List<List<Widget>> matchNodes = [];

    List<List<TournamentMatch>> rounds = tournament.loserRounds;
    rounds.add([tournament.finalMatch]);

    for (List<TournamentMatch> round in rounds) {
      List<Widget> roundMatchNodes = round.map((match) {
        Widget matchCard = MatchContextSubtree(
          key: ValueKey('DoubleEliminationMatch-${match.id}'),
          match: match,
          child: MatchupCard(
            showResult: showResults,
            width: matchNodeSize.width,
            placeholderLabels: placeholderLabels,
          ),
        );

        return matchCard;
      }).toList();

      matchNodes.add(roundMatchNodes);
    }

    return DoubleEliminationTreeLayout(
      winnerBracket: winnerBracket,
      winnerBracketSize: SingleEliminationTree.getLayoutSize(
        tournament.winnerRounds,
        matchNodeSize,
      ),
      matchNodes: matchNodes,
      layoutSize: layoutSize,
      matchNodeSize: matchNodeSize,
    );
  }

  Size _getLayoutSize(DoubleElimination tournament, Size matchNodeSize) {
    int numRounds = tournament.loserRounds.length + 1;
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
    DoubleElimination tournament,
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
    List<TournamentMatch> firstRound = tournament.winnerRounds.first;
    List<TournamentMatch> firstLoserRound = tournament.loserRounds.first;

    String firstRoundName = l10n.roundOfN((firstRound.length * 2).toString());

    Iterable<Slot> firstLoserSlots = firstLoserRound
        .expand((m) => [m.slot1, m.slot2])
        .where((s) => !s.isBye);

    Map<Slot, String> participantLabels = {};
    for (final (i, slot) in firstLoserSlots.indexed) {
      String label = l10n.loserOfMatch('$firstRoundName ${i + 1}');
      participantLabels[slot] = label;
    }

    Iterable<List<TournamentMatch>> majorLoserRounds =
        tournament.loserRounds.whereIndexed((i, _) => i.isOdd);

    for (final (i, round) in majorLoserRounds.indexed) {
      Iterable<Slot> loserSlots = round.map((m) => m.slot1);
      if (i.isEven) {
        // Swap halves
        int halfLength = loserSlots.length ~/ 2;
        loserSlots =
            loserSlots.skip(halfLength).followedBy(loserSlots.take(halfLength));
      }
      String parentRoundName;
      if (round.length == 1) {
        parentRoundName = l10n.smallFinal;
      } else {
        parentRoundName = l10n.roundOfN((round.length * 2).toString());
      }
      for (final (i, slot) in loserSlots.indexed) {
        String label;
        if (round.length == 1) {
          label = l10n.loserOfMatch(parentRoundName);
        } else {
          label = l10n.loserOfMatch('$parentRoundName ${i + 1}');
        }
        participantLabels[slot] = label;
      }
    }

    return participantLabels;
  }

  static List<BracketSection> getSections(
    DoubleElimination tournament,
  ) {
    List<BracketSection> sections =
        SingleEliminationTree.getSections(tournament.winnerRounds);

    BracketSection upperFinalSection = sections.removeLast();
    upperFinalSection = BracketSection(
      tournamentDataObjects: upperFinalSection.tournamentDataObjects,
      labelBuilder: (context) => AppLocalizations.of(context)!.smallFinal,
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
