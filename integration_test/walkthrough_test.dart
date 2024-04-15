import 'dart:io';

import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/assets/badminton_icons_icons.dart';
import 'package:ez_badminton_admin_app/competition_management/models/competition_category.dart';
import 'package:ez_badminton_admin_app/competition_management/tournament_mode_assignment/widgets/tournament_mode_selector.dart';
import 'package:ez_badminton_admin_app/constants.dart';
import 'package:ez_badminton_admin_app/court_management/court_editing/view/court_slot.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/cubit/gymnasium_deletion_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/view/gymnasium_editing_page.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/match_queue_list.dart';
import 'package:ez_badminton_admin_app/match_management/widgets/queued_match.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/view/player_editing_form.dart';
import 'package:ez_badminton_admin_app/player_management/widgets/player_expansion_panel_body.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;
import 'package:ez_badminton_admin_app/widgets/choice_chip_tab/choice_chip_tab.dart';
import 'package:ez_badminton_admin_app/widgets/custom_expansion_panel_list/expansion_panel_list.dart'
    as custom_expansion_panel;
import 'package:ez_badminton_admin_app/widgets/badminton_court/badminton_court.dart';
import 'package:ez_badminton_admin_app/widgets/custom_input_fields/clearable_dropdown_button.dart';
import 'package:ez_badminton_admin_app/widgets/gym_floor_plan/gym_floor_plan.dart';
import 'package:ez_badminton_admin_app/widgets/leaderboard/leaderboard.dart';
import 'package:ez_badminton_admin_app/widgets/match_info/match_info.dart';
import 'package:ez_badminton_admin_app/widgets/match_label/match_label.dart';
import 'package:ez_badminton_admin_app/widgets/mouse_hover_builder/mouse_hover_builder.dart';
import 'package:ez_badminton_admin_app/widgets/tie_breaker_menu/tie_breaker_menu.dart';
import 'package:ez_badminton_admin_app/widgets/tooltip_dropdown_menu_item/tooltip_dropdown_menu_item.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/match_participant_label.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/single_eliminiation_tree.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ez_badminton_admin_app/app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:io/io.dart';
import 'package:process_run/shell.dart';
import 'package:window_manager/window_manager.dart';

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
  await windowManager.ensureInitialized();

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

      await windowManager.setSize(const Size(1500, 900));

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
      await testTournamentModeSetting(tester, l10n);
      await testDraw(tester, l10n);
      //await testSkip(tester, l10n);
      await testMatches(tester, l10n);

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
  Directory serverTestDataDir = Directory(
    '${serverWorkingDir.path}${Platform.pathSeparator}pb_test_data',
  );

  if (await serverDataDir.exists()) {
    await serverDataDir.delete(recursive: true);
  }
  if (await serverTestDataDir.exists()) {
    await copyPath(serverTestDataDir.path, serverDataDir.path);
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

Future<void> testSkip(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  Finder inputs = find.byType(TextField);

  await tester.enterText(inputs.at(0), 'testuser');
  await tester.enterText(inputs.at(1), 'password');

  await tester.pump();

  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();

  expect(find.text(l10n.playerManagement), findsOne);

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.draw(2)),
  ));
  await tester.pumpAndSettle();
  String mensSinglesAbbr = display_strings.competitionGenderAndTypeAbbreviation(
    l10n,
    GenderCategory.male,
    CompetitionType.singles,
  );
  await tester.tap(find.ancestor(
    of: find.textContaining(mensSinglesAbbr),
    matching: find.byType(ChoiceChip),
  ));
  await tester.pumpAndSettle();
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

