import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DrawManagementPage extends StatelessWidget {
  const DrawManagementPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const _DrawManagementPageScaffold();
  }
}

class _DrawManagementPageScaffold extends StatelessWidget {
  const _DrawManagementPageScaffold();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.drawManagement)),
      body: const Placeholder(),
    );
  }
}
