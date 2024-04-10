import 'dart:io';

import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/court_management/court_editing/view/court_slot.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/cubit/gymnasium_deletion_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/view/gymnasium_editing_page.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/view/player_editing_form.dart';
import 'package:ez_badminton_admin_app/player_management/widgets/player_expansion_panel_body.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;
import 'package:ez_badminton_admin_app/widgets/custom_expansion_panel_list/expansion_panel_list.dart'
    as custom_expansion_panel;
import 'package:ez_badminton_admin_app/widgets/badminton_court/badminton_court.dart';
import 'package:ez_badminton_admin_app/widgets/custom_input_fields/clearable_dropdown_button.dart';
import 'package:ez_badminton_admin_app/widgets/gym_floor_plan/gym_floor_plan.dart';
import 'package:ez_badminton_admin_app/widgets/mouse_hover_builder/mouse_hover_builder.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ez_badminton_admin_app/app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:process_run/shell.dart';

import 'finders.dart';
import 'matchers.dart';
import 'package:ez_badminton_admin_app/utils/test_environment.dart';

late final Shell localServerShell;
final List<Process> serverProcesses = [];

const String firstName = 'Kane';
const String lastName = 'Doe';
const String clubName = '1. FC Entenhausen';
const String notes = 'This player is\nvery good!';
const String hallName = 'Gym 1';
const String hallName2 = 'Gym 2';
const String hallName3 = 'Gym 3';
const String playingLevel1 = 'Class A';
const String playingLevel2 = 'Class B';
const int overAgeGroup = 25;
const int underAgeGroup = 40;
const List<(String, String)> playerNames = [
  ('Bruce', 'Wayne'),
  ('Mary', 'Jane'),
  ('Mark', 'Twain'),
  ('Lady', 'Gaga'),
  ('Forrest', 'Gump'),
  ('Black', 'Widow'),
  ('Arnold', 'Schwarzenegger'),
  ('Marilyn', 'Monroe'),
  ('Christiano', 'Ronaldo'),
  ('Lea', 'Schüller'),
  ('Peter', 'Parker'),
  ('Zendaya', 'Coleman'),
  ('Steve', 'Jobs'),
  ('Margaret', 'Hamilton'),
  ('Michael', 'Schumacher'),
  ('Ada', 'Lovelace'),
  ('Ryan', 'Reynolds'),
  ('Marie', 'Curie'),
  ('Barack', 'Obama'),
  ('Rosa', 'Luxemburg'),
  ('Peter', 'Pan'),
  ('Sophie', 'Miller'),
  ('Max', 'Mustermann'),
  ('Mary', 'Poppins'),
  ('Mahadma', 'Ghandi'),
  ('Angela', 'Merkel'),
  ('Karl', 'Lagerfeld'),
  ('Bibi', 'Blocksberg'),
  ('Harry', 'Potter'),
  ('Evelyn', 'Glennie'),
  ('Michael', 'Jackson'),
  ('Martha', 'Cruz'),
];

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestEnvironment().isTest = true;
    await startLocalServer();

    debugSemanticsDisableAnimations = true;
  });

  tearDownAll(() {
    stopLocalServer();
  });

  testWidgets(
    'Test it all!',
    (WidgetTester tester) async {
      Widget app = const App();
      await tester.pumpWidget(app);

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
      await testAddPlayer(tester, l10n);
      await testPlayerStatusChange(tester, l10n);
      await testDeletePlayer(tester, l10n);
      await testCreateCompetitions(tester, l10n);
      await testAddCourts(tester, l10n);
      await testCompetitionRegistration(tester, l10n);
      await testCompetitionMerge(tester, l10n);

      await tester.pump(const Duration(seconds: 3));
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
    './ezBadmintonServer serve --http 127.0.0.1:8096',
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
  await tester.enterText(inputs.at(1), 'wrongPassword');

  await tester.pump();

  expect(find.text(l10n.invalidUsername), findsNothing);
  expect(find.text(l10n.invalidPassword), findsNothing);

  await tester.tap(find.byType(ElevatedButton));

  await tester.pumpAndSettle();

  expect(find.text(l10n.loginError('400')), findsOne);

  // Set the username again even though the text field already contains it.
  // Otherwise the test is flaky because the focus of the password text field
  // fails.
  await tester.enterText(inputs.at(0), 'testuser');
  await tester.enterText(inputs.at(1), 'password');

  await tester.pump();

  await tester.tap(find.byType(ElevatedButton));

  await tester.pumpAndSettle();

  expect(find.text(l10n.login), findsNothing);
}

Future<void> testAddPlayer(WidgetTester tester, AppLocalizations l10n) async {
  await tester.tap(find.text(l10n.add));

  await tester.pumpAndSettle();

  expect(find.text(l10n.addSubject(l10n.player(1))), findsOne);

  Finder firstNameInput = find.ancestor(
    of: find.textContaining(l10n.firstName),
    matching: find.byType(TextField),
  );
  Finder lastNameInput = find.ancestor(
    of: find.textContaining(l10n.lastName),
    matching: find.byType(TextField),
  );
  Finder clubInput = find.ancestor(
    of: find.textContaining(l10n.club),
    matching: find.byType(TextField),
  );
  Finder notesInput = find.ancestor(
    of: find.textContaining(l10n.notes),
    matching: find.byType(TextField),
  );

  await tester.enterText(firstNameInput, firstName);

  await tester.pumpAndSettle();

  await tester.tap(find.byType(FloatingActionButton));

  await tester.pump();

  expect(find.text(l10n.pleaseFillIn), findsOne);

  await tester.enterText(lastNameInput, lastName);
  await tester.enterText(clubInput, clubName);
  await tester.enterText(notesInput, notes);

  await tester.tap(find.byType(FloatingActionButton));

  await tester.pumpAndSettle();

  Finder playerPanels = find.ancestor(
    of: find.byType(PlayerExpansionPanelBody),
    matching: find.byType(AnimatedCrossFade),
  );

  expect(playerPanels, findsExactly(1));
  expect(tester.widget(playerPanels.at(0)), IsPanelExpanded(isFalse));

  expect(find.text(l10n.playerManagement), findsOne);
  expect(find.text('$firstName $lastName'), findsOne);
  expect(find.text(clubName), findsOne);
  expect(find.text(notes), findsOne);

  await tester.tap(find.textContaining(firstName));

  await tester.pumpAndSettle();

  expect(tester.widget(playerPanels.at(0)), IsPanelExpanded(isTrue));

  await tester.tap(find.textContaining(firstName));

  await tester.pumpAndSettle();

  expect(tester.widget(playerPanels.at(0)), IsPanelExpanded(isFalse));
}

Future<void> testPlayerStatusChange(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  String notAttending = l10n.playerStatus(PlayerStatus.notAttending.toString());
  String attending = l10n.playerStatus(PlayerStatus.attending.toString());

  await tester.tap(find.textContaining(firstName));
  await tester.pumpAndSettle();

  expect(
    find.ancestor(
      of: find.text(notAttending),
      matching: find.bySubtype<PopupMenuButton>(),
    ),
    findsOne,
  );

  await tester.tap(find.byTooltip(l10n.confirmAttendance));
  await tester.pumpAndSettle();

  expect(find.byTooltip(attending), findsOne);

  Finder popupMenu = find.ancestor(
    of: find.text(attending),
    matching: find.bySubtype<PopupMenuButton>(),
  );

  await tester.tap(popupMenu);
  await tester.pumpAndSettle();

  Finder menuItem = find.ancestor(
    of: find.text(notAttending),
    matching: find.bySubtype<PopupMenuItem>(),
  );

  await tester.tap(menuItem);
  await tester.pumpAndSettle();

  expect(
    find.ancestor(
      of: find.text(notAttending),
      matching: find.bySubtype<PopupMenuButton>(),
    ),
    findsOne,
  );

  await tester.tap(find.textContaining(firstName));
  await tester.pumpAndSettle();
}

Future<void> testDeletePlayer(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  Finder playerPanels = find.ancestor(
    of: find.byType(PlayerExpansionPanelBody),
    matching: find.byType(AnimatedCrossFade),
  );

  await tester.tap(find.textContaining(firstName));
  await tester.pumpAndSettle();

  await tester.tap(find.byType(PopupMenuButton<VoidCallback>));
  await tester.pumpAndSettle();

  await tester.tap(find.text(l10n.deletePlayer));
  await tester.pumpAndSettle();

  expect(find.text(l10n.reallyDeletePlayer), findsOne);

  await tester.tap(find.text(l10n.cancel));
  await tester.pumpAndSettle();

  expect(find.text(l10n.reallyDeletePlayer), findsNothing);
  expect(playerPanels, findsExactly(1));

  await tester.tap(find.byType(PopupMenuButton<VoidCallback>));
  await tester.pumpAndSettle();

  await tester.tap(find.text(l10n.deletePlayer));
  await tester.pumpAndSettle();

  await tester.tap(find.text(l10n.confirm));
  await tester.pumpAndSettle();

  expect(playerPanels, findsNothing);
}

Future<void> testCreateCompetitions(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  await tester.tap(find.text(l10n.competition(2)));
  await tester.pumpAndSettle();

  expect(find.text(l10n.competitionManagement), findsOne);

  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  expect(find.text(l10n.addSubject(l10n.competition(2))), findsOne);
  expect(find.text(l10n.newCompetitions(5)), findsOne);

  await tester.tap(find.text(
    display_strings.competitionCategory(l10n, CompetitionDiscipline.mixed),
  ));
  await tester.pump();

  expect(find.text(l10n.newCompetitions(4)), findsOne);

  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  expect(find.byType(CheckboxListTile), findsExactly(4));
  expect(
    find.text(
      display_strings.competitionCategory(
        l10n,
        CompetitionDiscipline.womensDoubles,
      ),
    ),
    findsOne,
  );
  expect(
    find.text(
      display_strings.competitionCategory(
        l10n,
        CompetitionDiscipline.mensDoubles,
      ),
    ),
    findsOne,
  );
  expect(
    find.text(
      display_strings.competitionCategory(
        l10n,
        CompetitionDiscipline.womensSingles,
      ),
    ),
    findsOne,
  );
  expect(
    find.text(
      display_strings.competitionCategory(
        l10n,
        CompetitionDiscipline.mensSingles,
      ),
    ),
    findsOne,
  );

  await tester.tap(find.text(
    display_strings.competitionCategory(
      l10n,
      CompetitionDiscipline.mensSingles,
    ),
  ));
  await tester.pump();

  expect(
    find.text(l10n.nSubjectsSelected(1, l10n.competition(1))),
    findsOne,
  );

  await tester.tap(find.text(
    display_strings.competitionCategory(
      l10n,
      CompetitionDiscipline.womensDoubles,
    ),
  ));
  await tester.pump();

  expect(
    find.text(l10n.nSubjectsSelected(2, l10n.competition(2))),
    findsOne,
  );

  await tester.tap(find.text(l10n.deleteSubject(l10n.competition(2))));
  await tester.pump();

  expect(find.text(l10n.deleteCompetitions), findsOne);

  await tester.tap(find.text(l10n.cancel));
  await tester.pumpAndSettle();

  expect(find.byType(CheckboxListTile), findsExactly(4));

  await tester.tap(find.text(l10n.deleteSubject(l10n.competition(2))));
  await tester.pump();
  await tester.tap(find.text(l10n.confirm));
  await tester.pumpAndSettle();

  expect(find.byType(CheckboxListTile), findsExactly(2));
  expect(
    find.text(
      display_strings.competitionCategory(
        l10n,
        CompetitionDiscipline.mensDoubles,
      ),
    ),
    findsOne,
  );
  expect(
    find.text(
      display_strings.competitionCategory(
        l10n,
        CompetitionDiscipline.womensSingles,
      ),
    ),
    findsOne,
  );

  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  bool? wsEnabled = (tester.widget(find.ancestor(
    of: find.text(display_strings.competitionCategory(
      l10n,
      CompetitionDiscipline.womensSingles,
    )),
    matching: find.byType(CheckboxListTile),
  )) as CheckboxListTile)
      .enabled;
  bool? wdEnabled = (tester.widget(find.ancestor(
    of: find.text(display_strings.competitionCategory(
      l10n,
      CompetitionDiscipline.womensDoubles,
    )),
    matching: find.byType(CheckboxListTile),
  )) as CheckboxListTile)
      .enabled;
  bool? msEnabled = (tester.widget(find.ancestor(
    of: find.text(display_strings.competitionCategory(
      l10n,
      CompetitionDiscipline.mensSingles,
    )),
    matching: find.byType(CheckboxListTile),
  )) as CheckboxListTile)
      .enabled;
  bool? mdEnabled = (tester.widget(find.ancestor(
    of: find.text(display_strings.competitionCategory(
      l10n,
      CompetitionDiscipline.mensDoubles,
    )),
    matching: find.byType(CheckboxListTile),
  )) as CheckboxListTile)
      .enabled;
  bool? mixedEnabled = (tester.widget(find.ancestor(
    of: find.text(display_strings.competitionCategory(
      l10n,
      CompetitionDiscipline.mixed,
    )),
    matching: find.byType(CheckboxListTile),
  )) as CheckboxListTile)
      .enabled;

  expect(
    [wsEnabled, wdEnabled, msEnabled, mdEnabled, mixedEnabled],
    [isFalse, isTrue, isTrue, isFalse, isTrue],
  );

  final BuildContext context = tester.element(find.byType(Scaffold).first);
  await tester.tap(
    find.byTooltip(MaterialLocalizations.of(context).backButtonTooltip),
  );
  await tester.pumpAndSettle();

  expect(find.text(l10n.competitionManagement), findsOne);

  Finder ageGroupSwitch = find.descendant(
    of: find
        .ancestor(
          of: find.text(l10n.activateAgeGroups),
          matching: find.byType(Row),
        )
        .first,
    matching: find.byType(Switch),
  );
  Finder playingLevelSwitch = find.descendant(
    of: find
        .ancestor(
          of: find.text(l10n.activatePlayingLevels),
          matching: find.byType(Row),
        )
        .first,
    matching: find.byType(Switch),
  );

  await tester.tap(ageGroupSwitch);
  await tester.pumpAndSettle();

  expect(find.text(l10n.noneOf(l10n.ageGroup(2))), findsOne);

  await tester.tap(find.text(l10n.close));
  await tester.pumpAndSettle();

  await tester.tap(find.descendant(
    of: find.byType(Transform),
    matching: find.byType(Checkbox),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.deleteSubject(l10n.competition(2))));
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.confirm));
  await tester.pumpAndSettle();

  await tester.tap(ageGroupSwitch);
  await tester.pumpAndSettle();

  expect((tester.widget(ageGroupSwitch) as Switch).value, isTrue);

  await tester.tap(find.text(l10n.editSubject(l10n.ageGroup(2))));
  await tester.pumpAndSettle();

  Finder radioButtons = find.byType(Radio<AgeGroupType>);

  await tester.tap(radioButtons.at(0));
  await tester.pump();
  await tester.enterText(find.byType(TextField), '$overAgeGroup');
  await tester.pumpAndSettle();
  await tester.tap(find.ancestor(
    of: find.text(l10n.add),
    matching: find.byType(ElevatedButton),
  ));
  await tester.pumpAndSettle();

  expect(find.text('${l10n.overAgeAbbreviated}$overAgeGroup'), findsOne);

  await tester.tap(radioButtons.at(1));
  await tester.pump();
  await tester.enterText(find.byType(TextField), '$underAgeGroup');
  await tester.pumpAndSettle();
  await tester.tap(find.ancestor(
    of: find.text(l10n.add),
    matching: find.byType(ElevatedButton),
  ));
  await tester.pumpAndSettle();

  expect(find.text('${l10n.underAgeAbbreviated}40'), findsOne);

  await tester.tapAt(const Offset(250, 10));
  await tester.pumpAndSettle();

  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  Finder ageGroupCheckbox = find.descendant(
    of: find
        .ancestor(
          of: find.text(l10n.ageGroup(2)),
          matching: find.byType(Row),
        )
        .first,
    matching: find.byType(Checkbox),
  );

  await tester.tap(ageGroupCheckbox);
  await tester.pumpAndSettle();
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  expect(find.byType(CheckboxListTile), findsExactly(10));
  expect(find.text('${l10n.overAgeAbbreviated}$overAgeGroup'), findsExactly(5));
  expect(
      find.text('${l10n.underAgeAbbreviated}$underAgeGroup'), findsExactly(5));

  await tester.tap(ageGroupSwitch);
  await tester.pumpAndSettle();

  expect(find.byType(CheckboxListTile), findsExactly(5));
  expect(find.text('${l10n.overAgeAbbreviated}$overAgeGroup'), findsNothing);
  expect(find.text('${l10n.underAgeAbbreviated}$underAgeGroup'), findsNothing);

  await tester.tap(ageGroupSwitch);
  await tester.pumpAndSettle();

  expect(find.text('${l10n.overAgeAbbreviated}$overAgeGroup'), findsExactly(5));

  await tester.tap(playingLevelSwitch);
  await tester.pumpAndSettle();

  expect(find.text(l10n.noneOf(l10n.playingLevel(2))), findsOne);

  await tester.tap(find.descendant(
    of: find.byType(AlertDialog),
    matching: find.text(l10n.editSubject(l10n.playingLevel(2))),
  ));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField), playingLevel1);
  await tester.pumpAndSettle();
  await tester.tap(find.ancestor(
    of: find.text(l10n.add),
    matching: find.byType(ElevatedButton),
  ));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField), playingLevel2);
  await tester.pumpAndSettle();
  await tester.tap(find.ancestor(
    of: find.text(l10n.add),
    matching: find.byType(ElevatedButton),
  ));
  await tester.pumpAndSettle();

  await tester.tapAt(const Offset(250, 10));
  await tester.pumpAndSettle();

  await tester.tap(playingLevelSwitch);
  await tester.pumpAndSettle();

  expect(find.text(playingLevel1), findsExactly(5));
  expect(find.text(playingLevel2), findsNothing);

  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  await tester.tap(find.text(playingLevel1));
  await tester.pump();

  bool? ageGroupEnabled = (tester.widget(find.ancestor(
    of: find.text('${l10n.overAgeAbbreviated}$overAgeGroup'),
    matching: find.byType(CheckboxListTile),
  )) as CheckboxListTile)
      .enabled;

  expect(ageGroupEnabled, isFalse);

  ageGroupEnabled = (tester.widget(find.ancestor(
    of: find.text('${l10n.underAgeAbbreviated}$underAgeGroup'),
    matching: find.byType(CheckboxListTile),
  )) as CheckboxListTile)
      .enabled;

  expect(ageGroupEnabled, isTrue);

  await tester.tap(find.text(playingLevel1));
  await tester.pump();
  await tester.tap(find.text('${l10n.overAgeAbbreviated}$overAgeGroup'));
  await tester.pump();

  bool? playingLevelEnabled = (tester.widget(find.ancestor(
    of: find.text(playingLevel1),
    matching: find.byType(CheckboxListTile),
  )) as CheckboxListTile)
      .enabled;

  expect(playingLevelEnabled, isFalse);

  playingLevelEnabled = (tester.widget(find.ancestor(
    of: find.text(playingLevel2),
    matching: find.byType(CheckboxListTile),
  )) as CheckboxListTile)
      .enabled;

  expect(playingLevelEnabled, isTrue);

  await tester.tap(
    find.byTooltip(MaterialLocalizations.of(context).backButtonTooltip),
  );
  await tester.pumpAndSettle();
}

