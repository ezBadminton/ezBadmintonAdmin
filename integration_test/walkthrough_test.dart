import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ez_badminton_admin_app/app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:process_run/shell.dart';

import 'matchers.dart';

late final Shell localServerShell;
final List<Process> serverProcesses = [];

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await startLocalServer();
  });

  tearDownAll(() {
    stopLocalServer();
  });

  testWidgets(
    'Test it all!',
    (WidgetTester tester) async {
      await tester.pumpWidget(const App());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 15),
      );

      final BuildContext context = tester.element(find.byType(Scaffold).first);

      var l10n = AppLocalizations.of(context)!;

      await testSignUp(tester, l10n);
      await testLogin(tester, l10n);
    },
  );
}

Future<void> startLocalServer() async {
  Directory cwd = Directory.current;
  Directory serverWorkingDir = Directory(
    "${cwd.path}${Platform.pathSeparator}local_test_server",
  );

  String fileExtension = Platform.isWindows ? '.exe' : '';
  File serverExe = File(
    '${serverWorkingDir.path}${Platform.pathSeparator}ezBadmintonServer$fileExtension',
  );

  if (!await serverExe.exists()) {
    throw Exception(
      "The integration test needs a local server at ${serverExe.path}",
    );
  }

  Directory serverDataDir = Directory(
    '${serverWorkingDir.path}${Platform.pathSeparator}pb_data',
  );

  if (await serverDataDir.exists()) {
    await serverDataDir.delete(recursive: true);
  }

  localServerShell = Shell(
    throwOnError: false,
    workingDirectory: serverWorkingDir.path,
  );

  localServerShell.run(
    './ezBadmintonServer serve',
    onProcess: serverProcesses.add,
  );
}

void stopLocalServer() {
  for (Process p in serverProcesses) {
    p.kill();
  }
}

Future<void> testSignUp(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  expect(find.text(l10n.signUp), findsAny);
  expect(find.text(l10n.invalidUsername), findsNothing);
  expect(find.text(l10n.invalidPassword), findsNothing);
  expect(find.text(l10n.invalidPasswordConfirmation), findsNothing);

  await tester.tap(find.byType(ElevatedButton));

  await tester.pump();

  expect(find.text(l10n.invalidUsername), findsOne);
  expect(find.text(l10n.invalidPassword), findsOne);

  Finder inputs = find.byType(TextField);

  await tester.enterText(inputs.at(0), 'testuser');
  await tester.enterText(inputs.at(1), 'p');

  await tester.pump();

  expect(find.text(l10n.invalidUsername), findsNothing);
  expect(find.text(l10n.passwordTooShort), findsOne);
  expect(find.text(l10n.invalidPasswordConfirmation), findsOne);

  await tester.enterText(inputs.at(1), 'password');
  await tester.enterText(inputs.at(2), 'password1');

  await tester.pump();

  expect(find.text(l10n.passwordTooShort), findsNothing);
  expect(find.text(l10n.invalidPasswordConfirmation), findsOne);

  await tester.enterText(inputs.at(2), 'password');

  await tester.pump();

  expect(find.text(l10n.passwordTooShort), findsNothing);
  expect(find.text(l10n.invalidPasswordConfirmation), findsNothing);

  await tester.tap(find.byType(ElevatedButton));

  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 5),
  );

  expect(find.text(l10n.login), findsAny);
}

Future<void> testLogin(WidgetTester tester, AppLocalizations l10n) async {
  Finder inputs = find.byType(TextField);

  expect(tester.widget(inputs.at(0)), TextFieldText(isEmpty));
  expect(tester.widget(inputs.at(1)), TextFieldText(isEmpty));
  expect(find.text(l10n.invalidUsername), findsNothing);
  expect(find.text(l10n.invalidPassword), findsNothing);
  expect(find.text(l10n.login), findsNWidgets(2));

  await tester.tap(find.byType(ElevatedButton));

  await tester.pump();

  expect(find.text(l10n.invalidUsername), findsOne);
  expect(find.text(l10n.invalidPassword), findsOne);

  await tester.enterText(inputs.at(0), 'testuser');
  await tester.enterText(inputs.at(1), 'passsword');

  await tester.pump();

  expect(find.text(l10n.invalidUsername), findsNothing);
  expect(find.text(l10n.invalidPassword), findsNothing);

  await tester.tap(find.byType(ElevatedButton));

  await tester.pumpAndSettle();

  expect(find.text(l10n.loginError('400')), findsOne);

  await tester.enterText(inputs.at(1), 'password');

  await tester.pump(const Duration(milliseconds: 50));

  await tester.tap(find.byType(ElevatedButton));

  await tester.pumpAndSettle();

  expect(find.text(l10n.login), findsNothing);
}