Future<void> testTournamentModeSetting(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.player(2)),
  ));
  await tester.pumpAndSettle();

  for ((String, String) playerName in playerNames.sublist(10)) {
    await registerPlayer(
      tester,
      l10n,
      playerName.$1,
      playerName.$2,
      playingLevel1,
      null,
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

  Finder tournamentModeButton = find.descendant(
    of: find.ancestor(
      of: find.text(display_strings.competitionGenderAndType(
        l10n,
        GenderCategory.male,
        CompetitionType.singles,
      )),
      matching: find.byType(CheckboxListTile),
    ),
    matching: find.text(l10n.assign),
  );

  await tester.tap(tournamentModeButton);
  await tester.pumpAndSettle();

  await tester.tap(find.text(l10n.pleaseChoose));
  await tester.pumpAndSettle();

  await tester.tap(find.text(l10n.roundRobin));
  await tester.pumpAndSettle();

  Finder plusButton = find.descendant(
    of: find
        .ancestor(
          of: find.text(l10n.passes),
          matching: find.byType(Row),
        )
        .first,
    matching: find.byIcon(Icons.add_circle_outline),
  );

  await tester.tap(plusButton);
  await tester.pumpAndSettle();

  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  expect(find.text(l10n.roundRobin), findsOne);

  await tester.tap(find.text(l10n.roundRobin));
  await tester.pumpAndSettle();

  await tester.tap(find.text(l10n.roundRobin));
  await tester.pumpAndSettle();

  await tester.tap(find.text(l10n.singleElimination));
  await tester.pumpAndSettle();

  Finder maxPointInput = find.descendant(
    of: find
        .ancestor(
          of: find.text(l10n.maxPoints),
          matching: find.byType(Row),
        )
        .first,
    matching: find.byType(TextFormField),
  );
  Finder pointInput = find.descendant(
    of: find
        .ancestor(
          of: find.text(l10n.winningPoints),
          matching: find.byType(Row),
        )
        .first,
    matching: find.byType(TextFormField),
  );

  await tester.enterText(maxPointInput, '20');
  await tester.pump();

  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  expect(find.text(l10n.maxPointsError), findsOne);

  await tester.enterText(pointInput, '21');
  await tester.enterText(maxPointInput, '30');
  await tester.pumpAndSettle();

  expect(find.text(l10n.maxPointsError), findsNothing);

  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  expect(find.text(l10n.competitionManagement).hitTestable(), findsOne);
  expect(find.text(l10n.singleElimination), findsOne);
}

Future<void> testDraw(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  String mensSinglesAbbr = display_strings.competitionGenderAndTypeAbbreviation(
    l10n,
    GenderCategory.male,
    CompetitionType.singles,
  );

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.draw(2)),
  ));
  await tester.pumpAndSettle();

  expect(find.text(l10n.drawManagement), findsOne);

  await tester.tap(find.ancestor(
    of: find.textContaining(mensSinglesAbbr),
    matching: find.byType(ChoiceChip),
  ));
  await tester.pumpAndSettle();

  expect(find.text(l10n.entryList), findsOne);
  expect(
    find.text(l10n.teamsReady(playerNames.length, playerNames.length)),
    findsOne,
  );
  expect(
    find.byIcon(playerStatusIcons[PlayerStatus.notAttending]!),
    findsNothing,
  );

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.player(2)),
  ));
  await tester.pumpAndSettle();
  await openPlayerPanel(tester, l10n, playerNames.last.$1, playerNames.last.$2);
  await tester.tap(find.byTooltip(l10n.changeStatus).hitTestable());
  await tester.pumpAndSettle();
  await tester.tap(
    find.text(l10n.playerStatus(PlayerStatus.injured.toString())),
  );
  await tester.pumpAndSettle();

  expect(
    find.byIcon(playerStatusIcons[PlayerStatus.injured]!),
    findsExactly(2),
  );

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.draw(2)),
  ));
  await tester.pumpAndSettle();

  Finder scrollable = find
      .ancestor(
        of: find.byType(DragTarget<int>),
        matching: find.bySubtype<Scrollable>(),
      )
      .first;

  await tester.scrollUntilVisible(
    find.byIcon(playerStatusIcons[PlayerStatus.notAttending]!),
    120,
    scrollable: scrollable,
  );

  expect(
    find.text(l10n.teamsReady(playerNames.length - 1, playerNames.length)),
    findsOne,
  );
  expect(find.text(l10n.singleElimination), findsOne);

  await tester.tap(find.text(l10n.makeDraw));
  await tester.pumpAndSettle();

  expect(find.text(l10n.roundOfN('32')), findsOne);
  expect(find.text(l10n.roundOfN('16')), findsOne);
  expect(find.text(l10n.roundOfN('8')), findsOne);
  expect(find.text(l10n.roundOfN('4')), findsOne);
  expect(find.text(l10n.roundOfN('2')), findsOne);

  expect(find.text(l10n.bye), findsOne);

  for ((String, String) playerName
      in playerNames.sublist(0, playerNames.length - 1)) {
    expect(
      find.descendant(
        of: find.byType(MatchParticipantLabel),
        matching: find.text(
          '${playerName.$1} ${playerName.$2}',
          findRichText: true,
        ),
      ),
      findsAny,
    );
  }
  expect(
    find.descendant(
      of: find.byType(MatchParticipantLabel),
      matching: find.text(
        '${playerNames.last.$1} ${playerNames.last.$2}',
        findRichText: true,
      ),
    ),
    findsNothing,
  );

  expect(find.byType(MatchupCard), findsExactly(31));

  await tester.tap(find.byTooltip(l10n.deleteSubject(l10n.draw(1))));
  await tester.pumpAndSettle();

  expect(find.text(l10n.deleteSubject(l10n.draw(1))), findsOne);

  await tester.tap(find.text(l10n.confirm));
  await tester.pumpAndSettle();

  expect(find.text(l10n.makeDraw), findsOne);

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.player(2)),
  ));
  await tester.pumpAndSettle();
  await openPlayerPanel(tester, l10n, playerNames.last.$1, playerNames.last.$2);
  await tester.tap(find.byTooltip(l10n.changeStatus).hitTestable());
  await tester.pumpAndSettle();
  await tester.tap(
    find
        .text(l10n.playerStatus(PlayerStatus.attending.toString()))
        .hitTestable(),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.draw(2)),
  ));
  await tester.pumpAndSettle();

  expect(
    find.text(l10n.teamsReady(playerNames.length, playerNames.length)),
    findsOne,
  );

  for ((String, String) playerName in playerNames.take(4)) {
    await seedPlayer(tester, l10n, '${playerName.$1} ${playerName.$2}');
  }

  Finder dragHandles = find.byIcon(Icons.drag_indicator);

  await tester.scrollUntilVisible(
    find.text('1'),
    -500,
    maxScrolls: 2,
    scrollable: scrollable,
  );
  await tester.pump();

  await tester.drag(
    dragHandles.first,
    const Offset(0, 80),
  );
  await tester.pumpAndSettle();

  Finder firstSeed = find.descendant(
    of: find.ancestor(
      of: find.text('${playerNames[1].$1} ${playerNames[1].$2}'),
      matching: find.byType(DragTarget<int>),
    ),
    matching: find.text('1'),
  );
  Finder secondSeed = find.descendant(
    of: find.ancestor(
      of: find.text('${playerNames[0].$1} ${playerNames[0].$2}'),
      matching: find.byType(DragTarget<int>),
    ),
    matching: find.text('2'),
  );
  Finder thirdSeed = find.descendant(
    of: find.ancestor(
      of: find.text('${playerNames[2].$1} ${playerNames[2].$2}'),
      matching: find.byType(DragTarget<int>),
    ),
    matching: find.text('3/4'),
  );
  Finder fourthSeed = find.descendant(
    of: find.ancestor(
      of: find.text('${playerNames[3].$1} ${playerNames[3].$2}'),
      matching: find.byType(DragTarget<int>),
    ),
    matching: find.text('3/4'),
  );

  expect(
    [firstSeed, secondSeed, thirdSeed, fourthSeed],
    [findsOne, findsOne, findsOne, findsOne],
  );

  await tester.tap(find.text(l10n.makeDraw));
  await tester.pumpAndSettle();

  firstSeed = find.ancestor(
    of: find.text(
      '${playerNames[1].$1} ${playerNames[1].$2}',
      findRichText: true,
    ),
    matching: find.byType(MatchParticipantLabel),
  );
  Element highestLabel = findHighestMatchParticipantLabel();
  expect(firstSeed.evaluate().single == highestLabel, isTrue);

  Finder dragHandle1 = find.descendant(
    of: find.ancestor(
      of: find.text(
        '${playerNames[1].$1} ${playerNames[1].$2}',
        findRichText: true,
      ),
      matching: find.byType(MatchParticipantLabel),
    ),
    matching: find.byIcon(Icons.drag_indicator),
  );
  Finder dragHandle2 = find.descendant(
    of: find.ancestor(
      of: find.text(
        '${playerNames[0].$1} ${playerNames[0].$2}',
        findRichText: true,
      ),
      matching: find.byType(MatchParticipantLabel),
    ),
    matching: find.byIcon(Icons.drag_indicator),
  );

  Offset dragOffset =
      getGlobalBoundsOfElement(dragHandle2.evaluate().single).center -
          getGlobalBoundsOfElement(dragHandle1.evaluate().single).center;

  await tester.drag(dragHandle1, dragOffset);
  await tester.pumpAndSettle();

  secondSeed = find.ancestor(
    of: find.text(
      '${playerNames[0].$1} ${playerNames[0].$2}',
      findRichText: true,
    ),
    matching: find.byType(MatchParticipantLabel),
  );
  highestLabel = findHighestMatchParticipantLabel();
  expect(secondSeed.evaluate().single == highestLabel, isTrue);

  await tester.tap(find.byTooltip(l10n.redraw));
  await tester.pumpAndSettle();

  expect(find.text(l10n.redraw), findsOne);

  await tester.tap(find.text(l10n.confirm));
  await tester.pumpAndSettle();

  firstSeed = find.ancestor(
    of: find.text(
      '${playerNames[1].$1} ${playerNames[1].$2}',
      findRichText: true,
    ),
    matching: find.byType(MatchParticipantLabel),
  );
  highestLabel = findHighestMatchParticipantLabel();
  expect(firstSeed.evaluate().single == highestLabel, isTrue);

  await drawTournamentMode(tester, l10n, l10n.roundRobin);
  Finder participants = find.descendant(
    of: find
        .ancestor(
          of: find.text(l10n.participant(2)),
          matching: find.byType(Card),
        )
        .first,
    matching: find.byType(MatchParticipantLabel),
  );
  expect(participants, findsExactly(playerNames.length));

  await drawTournamentMode(tester, l10n, l10n.groupKnockout);
  Finder group1 = find
      .ancestor(
        of: find.text(l10n.groupNumber(1)),
        matching: find.byType(Card),
      )
      .first;
  Finder group2 = find
      .ancestor(
        of: find.text(l10n.groupNumber(2)),
        matching: find.byType(Card),
      )
      .first;
  Finder group3 = find
      .ancestor(
        of: find.text(l10n.groupNumber(3)),
        matching: find.byType(Card),
      )
      .first;
  Finder group4 = find
      .ancestor(
        of: find.text(l10n.groupNumber(4)),
        matching: find.byType(Card),
      )
      .first;

  expect(
    [group1, group2, group3, group4],
    [findsOne, findsOne, findsOne, findsOne],
  );

  expect(
    find.descendant(
      of: group1,
      matching: find.text(
        '${playerNames[1].$1} ${playerNames[1].$2}',
        findRichText: true,
      ),
    ),
    findsOne,
  );
  expect(
    find.descendant(
      of: group2,
      matching: find.text(
        '${playerNames[0].$1} ${playerNames[0].$2}',
        findRichText: true,
      ),
    ),
    findsOne,
  );
  expect(find.byType(MatchupCard), findsExactly(7));

  for (int group = 1; group <= 4; group += 1) {
    expect(find.text(l10n.groupQualification(group, 1)), findsOne);
    expect(find.text(l10n.groupQualification(group, 2)), findsOne);
  }

  await drawTournamentMode(tester, l10n, l10n.doubleElimination);
  expect(find.byType(MatchupCard), findsExactly(62));

  await drawTournamentMode(tester, l10n, l10n.consolationElimination);
  expect(find.byType(MatchupCard), findsExactly(32));
  expect(find.text(l10n.matchForThrid), findsOne);
}

