import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/match_start_stop_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/help_tooltip_icon/help_tooltip_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class CallOutScript extends StatelessWidget {
  const CallOutScript({
    super.key,
    required this.callOuts,
    required this.matchStartingCubit,
  });

  final List<BadmintonMatch> callOuts;
  final MatchStartStopCubit matchStartingCubit;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    PageController controller = PageController();

    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(vertical: 20),
      title: Row(
        children: [
          Text(l10n.matchCallOut),
          const SizedBox(width: 7),
          HelpTooltipIcon(helpText: l10n.callOutHelp),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 800,
            height: 250,
            child: PageView.builder(
              controller: controller,
              itemCount: callOuts.length,
              allowImplicitScrolling: false,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _CallOutLines(match: callOuts[index]),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _callOut(context, controller),
                  child: Text(l10n.matchCalledOut),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _callOut(BuildContext context, PageController controller) async {
    NavigatorState navigator = Navigator.of(context);
    double page = controller.page!;
    if (page.truncateToDouble() != page) {
      /// Page view is currently scrolling
      return;
    }
    int pageIndex = page.round();
    await matchStartingCubit.matchStarted(callOuts[pageIndex].matchData!);
    controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutQuad,
    );
    if (pageIndex == callOuts.length - 1) {
      navigator.pop();
    }
  }
}

class _CallOutLines extends StatelessWidget {
  const _CallOutLines({
    required this.match,
  });

  final BadmintonMatch match;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    String? roundName = display_strings.matchName(l10n, match);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CompetitionLabel(competition: match.competition),
        if (roundName != null) Text(roundName, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(.6),
              width: 1,
            ),
            color: Theme.of(context).primaryColor,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: _CallOutTeamLabel(
                      team: match.a.resolvePlayer()!,
                      crossAxisAlignment: CrossAxisAlignment.end,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    l10n.versus,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withOpacity(.7),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _CallOutTeamLabel(
                      team: match.b.resolvePlayer()!,
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(l10n.on),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            children: [
              TextSpan(
                text: match.court!.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: ' (${match.court!.gymnasium.name})'),
            ],
          ),
        ),
      ],
    );
  }
}

class _CallOutTeamLabel extends StatelessWidget {
  const _CallOutTeamLabel({
    required this.team,
    required this.crossAxisAlignment,
  });

  final Team team;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      waitDuration: const Duration(milliseconds: 500),
      message: team.players
          .map((player) => display_strings.playerWithClub(player))
          .join('\n\n'),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          for (Player player in team.players)
            RichText(
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                children: [
                  TextSpan(
                    text: '${player.firstName} ',
                    style: const TextStyle(fontSize: 14),
                  ),
                  TextSpan(
                    text: player.lastName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