Future<void> testAddCourts(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  Finder gymAddButton = find.ancestor(
    of: find.text(l10n.gym(1)),
    matching: find.byType(ElevatedButton),
  );

  await tester.tap(find.text(l10n.court(2)));
  await tester.pumpAndSettle();

  expect(find.text(l10n.courtManagement), findsOne);
  expect(find.text(l10n.addFirstGymnasium), findsOne);

  await tester.tap(gymAddButton);
  await tester.pumpAndSettle();

  expect(find.text(l10n.addSubject(l10n.gym(1))), findsOne);

  Finder inputs = find.byType(TextField);

  await tester.enterText(inputs.at(0), hallName);
  await tester.pump();

  Finder miniCourts = find.descendant(
    of: find.byType(GymFloorPlan),
    matching: find.byType(SizedBox),
  );

  expect(miniCourts, findsExactly(4));

  // Rows + - Columns - +
  Finder floorPlanControls = find.descendant(
    of: find.byType(GymnasiumEditingPage),
    matching: find.byType(IconButton),
  );

  await tester.tap(floorPlanControls.at(0));
  await tester.pump();

  expect(miniCourts, findsExactly(6));

  await tester.tap(floorPlanControls.at(2));
  await tester.pump();

  expect(miniCourts, findsExactly(3));

  await tester.tap(floorPlanControls.at(3));
  await tester.pump();
  await tester.tap(floorPlanControls.at(3));
  await tester.pumpAndSettle();

  expect(miniCourts, findsExactly(9));

  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  Finder courtSlots = find.byType(CourtSlot);
  Finder filledCourtSlots = find.byWidgetPredicate(
    (widget) => widget is BadmintonCourt && widget.child is Stack,
  );
  Finder courtAddButtons = find.descendant(
    of: courtSlots,
    matching: find.byIcon(Icons.add),
  );
  Finder renameButtons = find.byTooltip(l10n.rename);
  Finder deleteButtons = find.bySubtype<PopupMenuButton>();

  expect(find.text(hallName), findsExactly(2));
  expect(courtSlots, findsExactly(9));
  expect(courtAddButtons, findsExactly(9));

  await tester.tap(courtAddButtons.at(0));
  await tester.pumpAndSettle();

  expect(find.text(l10n.courtN(1)), findsExactly(2));
  expect(filledCourtSlots, findsExactly(1));

  await tester.tap(courtAddButtons.at(1));
  await tester.pumpAndSettle();

  expect(find.text(l10n.courtN(7)), findsExactly(2));
  expect(filledCourtSlots, findsExactly(2));

  await tester.tap(renameButtons.at(0));
  await tester.pump();

  String courtName = 'Court Name';
  await tester.enterText(find.byType(TextField), courtName);
  await tester.tap(find.text(l10n.done));
  await tester.pumpAndSettle();

  expect(find.text(courtName), findsExactly(2));

  await tester.tap(deleteButtons.at(0));
  await tester.pumpAndSettle();

  await tester.tap(find.text(l10n.deleteSubject(l10n.court(1))));
  await tester.pumpAndSettle();

  expect(find.text(courtName), findsNothing);
  expect(filledCourtSlots, findsExactly(1));

  await tester.tap(find.byIcon(Icons.library_add));
  await tester.pumpAndSettle();

  expect(filledCourtSlots, findsExactly(9));

  await tester.tap(gymAddButton);
  await tester.pumpAndSettle();

  await tester.enterText(inputs.at(0), hallName2);
  await tester.pumpAndSettle();

  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  expect(find.text(hallName2), findsExactly(2));
  expect(courtSlots, findsExactly(4));
  expect(courtAddButtons, findsExactly(4));
  expect(filledCourtSlots, findsNothing);

  await tester.tap(find.byIcon(Icons.library_add));
  await tester.pumpAndSettle();

  expect(filledCourtSlots, findsExactly(4));

  await tester.tap(deleteButtons.at(1));
  await tester.pumpAndSettle();

  await tester.tap(find.text(l10n.deleteSubject(l10n.court(1))));
  await tester.pumpAndSettle();

  expect(filledCourtSlots, findsExactly(3));

  Finder gymnasiumMenuButton = find.byType(
    BlocBuilder<GymnasiumDeletionCubit, GymnasiumDeletionState>,
  );

  await tester.tap(gymnasiumMenuButton);
  await tester.pumpAndSettle();

  await tester.tap(find.text(l10n.numberCourts));
  await tester.pumpAndSettle();

  await tester.tap(find.text(l10n.rowWise));
  await tester.pump();
  await tester.tap(find.text(l10n.allGyms));
  await tester.pump();
  await tester.tap(find.text(l10n.count));
  await tester.pump();

  await tester.tap(find.text(l10n.renameSubject(l10n.court(2))));
  await tester.pumpAndSettle();

  expect(
    find.descendant(
      of: courtSlots.at(0),
      matching: find.text(l10n.courtN(10)),
    ),
    findsOne,
  );
  expect(
    find.descendant(
      of: courtSlots.at(1),
      matching: find.byIcon(Icons.add),
    ),
    findsOne,
  );
  expect(
    find.descendant(
      of: courtSlots.at(2),
      matching: find.text(l10n.courtN(12)),
    ),
    findsOne,
  );
  expect(
    find.descendant(
      of: courtSlots.at(3),
      matching: find.text(l10n.courtN(13)),
    ),
    findsOne,
  );

  await tester.tap(renameButtons.at(0));
  await tester.pump();
  await tester.enterText(find.byType(TextField), l10n.courtN(12));
  await tester.tap(find.text(l10n.done));
  await tester.pumpAndSettle();

  expect(find.text(l10n.courtN(10)), findsExactly(2));
  expect(find.text(l10n.courtN(12)), findsExactly(2));

  await tester.tap(find.byTooltip(l10n.editSubject(l10n.gym(1))));
  await tester.pumpAndSettle();

  expect(find.text(l10n.editSubject(l10n.gym(1))), findsOne);

  await tester.enterText(inputs.at(0), hallName3);
  await tester.pumpAndSettle();

  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  expect(find.text(hallName3), findsExactly(2));
}

