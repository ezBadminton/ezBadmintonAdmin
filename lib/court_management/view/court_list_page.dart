import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CourtListPage extends StatelessWidget {
  const CourtListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const _CourtListPageScaffold();
  }
}

class _CourtListPageScaffold extends StatelessWidget {
  const _CourtListPageScaffold();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.courtManagement)),
      body: const Placeholder(),
    );
  }
}
