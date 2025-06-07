// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get connectingToServer => 'Connecting to server';

  @override
  String get login => 'Sign in';

  @override
  String get logout => 'Sign out';

  @override
  String get signUp => 'Sign up';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get passwordConfirmation => 'Confirm password';

  @override
  String get eMail => 'e-mail';

  @override
  String get invalidUsername => 'Please enter username';

  @override
  String get invalidPassword => 'Please enter password';

  @override
  String get invalidPasswordConfirmation => 'Password doesn\'t match';

  @override
  String get passwordTooShort => 'Please use at least 5 characters';

  @override
  String loginError(String errorCode) {
    String _temp0 = intl.Intl.selectLogic(
      errorCode,
      {
        '400': 'Invalid credentials',
        'other': 'Unknown sign-in error',
      },
    );
    return '$_temp0';
  }

  @override
  String get overAge => 'over';

  @override
  String get underAge => 'under';

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
      other: 'Age groups',
      one: 'Age group',
    );
    return '$_temp0';
  }

  @override
  String get name => 'name';

  @override
  String get club => 'club';

  @override
  String get registrations => 'registrations';

  @override
  String get age => 'age';

  @override
  String get gender => 'gender';

  @override
  String playingLevel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Playing levels',
      one: 'Playing level',
    );
    return '$_temp0';
  }

  @override
  String competition(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Competitions',
      one: 'Competition',
    );
    return '$_temp0';
  }

  @override
  String baseCompetition(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Base competitions',
      one: 'Base competition',
    );
    return '$_temp0';
  }

  @override
  String court(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Courts',
      one: 'Court',
    );
    return '$_temp0';
  }

  @override
  String draw(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Draws',
      one: 'Draw',
    );
    return '$_temp0';
  }

  @override
  String match(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Matches',
      one: 'Match',
    );
    return '$_temp0';
  }

  @override
  String get women => 'women';

  @override
  String get men => 'men';

  @override
  String get womenAbbreviated => 'W';

  @override
  String get menAbbreviated => 'M';

  @override
  String get playerSearchHint => 'Search name/club';

  @override
  String genderCategory(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'female': 'Womens',
        'male': 'Mens',
        'mixed': 'Mixed',
        'other': 'Free',
      },
    );
    return '$_temp0';
  }

  @override
  String competitionType(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'doubles': 'doubles',
        'mixed': 'mixed',
        'singles': 'singles',
        'other': 'other',
      },
    );
    return '$_temp0';
  }

  @override
  String competitionSuffix(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'doubles': ' doubles',
        'mixed': '',
        'singles': ' singles',
        'other': ' other',
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
        'mixed': 'XD',
        'singles': 'S',
        'other': 'other',
      },
    );
    return '$_temp0';
  }

  @override
  String get add => 'Add';

  @override
  String get firstName => 'first name';

  @override
  String get lastName => 'last name';

  @override
  String player(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Players',
      one: 'Player',
    );
    return '$_temp0';
  }

  @override
  String get playerAndRegistrations => 'Player and Registrations';

  @override
  String get playerManagement => 'Manage players';

  @override
  String get competitionManagement => 'Competition management';

  @override
  String get courtManagement => 'Court management';

  @override
  String get drawManagement => 'Draw management';

  @override
  String get birthday => 'birthday';

  @override
  String get dateOfBirth => 'date of birth';

  @override
  String get personalData => 'Personal';

  @override
  String get registeredCompetitions => 'Registered competitions';

  @override
  String get pleaseFillIn => 'Please fill in';

  @override
  String get formatError => 'Format error';

  @override
  String get playerListLoadingError => 'Couldn\'t load the list of players';

  @override
  String get playerEditorLoadingError => 'Couldn\'t load the player editor';

  @override
  String get competitionListLoadingError =>
      'Couldn\'t load the competition list';

  @override
  String get retry => 'Retry';

  @override
  String get save => 'Save';

  @override
  String get saveError => 'Saving failed';

  @override
  String get addRegistration => 'Add registration';

  @override
  String get deleteRegistration => 'Delete registration';

  @override
  String get optional => 'optional';

  @override
  String get partner => 'partner';

  @override
  String get register => 'register';

  @override
  String get registerPartner => 'register partner';

  @override
  String get cancel => 'Cancel';

  @override
  String get continueMsg => 'Continue';

  @override
  String get registrationWarning => 'Registration notice';

  @override
  String ageGroupWarning(Object age, Object ageGroup) {
    return 'The registered age group is $ageGroup, the player is $age years old.';
  }

  @override
  String playingLevelWarning(Object playerLevel, Object playingLevel) {
    return 'The registered playing level is $playingLevel, the player is of $playerLevel.';
  }

  @override
  String genderWarning(Object conflictingGender, Object presentGender) {
    return 'Player is already registered in a $presentGender competition. The registration is for a $conflictingGender competition.';
  }

  @override
  String withPartner(Object partnerName) {
    return 'with $partnerName';
  }

  @override
  String get noPartner => 'no partner registered';

  @override
  String get notes => 'Notes';

  @override
  String get unsavedChanges => 'Unsaved changes';

  @override
  String get dismissChanges => 'Dismiss';

  @override
  String get expand => 'Expand';

  @override
  String get status => 'Status';

  @override
  String bulkEditStatus(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Edit status for $count players',
      one: 'Edit status for 1 player',
    );
    return '$_temp0';
  }

  @override
  String get none => 'none';

  @override
  String playerStatus(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'notAttending': 'Not attending',
        'attending': 'Attending',
        'forfeited': 'Gave up',
        'injured': 'Injured',
        'disqualified': 'Disqualified',
        'other': 'Other',
      },
    );
    return '$_temp0';
  }

  @override
  String get changeStatus => 'Change status';

  @override
  String get confirmAttendance => 'Confirm attendance';

  @override
  String get done => 'Done';

  @override
  String get searchPartner => 'Search partner';

  @override
  String get partnerNeeded => 'Partner needed';

  @override
  String get category => 'Category';

  @override
  String get clearFilter => 'Clear filter';

  @override
  String get deletePlayer => 'Delete player';

  @override
  String get reallyDeletePlayer => 'Really delete player?';

  @override
  String get confirm => 'Confirm';

  @override
  String nPlayersShown(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players listed',
      one: '1 player listed',
    );
    return '$_temp0';
  }

  @override
  String ofN(Object number) {
    return 'of $number';
  }

  @override
  String nSubjectsSelected(num count, Object subject) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count $subject selected',
      zero: 'No $subject selected',
    );
    return '$_temp0';
  }

  @override
  String categorizationHint(Object category) {
    return 'Enable categorization of the competitions into $category. This way the same competition (e.g. mixed) can be held more than once for different groups of players.';
  }

  @override
  String get activatePlayingLevels => 'Use playing levels';

  @override
  String get activateAgeGroups => 'Use age groups';

  @override
  String get categorizationCantBeChanged =>
      'The categorization can\'t be changed while the tournament is running';

  @override
  String categorizationCantBeEdited(Object category) {
    return '$category can\'t be added or removed while the tournament is running';
  }

  @override
  String editSubject(Object subject) {
    return 'Edit $subject';
  }

  @override
  String addSubject(Object subject) {
    return 'Add $subject';
  }

  @override
  String deleteSubject(Object subject) {
    return 'Delete $subject';
  }

  @override
  String deleteSubjectQuestion(Object subject) {
    return 'Delete $subject?';
  }

  @override
  String nameSubject(Object subject) {
    return 'name $subject';
  }

  @override
  String get reorder => 'Reorder';

  @override
  String get rename => 'Rename';

  @override
  String renameSubject(Object subject) {
    return 'Rename $subject';
  }

  @override
  String get chooseCompetitions => 'Choose base competitions';

  @override
  String get chooseCategoriesAndCompetitions =>
      'Choose categories and base competitions';

  @override
  String newCategories(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new categories',
      one: '1 new category',
      zero: 'No new categories',
    );
    return '$_temp0';
  }

  @override
  String newCompetitions(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new competitions',
      one: '1 new competition',
      zero: 'No new competitions',
    );
    return '$_temp0';
  }

  @override
  String totalNewCompetitions(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new competitions total',
      one: '1 new competition total',
      zero: 'No new competitions',
    );
    return '$_temp0';
  }

  @override
  String competitionAddingTooltip(
      Object baseCompetitionCount, Object categories, Object categoryCount) {
    return 'You chose $categoryCount $categories each of which have $baseCompetitionCount of the base competitions to register players in.';
  }

  @override
  String combinationsOf(Object firstSubject, Object secondSubject) {
    return 'combinations of $firstSubject and $secondSubject';
  }

  @override
  String get categoryAlreadyExists =>
      'All base competitions already exist for this category';

  @override
  String get competitionAlreadyExists =>
      'This competition already exists in one of the selected categories';

  @override
  String chooseAtLeastN(num count, Object subject) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Select at least $count $subject',
      one: 'Select at least one $subject',
    );
    return '$_temp0';
  }

  @override
  String createCategories(Object category) {
    return 'Create $category, to be able to add competitions!';
  }

  @override
  String get defaultPlayingLevel => 'Placeholder playing level';

  @override
  String disableCategorization(Object categorization) {
    return 'Stop using $categorization?';
  }

  @override
  String mergeRegistrationsWarning(Object categorization) {
    return 'There are registrations in multiple $categorization. By deactivating $categorization the competitions and their registration lists are merged.\n\nAny existing seedings and draws cannot be combined and will be lost.\n\nThis can\'t be undone. Continue?';
  }

  @override
  String deleteCategoryWarning(Object category, Object categoryName) {
    return 'By deleting the $category $categoryName the corresponding competitions are also deleted.\n\nContinue?';
  }

  @override
  String get selection => 'Selection';

  @override
  String get noSelection => 'No selection';

  @override
  String get continueWithoutSelection => 'Continue without selection';

  @override
  String deleteAndMergeCategoryWarning(Object category, Object categoryName) {
    return 'By deleting the $category $categoryName the corresponding competitions including registrations are also deleted.\nA replacement $category can be selected where the registrations will be transferred to:';
  }

  @override
  String get deleteCompetitions => 'Delete competitions?';

  @override
  String deleteCompetitionsWarning(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Really delete the selected competitions?',
      one: 'Really delete the selected competition?',
    );
    return '$_temp0';
  }

  @override
  String get deleteCompetitionsWithTeamsWarning =>
      'The competitions already have registered players.';

  @override
  String get competitionCantBeDeleted =>
      'Running competitions cannot be deleted';

  @override
  String get orMore => 'or more';

  @override
  String get orLess => 'or less';

  @override
  String get showRegistrations => 'Show registration list';

  @override
  String gym(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Halls',
      one: 'Hall',
    );
    return '$_temp0';
  }

  @override
  String row(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rows',
      one: 'Row',
    );
    return '$_temp0';
  }

  @override
  String column(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Columns',
      one: 'Column',
    );
    return '$_temp0';
  }

  @override
  String get description => 'Description';

  @override
  String get gymFloorPlan => 'Hall floor plan';

  @override
  String get directions => 'Directions';

  @override
  String gymFloorPlanHelpMessage(Object columns, Object rows) {
    return 'The plan describes how the courts are arranged in the hall. Thus, a maximum of ${rows}x$columns courts fit into the hall. It is up to you which of the courts are actually used.';
  }

  @override
  String courtN(Object n) {
    return 'Court $n';
  }

  @override
  String get noGymnasiumSelected => 'Select a hall to edit the courts';

  @override
  String get addFirstGymnasium => 'Add your first hall';

  @override
  String get zoom => 'Zoom';

  @override
  String get resetView => 'Reset view';

  @override
  String get deleteGymWarning => 'Really delete the hall with all courts?';

  @override
  String get addAllMissingCourts => 'Add all missing courts';

  @override
  String get reduceHall => 'Reduce hall?';

  @override
  String get reduceHallWarning =>
      'By shrinking the hall\'s floor plan, court will be deleted. Continue?';

  @override
  String get numberCourts => 'Number courts consecutively';

  @override
  String get cantReduceHall => 'Hall size can\'t be reduced';

  @override
  String get cantReduceHallInfo =>
      'Reducing the hall size would delete courts where matches are running.';

  @override
  String get cantDeleteHall => 'Hall can\'t be deleted';

  @override
  String get cantDeleteHallInfo =>
      'The hall can not be deleted because there are matches running there.';

  @override
  String get countingDirection => 'Counting direction';

  @override
  String get rowWise => 'Row by row';

  @override
  String get columnWise => 'Column by colum';

  @override
  String get allGyms => 'Throughout all halls';

  @override
  String get onlyGym => 'Just this hall';

  @override
  String get emptyCourts => 'Empty courts';

  @override
  String get skip => 'Skip';

  @override
  String get count => 'Count in';

  @override
  String get assign => 'Assign';

  @override
  String get assignTournamentMode => 'Assign tournament mode';

  @override
  String get changeTournamentMode => 'Change tournament mode';

  @override
  String get tournamentModeCantBeAssigned =>
      'Tournament mode can\'t be change on a running competition';

  @override
  String get roundRobin => 'Round robin';

  @override
  String get singleElimination => 'Single elimination';

  @override
  String get doubleElimination => 'Double elimination';

  @override
  String get consolationElimination => 'Elimination with consolation rounds';

  @override
  String get groupKnockout => 'Group tournament';

  @override
  String get roundRobinHelp =>
      'Each participant plays everyone else. How often is determined by the configurable number of rounds.';

  @override
  String get singleEliminationHelp =>
      'A tournament bracket that ends in a final. To make a match for 3rd place or play out more ranks use the \"elimination with consolation rounds\" mode.';

  @override
  String get doubleEliminationHelp =>
      'In a double elimination participants go into a \"lower\" bracket after their first loss. Another loss eliminates the participant. The final is played between the last unbeaten participant and the winner of the lower bracket.';

  @override
  String get consolationEliminationHelp =>
      'In this elimination format, additional consolation rounds can be scheduled for the losers of the main round. A minimum number of matches per participant can be guaranteed and/or a certain number of final placements can be played out.';

  @override
  String get groupKnockoutHelp =>
      'The group stage consists of a round robin in each group. The top ranked participants of each group advance to an elimination stage.';

  @override
  String get pleaseChoose => 'Please choose';

  @override
  String get tournamentMode => 'Tournament mode';

  @override
  String get seedingMode => 'Seeding mode';

  @override
  String seedingModeLabel(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'single': 'Single',
        'tiered': 'Tiered',
        'other': 'Other',
      },
    );
    return '$_temp0';
  }

  @override
  String get singleSeedingHelp => 'Every seed list entry gets their own rank.';

  @override
  String get tieredSeedingHelp =>
      '1st and 2nd seed are individually set. Afterwards the ranks will be staggered in tiers: 3/4, 5/8, 9/16, etc.';

  @override
  String get passes => 'Rounds';

  @override
  String get roundRobinPassesHelp =>
      'How often everyone plays everyone else. E.g. 2 means each matchup happens twice.';

  @override
  String get numGroups => 'Number of groups';

  @override
  String get numGroupsHelp =>
      'How many groups the participants will be divided among. Manual assignments are possible after the draw.';

  @override
  String get numQualifications => 'Number of qualifications';

  @override
  String get numQualificationsHelp =>
      'How many will advance from the groups to the knockout round.';

  @override
  String get entryList => 'Entry list/Seeds';

  @override
  String get addToSeeds => 'Add to seeds';

  @override
  String get removeFromSeeds => 'Remove from seeds';

  @override
  String get noDrawCompetitionSelected => 'Select a competition to make a draw';

  @override
  String get noResultCompetitionSelected =>
      'Select a competition to see the results';

  @override
  String get noResultsYet => 'There are no scores for this competition yet';

  @override
  String get noTournamentMode =>
      'This competition has no tournament mode assigned';

  @override
  String get makeDraw => 'Make draw';

  @override
  String get bye => 'Bye';

  @override
  String get freeOfPlay => 'Free of play';

  @override
  String encounterNumber(Object number) {
    return '$number. Encounter';
  }

  @override
  String participant(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Participants',
      one: 'Participant',
    );
    return '$_temp0';
  }

  @override
  String groupNumber(Object number) {
    return 'Group $number';
  }

  @override
  String groupQualification(Object group, Object place) {
    return '$place. Place, Group $group';
  }

  @override
  String contestedGroupQualification(Object place) {
    return '$place. Place, dependant on group results';
  }

  @override
  String roundOfN(String participants) {
    String _temp0 = intl.Intl.selectLogic(
      participants,
      {
        '2': 'Final',
        '4': 'Semi-Final',
        '8': 'Quarter-Final',
        'other': 'Round of $participants',
      },
    );
    return '$_temp0';
  }

  @override
  String roundN(Object roundNumber) {
    return 'Round $roundNumber';
  }

  @override
  String matchN(Object matchNumber) {
    return 'Match $matchNumber';
  }

  @override
  String loserRoundN(Object round) {
    return 'Loser\'s $round';
  }

  @override
  String groupPhaseRoundN(Object round) {
    return 'Gruppenphase $round';
  }

  @override
  String get collapse => 'Collapse';

  @override
  String get undoManualDraw => 'Reset manual changes';

  @override
  String get redraw => 'Redraw';

  @override
  String get undoManualDrawWarning =>
      'Really reset the manual changes to the draw?\nThis will update entries who\'s attendance status changed since the last draw.';

  @override
  String get redrawWarning =>
      'Really redo the draw?\nThis will update entries who\'s attendance status changed since the last draw.';

  @override
  String get deleteDrawWarning =>
      'Really delete the draw?\nAfterwards the tournament mode and seed list will be editable again.';

  @override
  String get seedsNotEditable =>
      'The seeds can\'t be edited because a draw already exists. Delete the draw to be able to edit the seeds.';

  @override
  String teamNotAttending(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'One or more players on this team do not have the \'attending\' status yet. The team wont be included in the match plan when drawing.',
      one:
          'The player does not have the \'attending\' status yet. They wont be included in the match plan when drawing.',
    );
    return '$_temp0';
  }

  @override
  String get teamNotComplete =>
      'This team does not have enough members. They wont be included in the match plan when drawing.';

  @override
  String teamsReady(num ready, Object total) {
    String _temp0 = intl.Intl.pluralLogic(
      ready,
      locale: localeName,
      other: '$ready Teams ready (of $total)',
      one: '$ready Team ready (of $total)',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughDrawParticipants => 'Not enough teams';

  @override
  String notEnoughDrawParticipantsInfo(Object count) {
    return 'At least $count teams need to be ready to make a draw for the given tournament mode.\nRegister more teams or change the tournament mode.\n\nHint: Players need to have the \'attending\' status to be considered ready.';
  }

  @override
  String get drawsWillBeOverridden => 'Existing draws';

  @override
  String get drawsWillBeOverriddenInfo =>
      'By changing the tournament mode existing draws will be removed.\n\nContinue?';

  @override
  String get noCompetitionsRegistrationHint =>
      'Add a competition to become able to make registrations';

  @override
  String get allCompetitionsRunningHint =>
      'All competitions are running or have been registered for';

  @override
  String get noCompetitionsDrawHint =>
      'No competitions.\n\nAdd a competition and register participants to make a draw.';

  @override
  String get noCompetitionsResultHint =>
      'Keine Disziplinen.\n\nAdd a competition and start it to see results.';

  @override
  String get matchOperations => 'Match operations';

  @override
  String get startTournament => 'Start tournament';

  @override
  String get startTournamentInfo =>
      'You are about to start the tournament for the selected competitions.\nThe matches will appear on the \'Matches\' tab and the tournament operations can commence!';

  @override
  String get cancelTournament => 'Cancel tournament';

  @override
  String get cancelTournamentInfo =>
      'Canceling the tournament for this competition means deleting all previously played matches and results in this competition. The tournament mode and draw for the competition can then be edited again. The deletion of the match results cannot be undone.\n\nDo you really want to cancel the tournament for this competition and delete the previous match results?';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get tournamentCouldNotStart => 'The tournament could not be started';

  @override
  String get matchQueue => 'Match queue';

  @override
  String get readyForCallout => 'Ready for call out';

  @override
  String get runningMatches => 'Running matches';

  @override
  String matchWaitingStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(
      status,
      {
        'waitingForCourt': 'Waiting for court',
        'waitingForRest': 'Waiting for rest time',
        'waitingForPlayer': 'Waiting for player',
        'waitingForProgress': 'Waiting for tournament progress',
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
      other: 'Matches ready',
      one: 'Match ready',
    );
    return '$_temp0';
  }

  @override
  String get nextMatch => 'Next match';

  @override
  String get showFullRound => 'Show full round';

  @override
  String get versusAbbreviated => 'vs';

  @override
  String get versus => 'versus';

  @override
  String get qualificationPending => 'Qualification pending';

  @override
  String get playMatchHere => 'Play match here';

  @override
  String get assignCourt => 'Assign court';

  @override
  String roundRobinMatchN(Object number) {
    return 'Round robin\nRound $number';
  }

  @override
  String groupNMatchN(Object group, Object match) {
    return 'Group $group\nRound $match';
  }

  @override
  String get callOutMatch => 'Call out match';

  @override
  String get backToWaitList => 'Back to wait list';

  @override
  String get on => 'on';

  @override
  String get matchCalledOut => 'Match called out';

  @override
  String get matchCallOut => 'Match call';

  @override
  String get callOutAll => 'Call out all';

  @override
  String nMinutes(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get playingTime => 'Playing time';

  @override
  String get matchPlanned => 'Match planned';

  @override
  String get enterResult => 'Enter result';

  @override
  String get editResult => 'Edit result';

  @override
  String get deleteResult => 'Delete result';

  @override
  String get deleteResultInfo =>
      'Really delete the result? Matches that might be depending on this result will be reset to the match queue.';

  @override
  String get callOutHelp =>
      'Tell the match participants, who and where they play. The match is then considered to be running.';

  @override
  String get resultEnteringHelp =>
      'When a match is finished enter the result here.\n\nTip: For each game, just enter the loser\'s points and press ENTER to autocomplete the game score!';

  @override
  String nBlockingPlayers(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players\nare in another match',
      one: '1 player\nis in another match',
    );
    return '$_temp0';
  }

  @override
  String blockingGames(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Blocking matches',
      one: 'Blocking match',
    );
    return '$_temp0';
  }

  @override
  String get tournamentIsStarted => 'Tournament has been started';

  @override
  String get playMode => 'Play mode';

  @override
  String get winningPoints => 'Winning points';

  @override
  String get winningPointsHelp => 'Number of points required to win a game';

  @override
  String get winningSets => 'Winning games';

  @override
  String winningSetsHelp(Object count, Object maxCount) {
    return 'Number of games required to win a match. With $count winning games, there will be $maxCount games at most.';
  }

  @override
  String get twoPointMargin => '2-point margin';

  @override
  String get twoPointMarginHelp =>
      'Whether the winner needs a minimum 2-point margin to win a game. If the winning points are reached without this margin, play continues until a player can establish the lead.';

  @override
  String get maxPoints => 'Max. points';

  @override
  String get maxPointsHelp =>
      'The maximum number of points that can be reached. If no player can establish the 2-point margin, the one who reaches the maximum points first wins.';

  @override
  String get maxPointsError => 'Value too low';

  @override
  String get gameSheetPrintingTitle => 'Which game sheets should be printed?';

  @override
  String get gameSheetPrintingHelp =>
      'The players can record their match results on the game sheets and return them to the tournament administration.\n\nOutside the manual selection, game sheets will only be printed once. Depending on the used print option, some game sheets need to be completed by hand.';

  @override
  String get gameSheetPrinting => 'Game sheet printing';

  @override
  String gameSheetPrintSelection(String selection) {
    String _temp0 = intl.Intl.selectLogic(
      selection,
      {
        'readyForCallOut': 'Matches that are ready for call out',
        'playersQualified': 'Matches where both opponents are determined',
        'playersPartiallyQualified':
            'Matches where at least one opponent is determined',
        'allUpcoming': 'All game sheets',
        'custom': 'Manual selection',
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
            'On these game sheets, no handwritten entries need to be made, as the opponents and fields are already determined.',
        'playersQualified':
            'With this option, sheets are also printed that do not have a court assigned. Instead, a blank space is printed for handwritten completion.',
        'playersPartiallyQualified':
            'With this option, sheets are also printed that only have one opponent determined. When the other opponent qualifies, the sheet has to be completed with handwriting.',
        'allUpcoming':
            'With this option, sheets are printed for all upcoming matches. It doesn\'t matter whether the court and opponents have already been determined; for the missing data, blank spaces are printed for handwritten completion.',
        'custom':
            'This option allows making a selection for printing sheets from all matches of the currently running tournament. Can be used to reprint sheets.',
        'other': 'OTHER',
      },
    );
    return '$_temp0';
  }

  @override
  String get preview => 'Vorschau';

  @override
  String gameSheetPrintPreview(Object pages, Object sheets) {
    return 'Preview ($sheets on $pages)';
  }

  @override
  String nSheets(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sheets',
      one: '1 sheet',
    );
    return '$_temp0';
  }

  @override
  String nPages(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String get saveAndOpenPdf => 'Save PDF and open';

  @override
  String get openSaveLocation => 'Open save location';

  @override
  String get noSheetsToPrint =>
      'The current selection icludes no game sheets that need printing.';

  @override
  String get changeSelection => 'Change selection';

  @override
  String get selectGameSheetsToPrint => 'Select matches for printing';

  @override
  String get apply => 'Apply';

  @override
  String get sheetCreated => 'Game sheet already created once';

  @override
  String get sheetNotCreated => 'Game sheet not created yet';

  @override
  String printingCategory(String status) {
    String _temp0 = intl.Intl.selectLogic(
      status,
      {
        'readyForCallOut': 'Ready for call out',
        'noCourt': 'No court assigned',
        'waitingForQualification': 'Waiting for qualification',
        'alreadyRunning': 'Running matches',
        'other': 'OTHER',
      },
    );
    return '$_temp0';
  }

  @override
  String get dontReprintGameSheets => 'Don\'t reprint game sheets';

  @override
  String get dontReprintGameSheetsHelp =>
      'With this option, game sheets that have been printed before wont be reprinted (except in a manual selection).';

  @override
  String get printQrCodes => 'Print QR codes';

  @override
  String get options => 'Options';

  @override
  String get cancelMatch => 'Cancel match\n(back to call out list)';

  @override
  String get cancelMatchConfirmation => 'Really cancel match?';

  @override
  String get cancelMatchInfo =>
      'The match can be started again, the match duration will be reset.';

  @override
  String get settings => 'Settings';

  @override
  String get courtModeSetting => 'Court assignment mode';

  @override
  String courtMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(
      mode,
      {
        'manual': 'Manual',
        'autoCourtAssignment': 'Automatic',
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
        'manual': 'Court assignment is done manually.',
        'autoCourtAssignment':
            'Matches are automatically assigned to an open court.',
        'other': 'OTHER',
      },
    );
    return '$_temp0';
  }

  @override
  String get playerRestTime => 'Rest time';

  @override
  String playerRestTimeHelp(Object minutes) {
    return 'Matches are held in the queue until all participants have had at least $minutes break since their last game.';
  }

  @override
  String minute(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'minutes',
      one: 'minute',
    );
    return '$_temp0';
  }

  @override
  String nOpenCourts(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open courts',
      one: '1 open court',
      zero: 'No open courts',
    );
    return '$_temp0';
  }

  @override
  String get matchWaitsForCourt => 'Match is waiting for open court';

  @override
  String get playerWithdrawal => 'Withdrawal of a tournament participant';

  @override
  String playerWithdrawalInfo(Object playerName) {
    return 'You have withdrawn the \'Attending\' status of $playerName.\n\nSelect the competitions in which the player no longer competes. The listed matches will then be counted as lost:';
  }

  @override
  String get playerReentering => 'Re-entering of a tournament participant';

  @override
  String playerReenteringInfo(Object playerName) {
    return 'You have set the status of $playerName back to \'Attending\'.\n\nThe player can re-enter competitions if the competition has not progressed since the withdrawal.\n\nSelect the competitions in which re-entry is desired. The listed matches will then be scored normally again or must still be played:';
  }

  @override
  String get playerCannotReenter =>
      'Competition progressed.\nRe-entry not possible.';

  @override
  String get unlockCourt => 'Unlock court\n(Enter result later)';

  @override
  String get matchEnded => 'Match ended';

  @override
  String result(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Results',
      one: 'Result',
    );
    return '$_temp0';
  }

  @override
  String get resultManagement => 'Manage results';

  @override
  String win(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wins',
      one: 'Win',
    );
    return '$_temp0';
  }

  @override
  String game(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Games',
      one: 'Game',
    );
    return '$_temp0';
  }

  @override
  String point(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Points',
      one: 'Point',
    );
    return '$_temp0';
  }

  @override
  String get walkover => 'Walkover';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get provisionalLeaderboardInfo =>
      'The competition has not yet been completed. The current provisional status of the leaderboard is displayed.';

  @override
  String nthPlace(Object place) {
    return '$place. Place';
  }

  @override
  String get breakTie => 'Break tie';

  @override
  String get breakTieInfo =>
      'Break the tie of these participants. Order the list using drag & drop.';

  @override
  String get editTieBreaker => 'Edit tie breaker';

  @override
  String get deleteTieBreaker => 'Delete tie breaker';

  @override
  String get tournamentProgressBlocked => 'Tournament progress blocked.';

  @override
  String get tieBreakerRequired => 'Tie breaker required!';

  @override
  String get noMatchesHint =>
      'Start a competition that has a draw on the \'Competitions\' tab to see the matches here';

  @override
  String get losersBracket => 'Losers Bracket';

  @override
  String get smallFinal => 'Small Final';

  @override
  String get smallLoserFinal => 'Small Loser\'s Final';

  @override
  String loserOfMatch(Object match) {
    return 'Loser $match';
  }

  @override
  String get numConsolationRounds => 'Guaranteed matches';

  @override
  String numConsolationRoundsHelp(Object matches) {
    return 'Each player is allowed to lose at least $matches before being eliminated. The required number of consolation rounds will be added automatically.\n\nNote: With certain odd numbers of participants, it may happen that a player finishes last after losing the first game despite a consolation round being present.';
  }

  @override
  String get placesToPlayOut => 'Placements to play out';

  @override
  String placesToPlayOutHelp(Object numPlaces) {
    return 'The tournament bracket will produce at least $numPlaces untied top placements. The required consolation rounds will be added automatically.';
  }

  @override
  String get tooFewPlacesToPlayOut => 'At least 2 places have to be played out';

  @override
  String upperToLowerRank(Object lower, Object upper) {
    return 'Rank $upper – $lower';
  }

  @override
  String get matchForThrid => 'Match for 3rd place';

  @override
  String matchForNthPlace(Object place) {
    return 'Match for\n$place. place';
  }

  @override
  String noneOf(Object subject) {
    return 'No $subject';
  }

  @override
  String noCategoryWarning(Object categorization, Object category) {
    return 'The $categorization can\'t be activated because no $category has been created.';
  }

  @override
  String get close => 'Close';

  @override
  String crossGroupTies(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cross Group Ties',
      one: 'Cross Group Tie',
    );
    return '$_temp0';
  }

  @override
  String get knockOutMode => 'Knock-Out mode';

  @override
  String get planPrinting => 'Print match plans';

  @override
  String pageNofM(Object m, Object n) {
    return 'Page $n of $m';
  }

  @override
  String get noMatchPlans =>
      'Select the competitions that the plans should be generated for';

  @override
  String get noDrawnCompetitions =>
      'There are no competitions with drawn match plan yet';

  @override
  String get matchPlanPrintPages => 'Choose page mode';

  @override
  String get multiPagePlan => 'Distribute over pages';

  @override
  String get bigPagePlan => 'One big page';

  @override
  String get multiPagePlanHelp =>
      'The match plan is distributed across multiple pages if needed. After printing the plan can be cut out and pieced together.';

  @override
  String get bigPagePlanHelp =>
      'The plan is put onto a single page. The page size follows the format of the plan. Note: The text can get an unreadable size when printing large plans.';
}