Future<void> testCompetitionRegistration(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  for ((String, String) playerName in playerNames) {
    await createPlayer(tester, l10n, playerName.$1, playerName.$2);
  }

  await registerPlayer(
    tester,
    l10n,
    playerNames[0].$1,
    playerNames[0].$2,
    playingLevel1,
    '${l10n.overAgeAbbreviated}$overAgeGroup',
    l10n.genderCategory(GenderCategory.female.toString()),
    l10n.competitionType(CompetitionType.doubles.toString()),
    null,
  );

  await registerPlayer(
    tester,
    l10n,
    playerNames[1].$1,
    playerNames[1].$2,
    playingLevel1,
    '${l10n.overAgeAbbreviated}$overAgeGroup',
    l10n.genderCategory(GenderCategory.female.toString()),
    l10n.competitionType(CompetitionType.doubles.toString()),
    '${playerNames[0].$1} ${playerNames[0].$2}',
  );

  await openPlayerPanel(tester, l10n, playerNames[0].$1, playerNames[0].$2);

  Finder registrationCard = findRegistrationCard(
    l10n,
    playerNames[0].$1,
    playerNames[0].$2,
    playingLevel1,
    '${l10n.overAgeAbbreviated}$overAgeGroup',
    l10n.genderCategory(GenderCategory.female.toString()),
    l10n.competitionType(CompetitionType.doubles.toString()),
    '${playerNames[1].$1} ${playerNames[1].$2}',
  );

  expect(registrationCard, findsOne);

  await unregisterPlayer(
    tester,
    l10n,
    playerNames[0].$1,
    playerNames[0].$2,
    playingLevel1,
    '${l10n.overAgeAbbreviated}$overAgeGroup',
    l10n.genderCategory(GenderCategory.female.toString()),
    l10n.competitionType(CompetitionType.doubles.toString()),
    '${playerNames[1].$1} ${playerNames[1].$2}',
  );
  await openPlayerPanel(tester, l10n, playerNames[1].$1, playerNames[1].$2);

  registrationCard = findRegistrationCard(
    l10n,
    playerNames[1].$1,
    playerNames[1].$2,
    playingLevel1,
    '${l10n.overAgeAbbreviated}$overAgeGroup',
    l10n.genderCategory(GenderCategory.female.toString()),
    l10n.competitionType(CompetitionType.doubles.toString()),
    null,
  );
  expect(registrationCard, findsOne);

  await registerPartner(
    tester,
    l10n,
    registrationCard,
    '${playerNames[0].$1} ${playerNames[0].$2}',
  );

  registrationCard = findRegistrationCard(
    l10n,
    playerNames[1].$1,
    playerNames[1].$2,
    playingLevel1,
    '${l10n.overAgeAbbreviated}$overAgeGroup',
    l10n.genderCategory(GenderCategory.female.toString()),
    l10n.competitionType(CompetitionType.doubles.toString()),
    '${playerNames[0].$1} ${playerNames[0].$2}',
  );
  expect(registrationCard, findsOne);

  await registerPlayer(
    tester,
    l10n,
    playerNames[2].$1,
    playerNames[2].$2,
    playingLevel1,
    '${l10n.overAgeAbbreviated}$overAgeGroup',
    l10n.genderCategory(GenderCategory.female.toString()),
    l10n.competitionType(CompetitionType.doubles.toString()),
    null,
  );
  await registerPlayer(
    tester,
    l10n,
    playerNames[3].$1,
    playerNames[3].$2,
    playingLevel1,
    '${l10n.overAgeAbbreviated}$overAgeGroup',
    l10n.genderCategory(GenderCategory.female.toString()),
    l10n.competitionType(CompetitionType.doubles.toString()),
    null,
  );
  await openPlayerPanel(tester, l10n, playerNames[3].$1, playerNames[3].$2);

  registrationCard = findRegistrationCard(
    l10n,
    playerNames[3].$1,
    playerNames[3].$2,
    playingLevel1,
    '${l10n.overAgeAbbreviated}$overAgeGroup',
    l10n.genderCategory(GenderCategory.female.toString()),
    l10n.competitionType(CompetitionType.doubles.toString()),
    null,
  );

  await registerPartner(
    tester,
    l10n,
    registrationCard,
    '${playerNames[2].$1} ${playerNames[2].$2}',
  );

  registrationCard = findRegistrationCard(
    l10n,
    playerNames[3].$1,
    playerNames[3].$2,
    playingLevel1,
    '${l10n.overAgeAbbreviated}$overAgeGroup',
    l10n.genderCategory(GenderCategory.female.toString()),
    l10n.competitionType(CompetitionType.doubles.toString()),
    '${playerNames[2].$1} ${playerNames[2].$2}',
  );
  expect(registrationCard, findsOne);

  await openPlayerPanel(tester, l10n, playerNames[2].$1, playerNames[2].$2);

  registrationCard = findRegistrationCard(
    l10n,
    playerNames[2].$1,
    playerNames[2].$2,
    playingLevel1,
    '${l10n.overAgeAbbreviated}$overAgeGroup',
    l10n.genderCategory(GenderCategory.female.toString()),
    l10n.competitionType(CompetitionType.doubles.toString()),
    '${playerNames[3].$1} ${playerNames[3].$2}',
  );
  expect(registrationCard, findsOne);

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.competition(2)),
  ));
  await tester.pumpAndSettle();

  Finder registrationCount = find.descendant(
    of: find
        .ancestor(
          of: find.text(display_strings.competitionGenderAndType(
            l10n,
            GenderCategory.female,
            CompetitionType.doubles,
          )),
          matching: find.byType(CheckboxListTile),
        )
        .first,
    matching: find.text('2'),
  );

  expect(registrationCount, findsOne);

  await tester.tap(registrationCount);
  await tester.pumpAndSettle();

  expect(find.text(l10n.playerManagement), findsOne);

  expect(find.text('${playerNames[0].$1} ${playerNames[0].$2}'), findsOne);
  expect(find.text('${playerNames[1].$1} ${playerNames[1].$2}'), findsOne);
  expect(find.text('${playerNames[2].$1} ${playerNames[2].$2}'), findsOne);
  expect(find.text('${playerNames[3].$1} ${playerNames[3].$2}'), findsOne);
  expect(find.text('${playerNames[4].$1} ${playerNames[4].$2}'), findsNothing);
  expect(find.text('${playerNames[5].$1} ${playerNames[5].$2}'), findsNothing);

  await tester.tap(find.byIcon(Icons.filter_alt_off));
  await tester.pumpAndSettle();

  expect(find.text('${playerNames[0].$1} ${playerNames[0].$2}'), findsOne);
  expect(find.text('${playerNames[1].$1} ${playerNames[1].$2}'), findsOne);
  expect(find.text('${playerNames[2].$1} ${playerNames[2].$2}'), findsOne);
  expect(find.text('${playerNames[3].$1} ${playerNames[3].$2}'), findsOne);
  expect(find.text('${playerNames[4].$1} ${playerNames[4].$2}'), findsOne);
  expect(find.text('${playerNames[5].$1} ${playerNames[5].$2}'), findsOne);

  final BuildContext context = tester.element(find.byType(Scaffold).first);
  await tester.tap(
    find.byTooltip(MaterialLocalizations.of(context).backButtonTooltip),
  );
  await tester.pumpAndSettle();

  expect(find.text(l10n.competitionManagement), findsOne);
}

