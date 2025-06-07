// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get connectingToServer => 'Verbinde mit Server';

  @override
  String get login => 'Anmelden';

  @override
  String get logout => 'Abmelden';

  @override
  String get signUp => 'Registrieren';

  @override
  String get username => 'Benutzername';

  @override
  String get password => 'Passwort';

  @override
  String get passwordConfirmation => 'Passwort bestätigen';

  @override
  String get eMail => 'E-Mail';

  @override
  String get invalidUsername => 'Bitte Benutzernamen eingeben';

  @override
  String get invalidPassword => 'Bitte Passwort eingeben';

  @override
  String get invalidPasswordConfirmation => 'Passwort stimmt nicht überein';

  @override
  String get passwordTooShort => 'Bitte min. 5 Zeichen verwenden';

  @override
  String loginError(String errorCode) {
    String _temp0 = intl.Intl.selectLogic(
      errorCode,
      {
        '400': 'Ungültige Anmeldeinformationen',
        'other': 'Unbekannter Fehler beim Anmelden',
      },
    );
    return '$_temp0';
  }

  @override
  String get overAge => 'Über';

  @override
  String get underAge => 'Unter';

  @override
  String get overAgeAbbreviated => 'O';

  @override
  String get underAgeAbbreviated => 'U';

  @override
  String ageGroupAbbreviated(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'over': 'O',
        'under': 'U',
        'other': 'other',
      },
    );
    return '$_temp0';
  }

  @override
  String ageGroup(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Altersklassen',
      one: 'Altersklasse',
    );
    return '$_temp0';
  }

  @override
  String get name => 'Name';

  @override
  String get club => 'Verein';

  @override
  String get registrations => 'Meldungen';

  @override
  String get age => 'Alter';

  @override
  String get gender => 'Geschlecht';

  @override
  String playingLevel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Spielklassen',
      one: 'Spielklasse',
    );
    return '$_temp0';
  }

  @override
  String competition(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Disziplinen',
      one: 'Disziplin',
    );
    return '$_temp0';
  }

  @override
  String baseCompetition(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Basisdisziplinen',
      one: 'Basisdisziplin',
    );
    return '$_temp0';
  }

  @override
  String court(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Felder',
      one: 'Feld',
    );
    return '$_temp0';
  }

  @override
  String draw(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Auslosungen',
      one: 'Auslosung',
    );
    return '$_temp0';
  }

  @override
  String match(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Spiele',
      one: 'Spiel',
    );
    return '$_temp0';
  }

  @override
  String get women => 'Damen';

  @override
  String get men => 'Herren';

  @override
  String get womenAbbreviated => 'D';

  @override
  String get menAbbreviated => 'H';

  @override
  String get playerSearchHint => 'Name/Verein suchen';

  @override
  String genderCategory(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'female': 'Damen',
        'male': 'Herren',
        'mixed': 'Mixed',
        'other': 'Frei',
      },
    );
    return '$_temp0';
  }

  @override
  String competitionType(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'doubles': 'Doppel',
        'mixed': 'Mixed',
        'singles': 'Einzel',
        'other': 'Sonstige',
      },
    );
    return '$_temp0';
  }

  @override
  String competitionSuffix(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'doubles': 'doppel',
        'mixed': '',
        'singles': 'einzel',
        'other': 'Sonstige',
      },
    );
    return '$_temp0';
  }

  @override
  String competitionTypeAbbreviated(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'doubles': 'D',
        'mixed': 'MX',
        'singles': 'E',
        'other': 'Sonst.',
      },
    );
    return '$_temp0';
  }

  @override
  String get add => 'Hinzufügen';

  @override
  String get firstName => 'Vorname';

  @override
  String get lastName => 'Nachname';

  @override
  String player(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Spieler',
    );
    return '$_temp0';
  }

  @override
  String get playerAndRegistrations => 'Spieler und Meldungen';

  @override
  String get playerManagement => 'Spieler verwalten';

  @override
  String get competitionManagement => 'Disziplinen verwalten';

  @override
  String get courtManagement => 'Felder verwalten';

  @override
  String get drawManagement => 'Auslosungen verwalten';

  @override
  String get birthday => 'Geburtstag';

  @override
  String get dateOfBirth => 'Geburtsdatum';

  @override
  String get personalData => 'Zur Person';

  @override
  String get registeredCompetitions => 'Gemeldete Disziplinen';

  @override
  String get pleaseFillIn => 'Bitte ausfüllen';

  @override
  String get formatError => 'Ungültiges Format';

  @override
  String get playerListLoadingError => 'Konnte die Spielerliste nicht laden';

  @override
  String get playerEditorLoadingError => 'Konnte den Spielereditor nicht laden';

  @override
  String get competitionListLoadingError =>
      'Konnte die Liste der Disziplinen nicht laden';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get save => 'Speichern';

  @override
  String get saveError => 'Speichern fehlgeschlagen';

  @override
  String get addRegistration => 'Neue Meldung';

  @override
  String get deleteRegistration => 'Meldung löschen';

  @override
  String get optional => 'Optional';

  @override
  String get partner => 'Partner';

  @override
  String get register => 'Melden';

  @override
  String get registerPartner => 'Partner melden';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get continueMsg => 'Fortfahren';

  @override
  String get registrationWarning => 'Hinweise zur Meldung';

  @override
  String ageGroupWarning(Object age, Object ageGroup) {
    return 'Gemeldete Altersklasse ist $ageGroup, Spieler ist $age.';
  }

  @override
  String playingLevelWarning(Object playerLevel, Object playingLevel) {
    return 'Gemeldete Spielklasse ist $playingLevel, Spieler ist in $playerLevel.';
  }

  @override
  String genderWarning(Object conflictingGender, Object presentGender) {
    return 'Spieler ist schon für eine $presentGender-Disziplin gemeldet. Meldung ist eine $conflictingGender-Disziplin.';
  }

  @override
  String withPartner(Object partnerName) {
    return 'mit $partnerName';
  }

  @override
  String get noPartner => 'kein Partner gemeldet';

  @override
  String get notes => 'Notizen';

  @override
  String get unsavedChanges => 'Ungesicherte Änderungen';

  @override
  String get dismissChanges => 'Verwerfen';

  @override
  String get expand => 'Ausklappen';

  @override
  String get status => 'Status';

  @override
  String bulkEditStatus(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Status von $count Spielern bearbeiten',
      one: 'Status von 1 Spieler bearbeiten',
    );
    return '$_temp0';
  }

  @override
  String get none => 'keine';

  @override
  String playerStatus(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'notAttending': 'Nicht anwesend',
        'attending': 'Anwesend',
        'forfeited': 'Aufgegeben',
        'injured': 'Verletzt',
        'disqualified': 'Disqualifiziert',
        'other': 'Sonst.',
      },
    );
    return '$_temp0';
  }

  @override
  String get changeStatus => 'Status ändern';

  @override
  String get confirmAttendance => 'Anwesenheit bestätigen';

  @override
  String get done => 'Fertig';

  @override
  String get searchPartner => 'Partner suchen';

  @override
  String get partnerNeeded => 'Partner gesucht';

  @override
  String get category => 'Kategorie';

  @override
  String get clearFilter => 'Filter löschen';

  @override
  String get deletePlayer => 'Spieler löschen';

  @override
  String get reallyDeletePlayer => 'Spieler wirklich löschen?';

  @override
  String get confirm => 'Bestätigen';

  @override
  String nPlayersShown(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Spieler angezeigt',
    );
    return '$_temp0';
  }

  @override
  String ofN(Object number) {
    return 'von $number';
  }

  @override
  String nSubjectsSelected(num count, Object subject) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count $subject ausgewählt',
      zero: 'Keine $subject ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String categorizationHint(Object category) {
    return 'Kategorisierung der Disziplinen in $category. Die selbe Disziplin (z.B. Mixed) kann so mehrfach für verschiedene Spielergruppen ausgetragen werden.';
  }

  @override
  String get activatePlayingLevels => 'Spielklassen verwenden';

  @override
  String get activateAgeGroups => 'Altersklassen verwenden';

  @override
  String get categorizationCantBeChanged =>
      'Die Kategorisierung kann bei laufendem Turnier nicht geändert werden';

  @override
  String categorizationCantBeEdited(Object category) {
    return '$category können bei laufendem Turnier nicht hinzugefügt oder gelöscht werden';
  }

  @override
  String editSubject(Object subject) {
    return '$subject bearbeiten';
  }

  @override
  String addSubject(Object subject) {
    return '$subject hinzufügen';
  }

  @override
  String deleteSubject(Object subject) {
    return '$subject löschen';
  }

  @override
  String deleteSubjectQuestion(Object subject) {
    return '$subject löschen?';
  }

  @override
  String nameSubject(Object subject) {
    return '$subject benennen';
  }

  @override
  String get reorder => 'Umordnen';

  @override
  String get rename => 'Umbenennen';

  @override
  String renameSubject(Object subject) {
    return '$subject umbenennen';
  }

  @override
  String get chooseCompetitions => 'Basisdisziplinen wählen';

  @override
  String get chooseCategoriesAndCompetitions =>
      'Kategorien und Basisdisziplinen wählen';

  @override
  String newCategories(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neue Kategorien',
      one: '1 neue Kategorie',
      zero: 'Keine neuen Kategorien',
    );
    return '$_temp0';
  }

  @override
  String newCompetitions(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neue Disziplinen',
      one: '1 neue Disziplin',
      zero: 'Keine neuen Disziplinen',
    );
    return '$_temp0';
  }

  @override
  String totalNewCompetitions(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Insgesamt $count neue Disziplinen',
      one: 'Insgesamt 1 neue Disziplin',
      zero: 'Keine neuen Disziplinen',
    );
    return '$_temp0';
  }

  @override
  String competitionAddingTooltip(
      Object baseCompetitionCount, Object categories, Object categoryCount) {
    return 'Du hast $categoryCount $categories gewählt in denen jeweils für $baseCompetitionCount der Basisdisziplinen gemeldet werden kann.';
  }

  @override
  String combinationsOf(Object firstSubject, Object secondSubject) {
    return 'Kombinationen aus $firstSubject und $secondSubject';
  }

  @override
  String get categoryAlreadyExists =>
      'Für diese Kategorie wurden bereits alle Basisdisziplinen erstellt';

  @override
  String get competitionAlreadyExists =>
      'Diese Disziplin wurde bereits in einer der gewählten Kategorien erstellt';

  @override
  String chooseAtLeastN(num count, Object subject) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wähle min. $count $subject',
      one: 'Wähle min. eine $subject',
    );
    return '$_temp0';
  }

  @override
  String createCategories(Object category) {
    return 'Erstelle $category, um Disziplinen hinzufügen zu können!';
  }

  @override
  String get defaultPlayingLevel => 'Platzhalter-Spielklasse';

  @override
  String disableCategorization(Object categorization) {
    return '$categorization nicht mehr verwenden?';
  }

  @override
  String mergeRegistrationsWarning(Object categorization) {
    return 'Es existieren Meldungen in mehreren $categorization. Durch das Entfernen der $categorization werden die Disziplinen und ihre Meldelisten zusammengelegt.\n\nEventuell bestehende Setzplätze und Auslosungen können nicht zusammengelegt werden und gehen verloren.\n\nDies kann nicht rückgängig gemacht werden. Forfahren?';
  }

  @override
  String deleteCategoryWarning(Object category, Object categoryName) {
    return 'Durch das Löschen der $category $categoryName werden auch die entsprechenden Disziplinen gelöscht.\n\nFortfahren?';
  }

  @override
  String get selection => 'Auswahl';

  @override
  String get noSelection => 'Keine Auswahl';

  @override
  String get continueWithoutSelection => 'Ohne Auswahl fortfahren';

  @override
  String deleteAndMergeCategoryWarning(Object category, Object categoryName) {
    return 'Durch das Löschen der $category $categoryName werden auch die entsprechenden Disziplinen inkl. Meldelisten gelöscht.\nEs kann eine andere $category ausgewählt werden, in die die Meldelisten übernommen werden:';
  }

  @override
  String get deleteCompetitions => 'Disziplinen löschen?';

  @override
  String deleteCompetitionsWarning(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Die ausgewählten Disziplinen wirklich löschen?',
      one: 'Die ausgewählte Disziplin wirklich löschen?',
    );
    return '$_temp0';
  }

  @override
  String get deleteCompetitionsWithTeamsWarning =>
      'Für die Disziplinen wurden bereits Spieler gemeldet.';

  @override
  String get competitionCantBeDeleted =>
      'Laufende Disziplinen können nicht gelöscht werden';

  @override
  String get orMore => 'oder mehr';

  @override
  String get orLess => 'oder weniger';

  @override
  String get showRegistrations => 'Meldeliste anzeigen';

  @override
  String gym(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hallen',
      one: 'Halle',
    );
    return '$_temp0';
  }

  @override
  String row(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Reihen',
      one: 'Reihe',
    );
    return '$_temp0';
  }

  @override
  String column(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Spalten',
      one: 'Spalte',
    );
    return '$_temp0';
  }

  @override
  String get description => 'Beschreibung';

  @override
  String get gymFloorPlan => 'Hallenplan';

  @override
  String get directions => 'Wegbeschreibung';

  @override
  String gymFloorPlanHelpMessage(Object columns, Object rows) {
    return 'Der Plan beschreibt, wie die Felder in der Halle angeordnet sind. Es passen also maximal ${rows}x$columns Felder in die Halle. Es steht frei, welche der Felder tatsächlich genutzt werden.';
  }

  @override
  String courtN(Object n) {
    return 'Feld $n';
  }

  @override
  String get noGymnasiumSelected =>
      'Wähle eine Halle, um die Felder zu bearbeiten';

  @override
  String get addFirstGymnasium => 'Füge die erste Halle hinzu';

  @override
  String get zoom => 'Zoom';

  @override
  String get resetView => 'Ansicht zurücksetzen';

  @override
  String get deleteGymWarning =>
      'Die Halle mit allen Feldern wirklich löschen?';

  @override
  String get addAllMissingCourts => 'Alle fehlenden Felder hinzufügen';

  @override
  String get reduceHall => 'Halle verkleinern?';

  @override
  String get reduceHallWarning =>
      'Durch das Verkleinern des Hallenplans werden Felder gelöscht werden. Fortfahren?';

  @override
  String get numberCourts => 'Felder durchnummerieren';

  @override
  String get cantReduceHall => 'Halle kann nicht verkleinert werden';

  @override
  String get cantReduceHallInfo =>
      'Das Verkleinern der Halle würde Felder entfernen, auf denen aktuell ein Spiel läuft.';

  @override
  String get cantDeleteHall => 'Halle kann nicht gelöscht werden';

  @override
  String get cantDeleteHallInfo =>
      'Die Halle kann nicht gelöscht werden, da dort aktuell Spiele laufen.';

  @override
  String get countingDirection => 'Zählrichtung';

  @override
  String get rowWise => 'Reihe für Reihe';

  @override
  String get columnWise => 'Spalte für Spalte';

  @override
  String get allGyms => 'Durch alle Hallen';

  @override
  String get onlyGym => 'Nur diese Halle';

  @override
  String get emptyCourts => 'Leere Felder';

  @override
  String get skip => 'Überspringen';

  @override
  String get count => 'Mitzählen';

  @override
  String get assign => 'Festlegen';

  @override
  String get assignTournamentMode => 'Turniermodus festlegen';

  @override
  String get changeTournamentMode => 'Turniermodus ändern';

  @override
  String get tournamentModeCantBeAssigned =>
      'Turniermodus kann bei laufenden Disziplinen nicht geändert werden';

  @override
  String get roundRobin => 'Jeder gegen Jeden';

  @override
  String get singleElimination => 'KO-System';

  @override
  String get doubleElimination => 'Doppeltes KO-System';

  @override
  String get consolationElimination => 'KO-System mit Trostrunden';

  @override
  String get groupKnockout => 'Gruppensystem';

  @override
  String get roundRobinHelp =>
      'Jeder Teilnehmer spielt gegen jeden Anderen. Die einstellbare Anzahl der Durchgänge bestimmt, wie oft.';

  @override
  String get singleEliminationHelp =>
      'Ein Turnierbaum, der in einem Finale gipfelt. Um ein Spiel um Platz 3 zu bekommen oder noch mehr Plätze auszuspielen, nutze das \"KO-System mit Trostrunden\".';

  @override
  String get doubleEliminationHelp =>
      'Bei einem doppelten KO-System kommen Teilnehmer nach der ersten Niederlage in einen \"unteren\" Turnierbaum. Eine weitere Niederlage führt zum Ausscheiden. Das Finale findet zwischen dem letzten ungeschlagenen Spieler und dem Gewinner des unteren Turniernaums statt.';

  @override
  String get consolationEliminationHelp =>
      'In diesem KO-Modus können zusätzliche Trostrunden für die Verlierer der Hauptrunde angesetzt werden. Es kann eine minimale Anzahl Spiele pro Teilnehmer garantiert werden und/oder eine bestimmte Anzahl an Endplatzierungen ausgespielt werden.';

  @override
  String get groupKnockoutHelp =>
      'In einer Gruppenphase spielen alle Gruppen jeweils ein Jeder-gegen-Jeden. Die Besten jeder Gruppe qualifizieren sich für die KO-Runde.';

  @override
  String get pleaseChoose => 'Bitte wählen';

  @override
  String get tournamentMode => 'Turniermodus';

  @override
  String get seedingMode => 'Setzplätze';

  @override
  String seedingModeLabel(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'single': 'Einzeln',
        'tiered': 'Gestaffelt',
        'other': 'Sonstige',
      },
    );
    return '$_temp0';
  }

  @override
  String get singleSeedingHelp =>
      'Jeder Eintrag auf der Setzliste erhält seinen eigenen Rang.';

  @override
  String get tieredSeedingHelp =>
      '1. und 2. Setzplatz sind einzeln. Danach werden die Ränge gestaffelt: 3/4, 5/8, 9/16, etc.';

  @override
  String get passes => 'Durchgänge';

  @override
  String get roundRobinPassesHelp =>
      'Wie oft Jeder gegen Jeden spielt. 2 Durchgänge bedeuten z.B. es gibt eine Hin- und eine Rückrunde.';

  @override
  String get numGroups => 'Anzahl Gruppen';

  @override
  String get numGroupsHelp =>
      'Auf wie viele Gruppen die Teilnehmer gleichmäßig aufgeteilt werden. Manuelle Zuweisungen sind nach der Auslosung möglich.';

  @override
  String get numQualifications => 'Anzahl Qualifikationen';

  @override
  String get numQualificationsHelp =>
      'Wie viele von der Gruppenphase in die KO-Runde einziehen.';

  @override
  String get entryList => 'Starterliste/Setzliste';

  @override
  String get addToSeeds => 'Setzplatz geben';

  @override
  String get removeFromSeeds => 'Von Setzliste nehmen';

  @override
  String get noDrawCompetitionSelected =>
      'Wähle eine Disziplin, um eine Auslosung zu machen';

  @override
  String get noResultCompetitionSelected =>
      'Wähle eine Disziplin, um die Ergebnisse zu sehen';

  @override
  String get noResultsYet =>
      'Für diese Disziplin liegen noch keine Spielstände vor';

  @override
  String get noTournamentMode =>
      'Diese Disziplin hat keinen Turniermodus festgelegt';

  @override
  String get makeDraw => 'Auslosung machen';

  @override
  String get bye => 'Freilos';

  @override
  String get freeOfPlay => 'Spielfrei';

  @override
  String encounterNumber(Object number) {
    return '$number. Begegnung';
  }

  @override
  String participant(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Teilnehmer',
    );
    return '$_temp0';
  }

  @override
  String groupNumber(Object number) {
    return 'Gruppe $number';
  }

  @override
  String groupQualification(Object group, Object place) {
    return '$place. Platz, Gruppe $group';
  }

  @override
  String contestedGroupQualification(Object place) {
    return '$place. Platz, abhängig vom Gruppenergebnis';
  }

  @override
  String roundOfN(String participants) {
    String _temp0 = intl.Intl.selectLogic(
      participants,
      {
        '2': 'Finale',
        '4': 'Halbfinale',
        '8': 'Viertelfinale',
        '16': 'Achtelfinale',
        'other': '${participants}er Runde',
      },
    );
    return '$_temp0';
  }

  @override
  String roundN(Object roundNumber) {
    return 'Runde $roundNumber';
  }

  @override
  String matchN(Object matchNumber) {
    return 'Spiel $matchNumber';
  }

  @override
  String loserRoundN(Object round) {
    return 'Verlierer-$round';
  }

  @override
  String groupPhaseRoundN(Object round) {
    return 'Gruppenphase $round';
  }

  @override
  String get collapse => 'Einklappen';

  @override
  String get undoManualDraw => 'Manuelle Änderungen zurücksetzen';

  @override
  String get redraw => 'Neu auslosen';

  @override
  String get undoManualDrawWarning =>
      'Sollen die manuellen Änderungen an der Auslosung wirklich zurückgesetzt werden?\nTeilnehmer, deren Anwesenheitsstatus sich seit der letzten Auslosung geändert hat, werden entsprechend berücksichtigt.';

  @override
  String get redrawWarning =>
      'Soll die Auslosung wirklich neu gemacht werden?\nTeilnehmer, deren Anwesenheitsstatus sich seit der letzten Auslosung geändert hat, werden entsprechend berücksichtigt.';

  @override
  String get deleteDrawWarning =>
      'Soll die Auslosung wirklich gelöscht werden?\nHierdurch kann die Setzliste wieder bearbeitet werden.';

  @override
  String get seedsNotEditable =>
      'Es besteht bereits eine Auslosung, daher kann die Setzliste nicht bearbeitet werden. Lösche die Auslosung, um die Setzplätze ändern zu können.';

  @override
  String teamNotAttending(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Min. ein Spieler dieses Teams hat noch nicht den Status \'Anwesend\'. Das Team wird bei der Auslosung nicht in den Spielplan aufgenommen.',
      one:
          'Der Spieler hat noch nicht den Status \'Anwesend\'. Er wird bei der Auslosung nicht in den Spielplan aufgenommen.',
    );
    return '$_temp0';
  }

  @override
  String get teamNotComplete =>
      'Dieses Team hat nicht genug Spieler. Das Team wird bei der Auslosung nicht in den Spielplan aufgenommen.';

  @override
  String teamsReady(num ready, Object total) {
    String _temp0 = intl.Intl.pluralLogic(
      ready,
      locale: localeName,
      other: '$ready Teams bereit (von $total)',
      one: '$ready Team bereit (von $total)',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughDrawParticipants => 'Nicht genug Teams';

  @override
  String notEnoughDrawParticipantsInfo(Object count) {
    return 'Es braucht mindestens $count bereite Teams, um die Auslosung für den gegebenen Turniermodus zu machen.\nMelde mehr Teams oder ändere den Turniermodus.\n\nHinweis: Spieler müssen den Status \'Anwesend\' haben, um als bereit gezählt zu werden.';
  }

  @override
  String get drawsWillBeOverridden => 'Bestehende Auslosungen';

  @override
  String get drawsWillBeOverriddenInfo =>
      'Durch das Ändern des Turniermodus werden bestehende Auslosungen gelöscht.\n\nFortfahren?';

  @override
  String get noCompetitionsRegistrationHint =>
      'Erstelle eine Disziplin, um Meldungen machen zu können';

  @override
  String get allCompetitionsRunningHint =>
      'Alle Disziplinen wurden gestartet oder bereits gemeldet';

  @override
  String get noCompetitionsDrawHint =>
      'Keine Disziplinen.\n\nErstelle eine Disziplin und melde Teilnehmer, um eine Auslosung machen zu können.';

  @override
  String get noCompetitionsResultHint =>
      'Keine Disziplinen.\n\nErstelle eine Disziplin und starte sie, um Ergebnisse sehen zu können.';

  @override
  String get matchOperations => 'Spielbetrieb';

  @override
  String get startTournament => 'Turnier starten';

  @override
  String get startTournamentInfo =>
      'Du bist dabei das Turnier für die ausgewälten Disziplinen zu starten.\nDie Begegnungen werden daraufhin im \'Spiele\' Tab auftauchen und der Turnierbetrieb kann beginnen!';

  @override
  String get cancelTournament => 'Turnier abbrechen';

  @override
  String get cancelTournamentInfo =>
      'Das Turnier für diese Disziplin abzubrechen bedeutet, alle bisher gespielten Spiele inkl. Ergebnisse in dieser Disziplin zu LÖSCHEN. Turniermodus und Auslosung der Disziplin können daraufhin wieder bearbeitet werden. Die Löschung der Spielergebnisse ist nicht rückgängig zu machen.\n\nMöchtest du wirklich das Turnier in dieser Disziplin abbrechen und die bisherigen Spielergebnisse löschen?';

  @override
  String get somethingWentWrong => 'Etwas ist schiefgelaufen';

  @override
  String get tournamentCouldNotStart =>
      'Das Turnier konnte nicht gerstartet werden';

  @override
  String get matchQueue => 'Warteschlange';

  @override
  String get readyForCallout => 'Bereit zum Aufrufen';

  @override
  String get runningMatches => 'Laufende Spiele';

  @override
  String matchWaitingStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(
      status,
      {
        'waitingForCourt': 'Warten auf Feld',
        'waitingForRest': 'Warten auf Spielpause',
        'waitingForPlayer': 'Warten auf Spieler',
        'waitingForProgress': 'Warten auf Turnierfortschritt',
        'other': 'OTHER',
      },
    );
    return '$_temp0';
  }

  @override
  String matchesReady(num ready) {
    String _temp0 = intl.Intl.pluralLogic(
      ready,
      locale: localeName,
      other: 'Spiele bereit',
      one: 'Spiel bereit',
    );
    return '$_temp0';
  }

  @override
  String get nextMatch => 'Nächstes Spiel';

  @override
  String get showFullRound => 'Ganze Runde anzeigen';

  @override
  String get versusAbbreviated => 'vs';

  @override
  String get versus => 'gegen';

  @override
  String get qualificationPending => 'Qualifikation ausstehend';

  @override
  String get playMatchHere => 'Match hier spielen';

  @override
  String get assignCourt => 'Feld zuweisen';

  @override
  String roundRobinMatchN(Object number) {
    return 'Jeder gegen Jeden\nRunde $number';
  }

  @override
  String groupNMatchN(Object group, Object match) {
    return 'Gruppe $group\nRunde $match';
  }

  @override
  String get callOutMatch => 'Spiel aufrufen';

  @override
  String get backToWaitList => 'Zurück in die Warteliste';

  @override
  String get on => 'auf';

  @override
  String get matchCalledOut => 'Spiel aufgerufen';

  @override
  String get matchCallOut => 'Spielaufruf';

  @override
  String get callOutAll => 'Alle aufrufen';

  @override
  String nMinutes(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes Minuten',
      one: '1 Minute',
    );
    return '$_temp0';
  }

  @override
  String get playingTime => 'Spieldauer';

  @override
  String get matchPlanned => 'Spiel geplant';

  @override
  String get enterResult => 'Ergebnis eintragen';

  @override
  String get editResult => 'Ergebnis bearbeiten';

  @override
  String get deleteResult => 'Ergebnis löschen';

  @override
  String get deleteResultInfo =>
      'Das Ergebnis wirklich löschen? Spiele, die eventuell von diesem Ergebnis abhängig sind, werden in die Warteschlange zurückgesetzt.';

  @override
  String get callOutHelp =>
      'Teile den Spielteilnehmern mit, gegen wen und wo sie spielen. Das Spiel gilt daraufhin als gestartet.';

  @override
  String get resultEnteringHelp =>
      'Wenn ein Spiel beendet ist, gib hier das Ergebnis ein.\n\nTipp: Gib bei jedem Satz nur die Punktzahl des Verlierers ein und drücke ENTER, um das Satzergebnis automatisch zu vervollständigen!';

  @override
  String nBlockingPlayers(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Spieler\nsind in einem anderen Spiel',
      one: '1 Spieler\nist in einem anderen Spiel',
    );
    return '$_temp0';
  }

  @override
  String blockingGames(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Blockierende Spiele',
      one: 'Blockierendes Spiel',
    );
    return '$_temp0';
  }

  @override
  String get tournamentIsStarted => 'Turnier wurde gestartet';

  @override
  String get playMode => 'Spielmodus';

  @override
  String get winningPoints => 'Gewinnpunkte';

  @override
  String get winningPointsHelp =>
      'Anzahl der Punkte, mit denen ein Satz gewonnen wird.';

  @override
  String get winningSets => 'Gewinnsätze';

  @override
  String winningSetsHelp(Object count, Object maxCount) {
    return 'Anzahl der Sätze, mit denen ein Spiel gewonnen wird. Bei $count Gewinnsätzen fällt die Entscheidung spätestens im $maxCount. Satz.';
  }

  @override
  String get twoPointMargin => '2 Punkte Vorsprung';

  @override
  String get twoPointMarginHelp =>
      'Ob der Gewinner mindestens 2 Punkte Vorsprung braucht, um einen Satz zu gewinnen. Sollten die Gewinnpunkte ohne diesen Vorsprung erreicht werden, wird weiter gespielt bis ein Spieler den Abstand herstellen kann.';

  @override
  String get maxPoints => 'Max. Punkte';

  @override
  String get maxPointsHelp =>
      'Die maximale Punktzahl, die erreicht werden kann. Wenn kein Spieler den 2 Punkte Vorsprung herstellen kann, gewinnt der, der zuerst die maximalen Punkte erreicht.';

  @override
  String get maxPointsError => 'Wert zu niedrig';

  @override
  String get gameSheetPrintingTitle =>
      'Welche Spielzettel sollen gedruckt werden?';

  @override
  String get gameSheetPrintingHelp =>
      'Auf den Spielzetteln können die Spieler ihre Spielergebnisse aufschreiben und an die Turnierleitung zurückgeben.\n\nAußer bei der manuellen Auswahl, werden Spielzettel nicht mehrmals gedruckt. Je nach gewählter Option müssen die Spielzettel handschriftlich vervollständigt werden.';

  @override
  String get gameSheetPrinting => 'Spielzettel drucken';

  @override
  String gameSheetPrintSelection(String selection) {
    String _temp0 = intl.Intl.selectLogic(
      selection,
      {
        'readyForCallOut': 'Spiele, die bereit zum Aufruf sind',
        'playersQualified': 'Spiele, bei denen beide Gegner feststehen',
        'playersPartiallyQualified':
            'Spiele, bei denen min. ein Gegner feststeht',
        'allUpcoming': 'Alle Spielzettel',
        'custom': 'Manuelle Auswahl',
        'other': 'OTHER',
      },
    );
    return '$_temp0';
  }

  @override
  String gameSheetPrintSelectionHelp(String selection) {
    String _temp0 = intl.Intl.selectLogic(
      selection,
      {
        'readyForCallOut':
            'Bei diesen Spielzetteln müssen keine handschriftlichen Eintragungen gemacht werden, da Gegner und Feld schon feststehen.',
        'playersQualified':
            'Bei dieser Auswahl werden auch Zettel gedruckt, die kein Feld zugewiesen haben. Stattdessen wird eine Lücke zur handschriftlichen Vervollständigung gedruckt.',
        'playersPartiallyQualified':
            'Bei dieser Auswahl werden auch Zettel gedruckt, bei denen erst einer der Gegner feststeht. Wenn der andere Gegner sich qualifiziert, muss der Zettel handschriftlich vervollständigt werden.',
        'allUpcoming':
            'Bei dieser Auswahl werden Zettel für alle anstehenden Spiele gedruckt. Dabei ist es egal, ob Feld und Gegner schon feststehen, für die fehlenden Daten werden Lücken zur handschriftlichen Vervollständigung gedruckt.',
        'custom':
            'Diese Option erlaubt eine manuelle Auswahl der zu druckenden Zettel aus allen Spielen des laufenden Turniers. Kann genutzt werden, um Zettel erneut auszudrucken.',
        'other': 'OTHER',
      },
    );
    return '$_temp0';
  }

  @override
  String get preview => 'Vorschau';

  @override
  String gameSheetPrintPreview(Object pages, Object sheets) {
    return 'Vorschau ($sheets auf $pages)';
  }

  @override
  String nSheets(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zettel',
    );
    return '$_temp0';
  }

  @override
  String nPages(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Seiten',
      one: '1 Seite',
    );
    return '$_temp0';
  }

  @override
  String get saveAndOpenPdf => 'PDF speichern und öffnen';

  @override
  String get openSaveLocation => 'Speicherort öffnen';

  @override
  String get noSheetsToPrint =>
      'In der aktuellen Auswahl gibt es keine Spielzettel, die gedruckt werden müssen.';

  @override
  String get changeSelection => 'Auswahl ändern';

  @override
  String get selectGameSheetsToPrint => 'Spiele zum Drucken auswählen';

  @override
  String get apply => 'Übernehmen';

  @override
  String get sheetCreated => 'Spielzettel bereits einmal erstellt';

  @override
  String get sheetNotCreated => 'Spielzettel noch nicht erstellt';

  @override
  String printingCategory(String status) {
    String _temp0 = intl.Intl.selectLogic(
      status,
      {
        'readyForCallOut': 'Bereit zum Aufrufen',
        'noCourt': 'Ohne zugewiesenes Feld',
        'waitingForQualification': 'Warten auf Qualifikation',
        'alreadyRunning': 'Laufende Spiele',
        'other': 'OTHER',
      },
    );
    return '$_temp0';
  }

  @override
  String get dontReprintGameSheets => 'Spielzettel nicht mehrfach erstellen';

  @override
  String get dontReprintGameSheetsHelp =>
      'Mit dieser Option werden (außer bei manueller Auswahl) keine Spielzettel erstellt, die vorher schon einmal generiert wurden.';

  @override
  String get printQrCodes => 'QR-Codes drucken';

  @override
  String get options => 'Optionen';

  @override
  String get cancelMatch => 'Spiel abbrechen\n(zurück zur Aufrufliste)';

  @override
  String get cancelMatchConfirmation => 'Spiel wirklich abbrechen?';

  @override
  String get cancelMatchInfo =>
      'Das Spiel kann erneut gestartet werden, die Spieldauer wird aber zurückgesetzt.';

  @override
  String get settings => 'Einstellungen';

  @override
  String get courtModeSetting => 'Feldzuweisung';

  @override
  String courtMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'manual': 'Manuell',
        'autoCourtAssignment': 'Automatisch',
        'other': 'OTHER',
      },
    );
    return '$_temp0';
  }

  @override
  String courtModeHelp(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'manual': 'Feldzuweisung wird manuell gemacht.',
        'autoCourtAssignment':
            'Spiele werden automatisch einem freien Feld zugewiesen.',
        'other': 'OTHER',
      },
    );
    return '$_temp0';
  }

  @override
  String get playerRestTime => 'Pausenzeit';

  @override
  String playerRestTimeHelp(Object minutes) {
    return 'Spiele werden in der Warteschlange zurückgehalten, bis alle Teilnehmer min. $minutes Pause seit ihrem letzten Spiel hatten.';
  }

  @override
  String minute(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Minuten',
      one: 'Minute',
    );
    return '$_temp0';
  }

  @override
  String nOpenCourts(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count freie Felder',
      one: '1 freies Feld',
      zero: 'Keine freien Felder',
    );
    return '$_temp0';
  }

  @override
  String get matchWaitsForCourt => 'Spiel wartet auf freies Feld';

  @override
  String get playerWithdrawal => 'Rücktritt eines Turnierteilnehmers';

  @override
  String playerWithdrawalInfo(Object playerName) {
    return 'Du hast den \'Anwesend\'-Status von $playerName zurückgezogen.\n\nWähle die Disziplinen, in denen der Spieler nicht weiter antritt. Die gelisteten Spiele werden dann als verloren gewertet:';
  }

  @override
  String get playerReentering => 'Wiedereintritt eines Turnierteilnehmers';

  @override
  String playerReenteringInfo(Object playerName) {
    return 'Du hast den Status von $playerName wieder auf \'Anwesend\' gestellt.\n\nDer Spieler kann wieder in Disziplinen einsteigen, wenn die Disziplin seit dem Rücktritt nicht fortgeschritten ist.\n\nWähle die Disziplinen, in denen der Wiedereinstieg gewünscht ist. Die gelisteten Spiele werden dann wieder normal gewertet bzw. müssen noch gespielt werden:';
  }

  @override
  String get playerCannotReenter =>
      'Disziplin ist fortgeschritten.\nWiedereinstieg nicht möglich.';

  @override
  String get unlockCourt => 'Feld freigeben\n(Ergebnis später eintragen)';

  @override
  String get matchEnded => 'Spiel beendet';

  @override
  String result(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ergebnisse',
      one: 'Ergebnis',
    );
    return '$_temp0';
  }

  @override
  String get resultManagement => 'Ergebnisse verwalten';

  @override
  String win(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Siege',
      one: 'Sieg',
    );
    return '$_temp0';
  }

  @override
  String game(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sätze',
      one: 'Satz',
    );
    return '$_temp0';
  }

  @override
  String point(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Punkte',
      one: 'Punkt',
    );
    return '$_temp0';
  }

  @override
  String get walkover => 'Walkover';

  @override
  String get leaderboard => 'Rangliste';

  @override
  String get provisionalLeaderboardInfo =>
      'Die Disziplin ist noch nicht abgeschlossen. Es wird der aktuelle vorläufige Stand der Rangliste angezeigt.';

  @override
  String nthPlace(Object place) {
    return '$place. Platz';
  }

  @override
  String get breakTie => 'Gleichstand auflösen';

  @override
  String get breakTieInfo =>
      'Lege die Platzierung dieser Teilnehmer innherhalb ihres Gleichstands fest. Sortiere die Liste mit drag & drop.';

  @override
  String get editTieBreaker => 'Gleichstandslösung bearbeiten';

  @override
  String get deleteTieBreaker => 'Gleichstandslösung löschen';

  @override
  String get tournamentProgressBlocked => 'Turnierfortschritt blockiert.';

  @override
  String get tieBreakerRequired => 'Gleichstand muss aufgelöst werden!';

  @override
  String get noMatchesHint =>
      'Starte im \'Disziplinen\' Tab eine Disziplin, die eine Auslosung hat, um die Spiele hier zu sehen';

  @override
  String get losersBracket => 'Losers Bracket';

  @override
  String get smallFinal => 'Kleines Finale';

  @override
  String get smallLoserFinal => 'Kleines Verlierer-Finale';

  @override
  String loserOfMatch(Object match) {
    return 'Verlierer $match';
  }

  @override
  String get numConsolationRounds => 'Trostrunden';

  @override
  String numConsolationRoundsHelp(Object matches) {
    return 'Jeder Spieler darf mindestens $matches verlieren, bevor er ausscheidet. Es werden automatisch entsprechend viele Trostrunden hinzugefügt.\n\nHinweis: Bei bestimmten ungeraden Teilnehmerzahlen kann es passieren, dass ein Spieler trotz Trostrunde nach einer Niederlage im ersten Spiel den letzten Platz belegt.';
  }

  @override
  String get placesToPlayOut => 'Ausgespielte Platzierungen';

  @override
  String placesToPlayOutHelp(Object numPlaces) {
    return 'Der Turnierbaum bringt mindestens $numPlaces eindeutige Spitzenplatzierungen hervor. Die entsprechenden Trostrunden werden automatisch hinzugefügt.';
  }

  @override
  String get tooFewPlacesToPlayOut => 'Min. 2 Plätze müssen ausgespielt werden';

  @override
  String upperToLowerRank(Object lower, Object upper) {
    return 'Platz $upper – $lower';
  }

  @override
  String get matchForThrid => 'Spiel um Platz 3';

  @override
  String matchForNthPlace(Object place) {
    return 'Spiel um\nPlatz $place';
  }

  @override
  String noneOf(Object subject) {
    return 'Keine $subject';
  }

  @override
  String noCategoryWarning(Object categorization, Object category) {
    return 'Die $categorization können nicht verwendet werden, weil keine $category erstellt wurde.';
  }

  @override
  String get close => 'Schließen';

  @override
  String crossGroupTies(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gruppenübergreifende Gleichstände',
      one: 'Gruppenübergreifender Gleichstand',
    );
    return '$_temp0';
  }

  @override
  String get knockOutMode => 'KO-Modus';

  @override
  String get planPrinting => 'Spielpläne drucken';

  @override
  String pageNofM(Object m, Object n) {
    return 'Seite $n von $m';
  }

  @override
  String get noMatchPlans =>
      'Wähle die Disziplinen, für die die Pläne erstellt werden sollen';

  @override
  String get noDrawnCompetitions =>
      'Es gibt noch keine Disziplinen mit ausgelostem Spielplan';

  @override
  String get matchPlanPrintPages => 'Seitenmodus wählen';

  @override
  String get multiPagePlan => 'Auf Seiten verteilen';

  @override
  String get bigPagePlan => 'Eine zusammenhängende Seite';

  @override
  String get multiPagePlanHelp =>
      'Der Spielplan wird ggf. auf mehrere Seiten aufgeteilt und kann nach dem Drucken ausgeschnitten und zusammengesetzt werden';

  @override
  String get bigPagePlanHelp =>
      'Der Spielplan wird auf einer einzelnen Seite erstellt. Die Seitengröße folgt dem Format des Plans. Hinweis: Die Schrift kann beim Drucken größerer Pläne eine unlesbare Größe bekommen.';
}