Future<void> testMatches(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  await tester.tap(find.byTooltip(l10n.deleteSubject(l10n.draw(1))));
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.confirm));
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.changeTournamentMode));
  await tester.pumpAndSettle();

  Finder modeSelector = find.descendant(
    of: find.byType(TournametModeSelector),
    matching: find.bySubtype<DropdownButton>(),
  );

  await tester.tap(modeSelector);
  await tester.pumpAndSettle();

  Finder modeItem = find.descendant(
    of: find.bySubtype<TooltipDropdownMenuItem>(),
    matching: find.text(l10n.groupKnockout),
  );

  await tester.tap(modeItem);
  await tester.pumpAndSettle();

  Finder addButtons = find.byIcon(Icons.add_circle_outline);

  for (int i = 0; i < 4; i += 1) {
    await tester.tap(addButtons.first);
    await tester.pump();
  }
  for (int i = 0; i < 2; i += 1) {
    await tester.tap(addButtons.at(1));
    await tester.pump();
  }

  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.makeDraw));
  await tester.pumpAndSettle();

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.competition(2)),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip(l10n.startTournament));
  await tester.pumpAndSettle();

  expect(find.text(l10n.startTournament).hitTestable(), findsOne);

  await tester.tap(find.text(l10n.confirm));
  await tester.pumpAndSettle();

  expect(find.byIcon(Icons.stop), findsOne);

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.match(2)),
  ));
  await tester.pumpAndSettle();

  expect(find.text(l10n.nOpenCourts(12)), findsOne);
  expect(find.byIcon(BadmintonIcons.badminton_court_outline), findsAny);

  await tester.tap(find.text(l10n.settings).hitTestable());
  await tester.pumpAndSettle();

  Finder autoQueueButton = find.ancestor(
    of: find.text(l10n.queueMode(QueueMode.auto.toString())),
    matching: find.byType(RadioListTile<QueueMode>),
  );

  await tester.tap(autoQueueButton);
  await tester.pumpAndSettle(const Duration(milliseconds: 300));

  //await tester.enterText(find.byType(TextField), '3');
  //await tester.pumpAndSettle();

  Finder callOutList = find.descendant(
    of: find.ancestor(
      of: find.text(l10n.readyForCallout),
      matching: find.byType(MatchQueueList),
    ),
    matching: find.byType(SliverList),
  );

  int listLength = ((tester.widget(callOutList) as SliverList).delegate
          as SliverChildListDelegate)
      .children
      .length;
  expect(listLength, 12);
  expect(find.byIcon(Icons.hourglass_top_rounded), findsExactly(4));

  Finder autoCourtButton = find.ancestor(
    of: find.text(l10n.queueMode(
      QueueMode.autoCourtAssignment.toString(),
    )),
    matching: find.byType(RadioListTile<QueueMode>),
  );

  await tester.tap(autoCourtButton);
  await tester.pumpAndSettle();

  expect(find.text('AUTO'), findsAny);

  Finder backToWaitListButton = find.byTooltip(l10n.backToWaitList);

  while (backToWaitListButton.evaluate().isNotEmpty) {
    await tester.tap(backToWaitListButton.first);
    await tester.pumpAndSettle();
  }
  expect(callOutList, findsNothing);

  Finder assignmentButtons =
      find.byIcon(BadmintonIcons.badminton_court_outline);

  for (int i = 0; i < 3; i += 1) {
    await tester.tap(assignmentButtons.at(0));
    await tester.pumpAndSettle();
  }
  listLength = ((tester.widget(callOutList) as SliverList).delegate
          as SliverChildListDelegate)
      .children
      .length;
  expect(listLength, 3);

  await tester.tap(find.text(l10n.callOutAll));
  await tester.pumpAndSettle();

  for (int i = 0; i < 3; i += 1) {
    await tester.tap(find.text(l10n.matchCalledOut));
    await tester.pumpAndSettle();
  }

  expect(callOutList, findsNothing);

  Finder runningMatchList = find.descendant(
    of: find.ancestor(
      of: find.text(l10n.runningMatches),
      matching: find.byType(MatchQueueList),
    ),
    matching: find.byType(SliverList),
  );

  listLength = ((tester.widget(runningMatchList) as SliverList).delegate
          as SliverChildListDelegate)
      .children
      .length;
  expect(listLength, 3);

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.court(2)),
  ));
  await tester.pumpAndSettle();

  Finder gymButton = find.ancestor(
    of: find.text(hallName),
    matching: find.byType(ChoiceChipTab),
  );
  await tester.tap(gymButton);
  await tester.pumpAndSettle();

  expect(find.byType(RunningMatchInfo), findsExactly(3));

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.match(2)),
  ));
  await tester.pumpAndSettle();

  await tester.tap(find.byIcon(Icons.more_vert).first);
  await tester.pumpAndSettle();
  await tester.tap(find.ancestor(
    of: find.text(l10n.unlockCourt),
    matching: find.bySubtype<PopupMenuItem>(),
  ));
  await tester.pumpAndSettle();

  await tester.tap(find.byIcon(Icons.more_vert).at(1));
  await tester.pumpAndSettle();
  await tester.tap(find.ancestor(
    of: find.text(l10n.cancelMatch),
    matching: find.bySubtype<PopupMenuItem>(),
  ));
  await tester.pumpAndSettle();

  expect(find.text(l10n.cancelMatchConfirmation), findsOne);

  await tester.tap(find.text(l10n.confirm));
  await tester.pumpAndSettle();

  expect(find.text(l10n.matchEnded), findsOne);

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.court(2)),
  ));
  await tester.pumpAndSettle();

  expect(find.byType(RunningMatchInfo), findsExactly(2));

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.match(2)),
  ));
  await tester.pumpAndSettle();

  await tester.tap(find.byTooltip(l10n.callOutMatch));
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.matchCalledOut));
  await tester.pumpAndSettle();

  await tester.tap(find.byIcon(Icons.more_vert).first);
  await tester.pumpAndSettle();
  await tester.tap(find.ancestor(
    of: find.text(l10n.cancelMatch),
    matching: find.bySubtype<PopupMenuItem>(),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.confirm));
  await tester.pumpAndSettle();

  await tester.tap(find.byTooltip(l10n.callOutMatch));
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.matchCalledOut));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField), '0');
  await tester.pumpAndSettle();

  Finder scoreButtons = find.byIcon(Icons.scoreboard_outlined);
  Finder scoreInputs = find.descendant(
    of: find.byType(FocusTraversalOrder),
    matching: find.byType(TextField),
  );

  await tester.tap(scoreButtons.first);
  await tester.pumpAndSettle();

  await tester.enterText(scoreInputs.at(0), '10');
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump();

  expect(find.text('21'), findsOne);

  await tester.enterText(scoreInputs.at(4), '23');
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump();

  expect(find.text('25'), findsOne);

  await tester.enterText(scoreInputs.at(2), '29');
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump();

  expect(find.text('30'), findsOne);

  await tester.sendKeyEvent(LogicalKeyboardKey.enter);
  await tester.pumpAndSettle();

  await tester.tap(scoreButtons.first);
  await tester.pumpAndSettle();

  await enterScore(tester, l10n, getScore());

  await tester.tap(scoreButtons.first);
  await tester.pumpAndSettle();

  await enterScore(tester, l10n, getScore());

  String group = l10n.groupNumber(0).split(' ').first;
  Finder groupPhaseMatches = find.descendant(
    of: find.ancestor(
      of: find.textContaining(group),
      matching: find.byType(WaitingMatch),
    ),
    matching: find.byType(ElevatedButton),
  );

  while (groupPhaseMatches.evaluate().isNotEmpty) {
    await tester.tap(groupPhaseMatches.first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(l10n.callOutMatch));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.matchCalledOut));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.scoreboard_outlined));
    await tester.pumpAndSettle();

    await enterScore(tester, l10n, getScore());
  }

  expect(find.text(l10n.tournamentProgressBlocked), findsOne);

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.result(2)),
  ));
  await tester.pumpAndSettle();

  String mensSinglesAbbr = display_strings.competitionGenderAndTypeAbbreviation(
    l10n,
    GenderCategory.male,
    CompetitionType.singles,
  );
  await tester.tap(find.ancestor(
    of: find.textContaining(mensSinglesAbbr),
    matching: find.byType(ChoiceChip),
  ));
  await tester.pumpAndSettle();

  expect(find.byType(TieBreakerButton), findsExactly(2));

  for (int i = 1; i <= 8; i += 1) {
    expect(find.text(l10n.groupQualification(i, 1)), findsOne);
  }
  expect(find.text(l10n.groupQualification('?', 2)), findsExactly(2));
  expect(find.text(l10n.bye), findsExactly(6));

  await tester.tap(find.byType(TieBreakerButton).first);
  await tester.pumpAndSettle();

  expect(
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text(l10n.breakTie),
    ),
    findsOne,
  );

  await tester.tap(find.text(l10n.save));
  await tester.pumpAndSettle();

  expect(find.text(l10n.editTieBreaker), findsOne);

  await tester.tap(find.byType(TieBreakerButton).at(1));
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.save));
  await tester.pumpAndSettle();

  expect(find.text(l10n.editTieBreaker), findsExactly(2));
  expect(find.byType(TieBreakerButton), findsExactly(3));
  expect(find.text(l10n.crossGroupTies(1)), findsOne);
  for (int i = 1; i <= 8; i += 1) {
    expect(find.text(l10n.groupQualification(i, 1)), findsOne);
  }
  expect(find.text(l10n.groupQualification('?', 2)), findsExactly(2));
  expect(find.text(l10n.bye), findsExactly(6));

  await tester.tap(find.byType(TieBreakerButton).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.save));
  await tester.pumpAndSettle();

  for (int i = 1; i <= 8; i += 1) {
    expect(find.text(l10n.groupQualification(i, 1)), findsNothing);
  }
  expect(find.text(l10n.groupQualification('?', 2)), findsNothing);
  expect(find.text(l10n.bye), findsExactly(6));
  expect(find.byIcon(Icons.warning_rounded), findsNothing);
  expect(find.text(l10n.editTieBreaker), findsExactly(3));

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.player(2)),
  ));
  await tester.pumpAndSettle();

  await openPlayerPanel(tester, l10n, playerNames[0].$1, playerNames[0].$2);
  await tester.tap(find.byTooltip(l10n.changeStatus).hitTestable());
  await tester.pumpAndSettle();
  await tester.tap(
    find.text(l10n.playerStatus(PlayerStatus.injured.toString())).hitTestable(),
  );
  await tester.pump(const Duration(milliseconds: 200));

  expect(find.text(l10n.playerWithdrawal), findsOne);
  expect(
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(MatchupLabel),
    ),
    findsExactly(3),
  );

  await tester.tap(find.text(l10n.confirm));
  await tester.pumpAndSettle();
  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.result(2)),
  ));
  await tester.pumpAndSettle();

  expect(find.byIcon(Icons.info_outline), findsExactly(3));
  expect(
    find.descendant(
      of: find.byType(SingleEliminationTree),
      matching: find.text(
        '${playerNames[0].$1} ${playerNames[0].$2}',
        findRichText: true,
      ),
    ),
    findsNothing,
  );

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.player(2)),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip(l10n.changeStatus).hitTestable());
  await tester.pumpAndSettle();
  await tester.tap(
    find
        .text(l10n.playerStatus(PlayerStatus.attending.toString()))
        .hitTestable(),
  );
  await tester.pump(const Duration(milliseconds: 200));

  expect(find.text(l10n.playerReentering), findsOne);
  expect(find.text(l10n.playerCannotReenter), findsNothing);
  expect(
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(MatchupLabel),
    ),
    findsExactly(3),
  );

  await tester.tap(find.text(l10n.confirm));
  await tester.pumpAndSettle();
  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.result(2)),
  ));
  await tester.pumpAndSettle();

  expect(find.byIcon(Icons.info_outline), findsNothing);
  expect(
    find.descendant(
      of: find.byType(SingleEliminationTree),
      matching: find.text(
        '${playerNames[0].$1} ${playerNames[0].$2}',
        findRichText: true,
      ),
    ),
    findsExactly(2),
  );

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.match(2)),
  ));
  await tester.pumpAndSettle();

  Finder eliminationMatches = find.descendant(
    of: find.byType(WaitingMatch),
    matching: find.byType(ElevatedButton),
  );

  await tester.tap(eliminationMatches.first);
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip(l10n.callOutMatch));
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.matchCalledOut));
  await tester.pumpAndSettle();

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.player(2)),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip(l10n.changeStatus).hitTestable());
  await tester.pumpAndSettle();
  await tester.tap(
    find
        .text(l10n.playerStatus(PlayerStatus.disqualified.toString()))
        .hitTestable(),
  );
  await tester.pump(const Duration(milliseconds: 200));

  expect(
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(MatchupLabel),
    ),
    findsOne,
  );

  await tester.tap(find.text(l10n.confirm));
  await tester.pumpAndSettle();
  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.result(2)),
  ));
  await tester.pumpAndSettle();

  expect(find.byIcon(Icons.info_outline), findsOne);
  expect(
    find.descendant(
      of: find.byType(SingleEliminationTree),
      matching: find.text(
        '${playerNames[0].$1} ${playerNames[0].$2}',
        findRichText: true,
      ),
    ),
    findsExactly(2),
  );

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.player(2)),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip(l10n.changeStatus).hitTestable());
  await tester.pumpAndSettle();
  await tester.tap(
    find
        .text(l10n.playerStatus(PlayerStatus.attending.toString()))
        .hitTestable(),
  );
  await tester.pump(const Duration(milliseconds: 200));

  expect(find.text(l10n.playerReentering), findsOne);
  expect(find.text(l10n.playerCannotReenter), findsNothing);
  expect(
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(MatchupLabel),
    ),
    findsOne,
  );

  await tester.tap(find.text(l10n.confirm));
  await tester.pumpAndSettle();
  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.result(2)),
  ));
  await tester.pumpAndSettle();

  expect(find.byIcon(Icons.info_outline), findsNothing);
  expect(
    find.descendant(
      of: find.byType(SingleEliminationTree),
      matching: find.text(
        '${playerNames[0].$1} ${playerNames[0].$2}',
        findRichText: true,
      ),
    ),
    findsExactly(2),
  );

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.match(2)),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.scoreboard_outlined));
  await tester.pumpAndSettle();

  await enterScore(tester, l10n, getScore());

  while (eliminationMatches.evaluate().isNotEmpty) {
    await tester.tap(eliminationMatches.first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(l10n.callOutMatch));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.matchCalledOut));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.scoreboard_outlined));
    await tester.pumpAndSettle();

    await enterScore(tester, l10n, getScore());
  }

  await tester.tap(find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.result(2)),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.leaderboard));
  await tester.pumpAndSettle();

  Finder rankNumbers = find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(RankNumber),
  );
  Finder leaderboardEntries = find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(MatchParticipantLabel),
  );

  expect(
    find.descendant(of: rankNumbers.at(0), matching: find.text('1.')),
    findsOne,
  );
  expect(
    find.descendant(
      of: leaderboardEntries.at(0),
      matching: find.text(
        '${playerNames[0].$1} ${playerNames[0].$2}',
        findRichText: true,
      ),
    ),
    findsOne,
  );
  expect(
    find.descendant(of: rankNumbers.at(1), matching: find.text('2.')),
    findsOne,
  );
  expect(
    find.descendant(
      of: leaderboardEntries.at(1),
      matching: find.text(
        '${playerNames[1].$1} ${playerNames[1].$2}',
        findRichText: true,
      ),
    ),
    findsOne,
  );
  expect(
    find.descendant(of: rankNumbers.at(2), matching: find.text('3.')),
    findsOne,
  );
  expect(
    find.descendant(of: rankNumbers.at(3), matching: find.byType(Text)),
    findsNothing,
  );

  await tester.tap(find.text(l10n.confirm));
  await tester.pumpAndSettle();
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
    200,
    scrollable: playerList,
    maxScrolls: 20,
  );
  await tester.scrollUntilVisible(
    playerName,
    -200,
    scrollable: playerList,
    maxScrolls: 20,
  );
  await tester.pump();

  expect(playerName, findsOne);
  expect(playerEditButton, findsOne);
}