Future<void> testCompetitionMerge(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.competition(2)),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  Finder playingLevelCheckbox = find.descendant(
    of: find
        .ancestor(
          of: find.text(l10n.playingLevel(2)),
          matching: find.byType(Row),
        )
        .first,
    matching: find.byType(Checkbox),
  );

  await tester.tap(playingLevelCheckbox);
  await tester.pump();
  await tester.tap(find.text('${l10n.underAgeAbbreviated}$underAgeGroup'));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.player(2)),
  ));
  await tester.pumpAndSettle();

  for ((String, String) playerName in playerNames.sublist(0, 4)) {
    await registerPlayer(
      tester,
      l10n,
      playerName.$1,
      playerName.$2,
      playingLevel1,
      '${l10n.underAgeAbbreviated}$underAgeGroup',
      l10n.genderCategory(GenderCategory.male.toString()),
      l10n.competitionType(CompetitionType.singles.toString()),
      null,
    );
  }
  for ((String, String) playerName in playerNames.sublist(4, 8)) {
    await registerPlayer(
      tester,
      l10n,
      playerName.$1,
      playerName.$2,
      playingLevel2,
      '${l10n.underAgeAbbreviated}$underAgeGroup',
      l10n.genderCategory(GenderCategory.male.toString()),
      l10n.competitionType(CompetitionType.singles.toString()),
      null,
    );
  }

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.competition(2)),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.editSubject(l10n.playingLevel(2))));
  await tester.pumpAndSettle();

  Finder deleteButton = find.descendant(
    of: find
        .ancestor(
          of: find.text(playingLevel2),
          matching: find.byType(MouseHoverBuilder),
        )
        .first,
    matching: find.byIcon(Icons.close),
  );

  await tester.tap(deleteButton);
  await tester.pumpAndSettle();

  expect(find.text(l10n.deleteSubjectQuestion(l10n.playingLevel(1))), findsOne);

  await tester.tap(find.byType(DropdownButtonFormField<PlayingLevel>));
  await tester.pump();

  Finder dropdownOption = find.descendant(
    of: find.byType(DropdownMenuItem<PlayingLevel>),
    matching: find.text(playingLevel1),
  );

  await tester.tap(dropdownOption);
  await tester.pump();

  await tester.tap(find.text(l10n.confirm));
  await tester.pumpAndSettle();

  expect(find.text(playingLevel2), findsNothing);

  await tester.tapAt(const Offset(250, 10));
  await tester.pumpAndSettle();

  Finder registrationCount = find.descendant(
    of: find.ancestor(
      of: find.text(display_strings.competitionGenderAndType(
        l10n,
        GenderCategory.male,
        CompetitionType.singles,
      )),
      matching: find.byType(CheckboxListTile),
    ),
    matching: find.text('8'),
  );

  expect(registrationCount, findsOne);
  expect(find.byType(CheckboxListTile), findsExactly(10));

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.player(2)),
  ));
  await tester.pumpAndSettle();

  for ((String, String) playerName in playerNames.sublist(7, 10)) {
    await registerPlayer(
      tester,
      l10n,
      playerName.$1,
      playerName.$2,
      playingLevel1,
      '${l10n.overAgeAbbreviated}$overAgeGroup',
      l10n.genderCategory(GenderCategory.male.toString()),
      l10n.competitionType(CompetitionType.singles.toString()),
      null,
    );
  }

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.competition(2)),
  ));
  await tester.pumpAndSettle();

  Finder ageGroupSwitch = find.descendant(
    of: find
        .ancestor(
          of: find.text(l10n.activateAgeGroups),
          matching: find.byType(Row),
        )
        .first,
    matching: find.byType(Switch),
  );

  await tester.tap(ageGroupSwitch);
  await tester.pumpAndSettle();

  expect(find.text(l10n.disableCategorization(l10n.ageGroup(2))), findsOne);

  await tester.tap(find.text(l10n.confirm));
  await tester.pumpAndSettle();

  registrationCount = find.descendant(
    of: find.ancestor(
      of: find.text(display_strings.competitionGenderAndType(
        l10n,
        GenderCategory.male,
        CompetitionType.singles,
      )),
      matching: find.byType(CheckboxListTile),
    ),
    matching: find.text('10'),
  );

  expect(registrationCount, findsOne);
  expect(find.byType(CheckboxListTile), findsExactly(5));
}

