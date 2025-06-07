import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section_subtree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/sectioned_bracket.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_context/tournament_context.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/interactive_view_blocker_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/bracket_match_label.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/slot_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_scroll_shadow/flutter_scroll_shadow.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'bracket_sizes.dart' as bracket_sizes;

class RoundRobinPlan extends StatelessWidget implements SectionedBracket {
  const RoundRobinPlan({
    super.key,
    this.isEditable = false,
    this.title,
    this.sections = const [],
  });

  final bool isEditable;

  final String? title;

  @override
  final List<BracketSection> sections;

  @override
  bool get navigatable => false;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BracketSectionSubtree(
      tournamentDataObject: context.readTournament(),
      child: Column(
        children: [
          _RoundRobinTable(
            isEditable: isEditable,
            title: title ?? l10n.participant(2),
          ),
          const SizedBox(height: 5),
          _RoundRobinMatchList(),
        ],
      ),
    );
  }
}

class _RoundRobinTable extends StatelessWidget {
  const _RoundRobinTable({
    required this.isEditable,
    this.title,
  });

  final bool isEditable;

  final String? title;

  @override
  Widget build(BuildContext context) {
    double width = bracket_sizes.roundRobinTableWidth;

    var tPlan = context.readTournamentPlan();
    var tournament = context.readTournament();
    var entries = tournament.entries;
    var competition = tPlan.competition;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          if (title != null) ...[
            SizedBox(
              width: width,
              height: 45,
              child: Container(
                alignment: Alignment.center,
                color: Theme.of(context).primaryColor.withOpacity(.45),
                child: Text(
                  title!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: width,
              child: Divider(
                height: 0,
                thickness: 2,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.3),
              ),
            ),
          ],
          for (Team team in entries) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: SlotLabel(
                Slot.fromTeam(team),
                teamSize: competition.teamSize,
                isEditable: isEditable,
                width: width,
                showClub: true,
              ),
            ),
            if (entries.last != team)
              SizedBox(
                width: width,
                child: const Divider(height: 0),
              ),
          ],
        ],
      ),
    );
  }
}

class _RoundRobinMatchList extends StatefulWidget {
  const _RoundRobinMatchList();

  @override
  State<_RoundRobinMatchList> createState() => _RoundRobinMatchListState();
}

class _RoundRobinMatchListState extends State<_RoundRobinMatchList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  bool _isScrollable() {
    if (!_scrollController.hasClients) {
      return false;
    }
    ScrollPosition pos = _scrollController.position;
    return pos.extentTotal > pos.extentInside;
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var interactionBlockerCubit = context.read<InteractiveViewBlockerCubit>();
    double width = bracket_sizes.roundRobinTableWidth;

    var tournament = context.readTournament();

    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.2),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 550),
          child: MouseRegion(
            onEnter: (_) {
              /// Prevent zooming and scrolling at the same time
              if (_isScrollable()) {
                interactionBlockerCubit.addZoomingBlock();
              }
            },
            onExit: (_) => interactionBlockerCubit.removeZoomingBlock(),
            child: ScrollShadow(
              size: 20,
              color: Colors.black.withOpacity(.16),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: tournament.rounds.length,
                prototypeItem: _buildRound(context, 0, l10n),
                shrinkWrap: true,
                itemBuilder: (context, index) => _buildRound(
                  context,
                  index,
                  l10n,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRound(
    BuildContext context,
    int roundIndex,
    AppLocalizations l10n,
  ) {
    var tournament = context.readTournament();
    var rounds = tournament.rounds;
    var round = rounds[roundIndex];
    return Column(
      children: [
        if (roundIndex == 0) const SizedBox(height: 15),
        Text(
          l10n.encounterNumber(roundIndex + 1),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        for (TournamentMatch match in round)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: MatchContextSubtree(
              key: ValueKey('RoundRobinMatch-${match.id}'),
              match: match,
              child: BracketMatchLabel(),
            ),
          ),
        if (roundIndex != rounds.length - 1) const SizedBox(height: 10),
        if (roundIndex == rounds.length - 1) const SizedBox(height: 15),
      ],
    );
  }
}
