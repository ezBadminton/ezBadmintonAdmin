import 'package:collection_repository/collection_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TournamentModeAssignmentPage extends StatelessWidget {
  const TournamentModeAssignmentPage({
    super.key,
    required this.competitions,
  });

  final List<Competition> competitions;

  static Route<void> route(List<Competition> competitions) {
    return MaterialPageRoute<void>(
      builder: (_) => TournamentModeAssignmentPage(competitions: competitions),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const _TournamentModeAssignmentPageScaffold();
  }
}

class _TournamentModeAssignmentPageScaffold extends StatelessWidget {
  const _TournamentModeAssignmentPageScaffold();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.assignTournamentMode)),
      body: const Placeholder(),
    );
  }
}