Future<void> createPlayer(
  WidgetTester tester,
  AppLocalizations l10n,
  String firstName,
  String lastName,
) async {
  Finder playerPageTitle = find.text(l10n.playerManagement);

  if (playerPageTitle.evaluate().isEmpty) {
    Finder playerTab = find.descendant(
      of: find.byType(NavigationRail),
      matching: find.text(l10n.player(2)),
    );

    expect(playerTab, findsOne);

    await tester.tap(playerTab);
    await tester.pumpAndSettle();

    expect(playerPageTitle, findsOne);
  }

  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  Finder inputs = find.byType(TextField);

  await tester.enterText(inputs.at(0), firstName);
  await tester.enterText(inputs.at(2), lastName);
  await tester.pumpAndSettle();

  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  expect(playerPageTitle, findsOne);
  expect(find.text('$firstName $lastName'), findsOne);

  await tester.tap(find.text('$firstName $lastName'));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip(l10n.confirmAttendance));
  await tester.pumpAndSettle();

  Finder playerStatus = find.descendant(
    of: find
        .ancestor(
          of: find.text('$firstName $lastName'),
          matching: find.byType(Column),
        )
        .at(1),
    matching: find.text(l10n.playerStatus(PlayerStatus.attending.toString())),
  );

  expect(playerStatus, findsOne);

  await tester.tap(find.text('$firstName $lastName'));
  await tester.pumpAndSettle();
}

