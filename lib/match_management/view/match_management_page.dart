import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/match_management/cubit/match_queue_cubit.dart';
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
    return BlocProvider(
      create: (context) => MatchQueueCubit(
        competitionRepository:
            context.read<CollectionRepository<Competition>>(),
      ),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.matchOperations)),
        body: const _MatchQueueLists(),
      ),
    );
  }
}

class _MatchQueueLists extends StatelessWidget {
  const _MatchQueueLists();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocBuilder<MatchQueueCubit, MatchQueueState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MatchQueueList(
              width: 420,
              title: l10n.matchQueue,
              sublists: _buildWaitList(state.waitList, l10n),
            ),
            MatchQueueList(
              width: 250,
              title: l10n.readyForCallout,
              list: _buildMatchList(state.calloutWaitList),
            ),
            MatchQueueList(
              width: 420,
              title: l10n.runningMatches,
              list: _buildMatchList(state.inProgressList),
            ),
          ],
        );
      },
    );
  }

  Map<String, List<Widget>> _buildWaitList(
    Map<MatchWaitingStatus, List<BadmintonMatch>> waitList,
    AppLocalizations l10n,
  ) {
    return waitList.map<String, List<Widget>>(
      (waitStatus, matches) => MapEntry(
        l10n.matchWaitingStatus(waitStatus.toString()),
        matches.map((match) => QueuedMatch(match: match)).toList(),
      ),
    );
  }

  List<Widget> _buildMatchList(List<BadmintonMatch> matches) {
    return matches.map((match) => QueuedMatch(match: match)).toList();
  }
}
