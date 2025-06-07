import 'package:flutter/material.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const SplashPage());
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              l10n.connectingToServer,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