Future<void> registerPlayer(
  WidgetTester tester,
  AppLocalizations l10n,
  String firstName,
  String lastName,
  String? playingLevel,
  String? ageGroup,
  String genderCategory,
  String competitionType,
  String? partner,
) async {
  await openPlayerPanel(tester, l10n, firstName, lastName);

  Finder playerEditButton = find.descendant(
    of: find
        .ancestor(
          of: find.text('$firstName $lastName'),
          matching: find.byType(Column),
        )
        .at(1),
    matching: find.text(l10n.editSubject(l10n.playerAndRegistrations)),
  );

  await tester.tap(playerEditButton);
  await tester.pumpAndSettle();

  await tester.tap(find.text(l10n.addRegistration));
  await tester.pumpAndSettle();

  Finder scrollable = find
      .ancestor(
        of: find.byType(PlayerEditingForm),
        matching: find.bySubtype<Scrollable>(),
      )
      .first;

  if (playingLevel != null) {
    Finder playingLevelList =
        find.byType(ClearableDropdownButton<PlayingLevel>).hitTestable();
    await tester.scrollUntilVisible(
      playingLevelList,
      -30,
      scrollable: scrollable,
    );

    await tester.tap(playingLevelList);
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
      of: find.byType(DropdownMenuItem<PlayingLevel>),
      matching: find.text(playingLevel),
    ));
    await tester.pumpAndSettle();
  }

  if (ageGroup != null) {
    Finder ageGroupList =
        find.byType(ClearableDropdownButton<AgeGroup>).hitTestable();
    await tester.scrollUntilVisible(
      ageGroupList,
      -30,
      scrollable: scrollable,
    );

    await tester.tap(ageGroupList);
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
      of: find.byType(DropdownMenuItem<AgeGroup>),
      matching: find.text(ageGroup),
    ));
    await tester.pumpAndSettle();
  }

  Finder genderCategoryList =
      find.byType(ClearableDropdownButton<GenderCategory>).hitTestable();
  await tester.scrollUntilVisible(
    genderCategoryList,
    -30,
    scrollable: scrollable,
  );

  await tester.tap(genderCategoryList);
  await tester.pumpAndSettle();
  await tester.tap(find.descendant(
    of: find.byType(DropdownMenuItem<GenderCategory>),
    matching: find.text(genderCategory),
  ));
  await tester.pumpAndSettle();

  Finder competitionTypeList =
      find.byType(ClearableDropdownButton<CompetitionType>).hitTestable();
  await tester.scrollUntilVisible(
    competitionTypeList,
    -30,
    scrollable: scrollable,
  );

  await tester.tap(competitionTypeList);
  await tester.pumpAndSettle();
  await tester.pumpAndSettle();
  await tester.tap(find.descendant(
    of: find.byType(DropdownMenuItem<CompetitionType>),
    matching: find.text(competitionType),
  ));
  await tester.pumpAndSettle();

  if (partner != null) {
    Finder partnerInput = find
        .ancestor(
          of: find.textContaining(l10n.partner),
          matching: find.byType(TextField),
        )
        .hitTestable();
    await tester.scrollUntilVisible(
      partnerInput,
      -30,
      scrollable: scrollable,
    );

    await tester.enterText(partnerInput, partner);
    await tester.pump();
    await tester.tap(find.byWidgetPredicate(
      (widget) => widget is Text && widget.data == partner,
    ));
    await tester.pump();
  }

  await tester.tap(find.text(l10n.register.toUpperCase()));
  await tester.pumpAndSettle();

  Finder registrationNotice = find.text(l10n.registrationWarning);
  if (registrationNotice.evaluate().isNotEmpty) {
    await tester.tap(find.text(l10n.continueMsg));
    await tester.pumpAndSettle();
  }

  Finder registrationCard = findRegistrationCard(
    l10n,
    firstName,
    lastName,
    playingLevel,
    ageGroup,
    genderCategory,
    competitionType,
    partner,
  );

  expect(registrationCard, findsOne);

  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  expect(registrationCard, findsOne);
}

