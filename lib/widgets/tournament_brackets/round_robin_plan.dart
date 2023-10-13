import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/interactive_view_blocker_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/match_label.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/match_participant_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_scroll_shadow/flutter_scroll_shadow.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'bracket_widths.dart' as bracket_widths;

class RoundRobinPlan extends StatelessWidget {
  const RoundRobinPlan({
    super.key,
    required this.tournament,
    required this.competition,
    this.isEditable = false,
    this.title,
  });

  final BadmintonRoundRobin tournament;
  final Competition competition;

  final bool isEditable;

  final String? title;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    List<MatchParticipant<Team>> participants =
        tournament.participants.where((p) => !p.isBye).toList();

    return Column(
      children: [
        _RoundRobinTable(
          participants: participants,
          competition: competition,
          isEditable: isEditable,
          title: title ?? l10n.participant(2),
        ),
        const SizedBox(height: 5),
        _RoundRobinMatchList(
          rounds: tournament.rounds,
          competition: competition,
        ),
      ],
    );
  }
}

class _RoundRobinTable extends StatelessWidget {
  const _RoundRobinTable({
    required this.participants,
    required this.competition,
    required this.isEditable,
    this.title,
  });

  final List<MatchParticipant<Team>> participants;
  final Competition competition;

  final bool isEditable;

  final String? title;

  @override
  Widget build(BuildContext context) {
    double width = bracket_widths.roundRobinTableWidth;

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
          for (MatchParticipant<Team> participant in participants) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: MatchParticipantLabel(
                participant,
                teamSize: competition.teamSize,
                isEditable: isEditable,
                width: width,
                showClub: true,
              ),
            ),
            if (participants.last != participant)
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
  const _RoundRobinMatchList({
    required this.rounds,
    required this.competition,
  });

  final List<RoundRobinRound<BadmintonMatch>> rounds;
  final Competition competition;

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
    double width = bracket_widths.roundRobinTableWidth;

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
                itemCount: widget.rounds.length,
                prototypeItem: _buildRound(widget.rounds.first, l10n),
                shrinkWrap: true,
                itemBuilder: (context, index) => _buildRound(
                  widget.rounds[index],
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
    RoundRobinRound<BadmintonMatch> round,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        if (widget.rounds.first == round) const SizedBox(height: 15),
        Text(
          l10n.encounterNumber(round.roundNumber + 1),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        for (BadmintonMatch match in round.matches)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: MatchLabel(match: match, competition: widget.competition),
          ),
        if (widget.rounds.last != round) const SizedBox(height: 10),
        if (widget.rounds.last == round) const SizedBox(height: 15),
      ],
    );
  }
}