Future<void> seedPlayer(
  WidgetTester tester,
  AppLocalizations l10n,
  String playerName,
) async {
  Finder scrollable = find
      .ancestor(
        of: find.byType(DragTarget<int>),
        matching: find.bySubtype<Scrollable>(),
      )
      .first;

  Finder seedButton = find
      .descendant(
        of: find.ancestor(
          of: find.text(playerName),
          matching: find.byType(DragTarget<int>),
        ),
        matching: find.byIcon(BadmintonIcons.seedling),
      )
      .hitTestable();

  try {
    await tester.scrollUntilVisible(
      seedButton,
      150,
      scrollable: scrollable,
    );
  } catch (_) {}
  try {
    await tester.scrollUntilVisible(
      seedButton,
      -150,
      scrollable: scrollable,
    );
  } catch (_) {}
  await tester.tap(seedButton);
  await tester.pumpAndSettle();

  Finder unseedButton = find
      .descendant(
        of: find.ancestor(
          of: find.text(playerName),
          matching: find.byType(DragTarget<int>),
        ),
        matching: find.byIcon(BadmintonIcons.crossed_seedling),
      )
      .hitTestable();
  await tester.scrollUntilVisible(
    unseedButton,
    -99999,
    scrollable: scrollable,
    maxScrolls: 1,
  );
  await tester.pumpAndSettle();

  expect(unseedButton, findsOne);
}