Future<void> unregisterPlayer(
  WidgetTester tester,
  AppLocalizations l10n,
  String firstName,
  String lastName,
  String? playingLevel,
  String? ageGroup,
  String genderCategory,
  String competitionType,
  String? partner,
) async {
  await openPlayerPanel(tester, l10n, firstName, lastName);

  Finder playerEditButton = find.descendant(
    of: find
        .ancestor(
          of: find.text('$firstName $lastName'),
          matching: find.byType(Column),
        )
        .at(1),
    matching: find.text(l10n.editSubject(l10n.playerAndRegistrations)),
  );

  await tester.tap(playerEditButton);
  await tester.pumpAndSettle();

  Finder registrationCard = findRegistrationCard(
    l10n,
    firstName,
    lastName,
    playingLevel,
    ageGroup,
    genderCategory,
    competitionType,
    partner,
  );

  expect(registrationCard, findsOne);

  Finder unregisterButton = find.descendant(
    of: registrationCard,
    matching: find.byIcon(Icons.close),
  );

  await tester.tap(unregisterButton);
  await tester.pumpAndSettle();

  expect(registrationCard, findsNothing);

  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  expect(registrationCard, findsNothing);
}

Future<void> registerPartner(
  WidgetTester tester,
  AppLocalizations l10n,
  Finder registrationCard,
  String partner,
) async {
  Finder partnerRegistrationButton = find.descendant(
    of: registrationCard,
    matching: find.text(l10n.registerPartner),
  );

  await tester.tap(partnerRegistrationButton);
  await tester.pump();

  Finder partnerInput = find.descendant(
    of: registrationCard,
    matching: find.byType(TextField),
  );

  await tester.enterText(partnerInput, partner);
  await tester.pumpAndSettle();

  Finder doneButton = find.descendant(
    of: registrationCard,
    matching: find.text(l10n.done),
  );

  await tester.tap(doneButton);
  await tester.pumpAndSettle();
}

