import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/call_out_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/match_queue_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/call_out_script.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/match_queue_list.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/queued_match.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MatchManagementPage extends StatelessWidget {
  const MatchManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MatchQueueCubit(),
        ),
        BlocProvider(
          create: (context) => CallOutCubit(
            matchDataRepository:
                context.read<CollectionRepository<MatchData>>(),
          ),
        ),
      ],
      child: BlocListener<TournamentProgressCubit, TournamentProgressState>(
        listener: (context, state) {
          context.read<MatchQueueCubit>().tournamentChanged(state);
        },
        child: Scaffold(
          appBar: AppBar(title: Text(l10n.matchOperations)),
          body: const _MatchQueueLists(),
        ),
      ),
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
              title: Text(
                l10n.matchQueue,
                style: queueTitleStyle,
              ),
              sublists: _buildWaitList(
                state.waitList,
                l10n,
                (match, waitingStatus) => WaitingMatch(
                  match: match,
                  waitingStatus: waitingStatus,
                ),
              ),
            ),
            MatchQueueList(
              width: 250,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.readyForCallout,
                    style: queueTitleStyle,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
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
                  ),
                ],
              ),
              list: _buildMatchList(
                state.calloutWaitList,
                (match) => ReadyForCallOutMatch(match: match),
              ),
            ),
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

  Map<String, List<Widget>> _buildWaitList(
    Map<MatchWaitingStatus, List<BadmintonMatch>> waitList,
    AppLocalizations l10n,
    Widget Function(BadmintonMatch match, MatchWaitingStatus waitingStatus)
        matchItemBuilder,
  ) {
    return waitList.map<String, List<Widget>>(
      (waitStatus, matches) => MapEntry(
        l10n.matchWaitingStatus(waitStatus.toString()),
        matches.map((match) => matchItemBuilder(match, waitStatus)).toList(),
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