Future<void> drawTournamentMode(
  WidgetTester tester,
  AppLocalizations l10n,
  String tournamentMode,
) async {
  await tester.tap(find.byTooltip(l10n.deleteSubject(l10n.draw(1))));
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.confirm));
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.changeTournamentMode));
  await tester.pumpAndSettle();

  Finder modeSelector = find.descendant(
    of: find.byType(TournametModeSelector),
    matching: find.bySubtype<DropdownButton>(),
  );

  await tester.tap(modeSelector);
  await tester.pumpAndSettle();

  Finder modeItem = find.descendant(
    of: find.bySubtype<TooltipDropdownMenuItem>(),
    matching: find.text(tournamentMode),
  );

  await tester.tap(modeItem);
  await tester.pumpAndSettle();
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
  await tester.tap(find.text(l10n.makeDraw));
  await tester.pumpAndSettle();
}

List<int> getScore() {
  Finder playerNameLabels = find.descendant(
    of: find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(MatchParticipantLabel),
    ),
    matching: find.byType(RichText),
  )..evaluate();

  String playerName2 = (playerNameLabels.found.elementAt(1).widget as RichText)
      .text
      .toPlainText();

  List<String> defaultWinners = [
    '${playerNames[0].$1} ${playerNames[0].$2}',
    '${playerNames[1].$1} ${playerNames[1].$2}',
  ];

  if (defaultWinners.contains(playerName2)) {
    return [10, 21, 10, 21];
  }

  return [21, 10, 21, 10];
}

Future<void> enterScore(
  WidgetTester tester,
  AppLocalizations l10n,
  List<int> score,
) async {
  Finder scoreInputs = find.descendant(
    of: find.byType(FocusTraversalOrder),
    matching: find.byType(TextField),
  );

  const List<int> inputOrder = [0, 3, 1, 4, 2, 5];

  for ((int, int) scoreEntry in score.indexed) {
    int inputIndex = inputOrder[scoreEntry.$1];
    int points = scoreEntry.$2;

    await tester.enterText(scoreInputs.at(inputIndex), '$points');
  }
  await tester.pumpAndSettle();

  Finder submitButton = find.ancestor(
    of: find.text(l10n.enterResult),
    matching: find.byType(ElevatedButton),
  );

  await tester.tap(submitButton);
  await tester.pumpAndSettle();
}
