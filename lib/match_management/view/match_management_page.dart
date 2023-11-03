import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/call_out_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/match_queue_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/match_queue_settings_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/call_out_script.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/match_queue_list.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/match_queue_settings.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/queued_match.dart';
import 'package:ez_badminton_admin_app/match_management/game_sheet_printing/view/game_sheet_printing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MatchManagementPage extends StatelessWidget {
  const MatchManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MatchQueueCubit(
            tournamentRepository:
                context.read<CollectionRepository<Tournament>>(),
            matchDataRepository:
                context.read<CollectionRepository<MatchData>>(),
          ),
        ),
        BlocProvider(
          create: (context) => CallOutCubit(
            matchDataRepository:
                context.read<CollectionRepository<MatchData>>(),
          ),
        ),
        BlocProvider(
          create: (context) => MatchQueueSettingsCubit(
            tournamentRepository:
                context.read<CollectionRepository<Tournament>>(),
          ),
        ),
      ],
      child: BlocListener<TournamentProgressCubit, TournamentProgressState>(
        listener: (context, state) {
          context.read<MatchQueueCubit>().tournamentChanged(state);
        },
        // Use a nested Navigator get access to the MatchQueueCubit in the routes
        child: Navigator(
          key: const ValueKey('nested-match-management-navigator'),
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (context) => const _MatchManagementPageScaffold(),
          ),
        ),
      ),
    );
  }
}

class _MatchManagementPageScaffold extends StatelessWidget {
  const _MatchManagementPageScaffold();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.matchOperations)),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 80, bottom: 40),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(GameSheetPrintingPage.route());
          },
          heroTag: 'match_print_button',
          child: const Icon(Icons.print),
        ),
      ),
      body: const _MatchQueueLists(),
    );
  }
}

class _MatchQueueLists extends StatelessWidget {
  const _MatchQueueLists();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    TextStyle queueTitleStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 16,
    );

    return BlocBuilder<MatchQueueCubit, MatchQueueState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MatchQueueList(
              width: 420,
              title: Column(
                children: [
                  Text(
                    l10n.matchQueue,
                    style: queueTitleStyle,
                  ),
                  const SizedBox(height: 10),
                  const MatchQueueSettings(),
                ],
              ),
              sublists: _buildWaitList(
                context,
                state.waitList,
                (match, waitingStatus) => WaitingMatch(
                  match: match,
                  waitingStatus: waitingStatus,
                ),
              ),
            ),
            const SizedBox(width: 5),
            MatchQueueList(
              width: 250,
              title: Column(
                children: [
                  Text(
                    l10n.readyForCallout,
                    style: queueTitleStyle,
                  ),
                  const SizedBox(height: 10),
                  const _CallOutAllButton(),
                ],
              ),
              list: _buildMatchList(
                state.calloutWaitList,
                (match) => ReadyForCallOutMatch(match: match),
              ),
            ),
            const SizedBox(width: 5),
            MatchQueueList(
              width: 420,
              title: Text(
                l10n.runningMatches,
                style: queueTitleStyle,
              ),
              list: _buildMatchList(
                state.inProgressList,
                (match) => RunningMatch(match: match),
              ),
            ),
          ],
        );
      },
    );
  }

  Map<Widget, List<Widget>> _buildWaitList(
    BuildContext context,
    Map<MatchWaitingStatus, List<BadmintonMatch>> waitList,
    Widget Function(BadmintonMatch match, MatchWaitingStatus waitingStatus)
        matchItemBuilder,
  ) {
    return waitList.map<Widget, List<Widget>>(
      (waitingStatus, matches) => MapEntry(
        _buildWaitListStatusTitle(context, waitingStatus),
        matches.map((match) => matchItemBuilder(match, waitingStatus)).toList(),
      ),
    );
  }

  Widget _buildWaitListStatusTitle(
    BuildContext context,
    MatchWaitingStatus waitingStatus,
  ) {
    var l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.matchWaitingStatus(waitingStatus.toString()),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (waitingStatus == MatchWaitingStatus.waitingForCourt) ...[
              const SizedBox(width: 8),
              const _OpenCourtsInfo(),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMatchList(
    List<BadmintonMatch> matches,
    Widget Function(BadmintonMatch match) matchItemBuilder,
  ) {
    return matches.map((match) => matchItemBuilder(match)).toList();
  }
}

class _OpenCourtsInfo extends StatelessWidget {
  const _OpenCourtsInfo();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocBuilder<TournamentProgressCubit, TournamentProgressState>(
      buildWhen: (previous, current) =>
          previous.openCourts.length != current.openCourts.length,
      builder: (context, state) {
        return Text(
          l10n.nOpenCourts(state.openCourts.length),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(.55),
          ),
        );
      },
    );
  }
}

class _CallOutAllButton extends StatelessWidget {
  const _CallOutAllButton();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocBuilder<MatchQueueCubit, MatchQueueState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: state.calloutWaitList.isEmpty
              ? null
              : () {
                  showDialog(
                    context: context,
                    builder: (_) => CallOutScript(
                      callOuts: state.calloutWaitList,
                      callOutCubit: context.read<CallOutCubit>(),
                    ),
                  );
                },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.campaign),
              const SizedBox(width: 7),
              Text(l10n.callOutAll),
            ],
          ),
        );
      },
    );
  }
}