Future<void> openPlayerPanel(
  WidgetTester tester,
  AppLocalizations l10n,
  String firstName,
  String lastName,
) async {
  Finder playerList = find.ancestor(
    of: find.byType(custom_expansion_panel.ExpansionPanelList),
    matching: find.bySubtype<Scrollable>(),
  );

  Finder playerEditButton = find
      .descendant(
        of: find
            .ancestor(
              of: find.text('$firstName $lastName'),
              matching: find.byType(Column),
            )
            .at(1),
        matching: find.text(l10n.editSubject(l10n.playerAndRegistrations)),
      )
      .hitTestable();

  Finder playerName = find.text('$firstName $lastName').hitTestable();

  try {
    await tester.scrollUntilVisible(
      playerName,
      -150,
      scrollable: playerList,
      maxScrolls: 15,
    );
  } catch (_) {}

  try {
    await tester.scrollUntilVisible(
      playerName,
      150,
      scrollable: playerList,
      maxScrolls: 15,
    );
  } catch (_) {}

  bool isExpanded =
      (tester.widget(playerName) as Text).style?.fontWeight == FontWeight.w600;

  if (!isExpanded) {
    await tester.tap(playerName);
    await tester.pumpAndSettle();
  }

  await tester.scrollUntilVisible(
    playerEditButton,
    50,
    scrollable: playerList,
    maxScrolls: 20,
  );
  await tester.scrollUntilVisible(
    playerName,
    -50,
    scrollable: playerList,
    maxScrolls: 20,
  );
  await tester.pump();

  expect(playerName, findsOne);
  expect(playerEditButton, findsOne);
}
