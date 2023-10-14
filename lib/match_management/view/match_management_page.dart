import 'package:ez_badminton_admin_app/match_management/widgets/match_queue_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MatchManagementPage extends StatelessWidget {
  const MatchManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.matchOperations)),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MatchQueueList(
            width: 420,
            title: l10n.matchQueue,
            sublists: const {},
          ),
          MatchQueueList(
            width: 250,
            title: l10n.readyForCallout,
            sublists: const {},
          ),
          MatchQueueList(
            width: 420,
            title: l10n.runningMatches,
            sublists: const {},
          ),
        ],
      ),
    );
  }
}
