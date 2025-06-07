import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @connectingToServer.
  ///
  /// In en, this message translates to:
  /// **'Connecting to server'**
  String get connectingToServer;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get passwordConfirmation;

  /// No description provided for @eMail.
  ///
  /// In en, this message translates to:
  /// **'e-mail'**
  String get eMail;

  /// No description provided for @invalidUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get invalidUsername;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get invalidPassword;

  /// No description provided for @invalidPasswordConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Password doesn\'t match'**
  String get invalidPasswordConfirmation;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Please use at least 5 characters'**
  String get passwordTooShort;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'{errorCode, select, 400{Invalid credentials} other{Unknown sign-in error}}'**
  String loginError(String errorCode);

  /// No description provided for @overAge.
  ///
  /// In en, this message translates to:
  /// **'over'**
  String get overAge;

  /// No description provided for @underAge.
  ///
  /// In en, this message translates to:
  /// **'under'**
  String get underAge;

  /// No description provided for @overAgeAbbreviated.
  ///
  /// In en, this message translates to:
  /// **'O'**
  String get overAgeAbbreviated;

  /// No description provided for @underAgeAbbreviated.
  ///
  /// In en, this message translates to:
  /// **'U'**
  String get underAgeAbbreviated;

  /// No description provided for @ageGroupAbbreviated.
  ///
  /// In en, this message translates to:
  /// **'{type, select, over{O} under{U} other{other}}'**
  String ageGroupAbbreviated(String type);

  /// No description provided for @ageGroup.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Age group} other{Age groups}}'**
  String ageGroup(num count);

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'name'**
  String get name;

  /// No description provided for @club.
  ///
  /// In en, this message translates to:
  /// **'club'**
  String get club;

  /// No description provided for @registrations.
  ///
  /// In en, this message translates to:
  /// **'registrations'**
  String get registrations;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'age'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'gender'**
  String get gender;

  /// No description provided for @playingLevel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Playing level} other{Playing levels}}'**
  String playingLevel(num count);

  /// No description provided for @competition.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Competition} other{Competitions}}'**
  String competition(num count);

  /// No description provided for @baseCompetition.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Base competition} other{Base competitions}}'**
  String baseCompetition(num count);

  /// No description provided for @court.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Court} other{Courts}}'**
  String court(num count);

  /// No description provided for @draw.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Draw} other{Draws}}'**
  String draw(num count);

  /// No description provided for @match.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Match} other{Matches}}'**
  String match(num count);

  /// No description provided for @women.
  ///
  /// In en, this message translates to:
  /// **'women'**
  String get women;

  /// No description provided for @men.
  ///
  /// In en, this message translates to:
  /// **'men'**
  String get men;

  /// No description provided for @womenAbbreviated.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get womenAbbreviated;

  /// No description provided for @menAbbreviated.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get menAbbreviated;

  /// No description provided for @playerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search name/club'**
  String get playerSearchHint;

  /// No description provided for @genderCategory.
  ///
  /// In en, this message translates to:
  /// **'{type, select, female{Womens} male{Mens} mixed{Mixed} other{Free}}'**
  String genderCategory(String type);

  /// No description provided for @competitionType.
  ///
  /// In en, this message translates to:
  /// **'{type, select, doubles{doubles} mixed{mixed} singles{singles} other{other}}'**
  String competitionType(String type);

  /// No description provided for @competitionSuffix.
  ///
  /// In en, this message translates to:
  /// **'{type, select, doubles{ doubles} mixed{} singles{ singles} other{ other}}'**
  String competitionSuffix(String type);

  /// No description provided for @competitionTypeAbbreviated.
  ///
  /// In en, this message translates to:
  /// **'{type, select, doubles{D} mixed{XD} singles{S} other{other}}'**
  String competitionTypeAbbreviated(String type);

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'first name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'last name'**
  String get lastName;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Player} other{Players}}'**
  String player(num count);

  /// No description provided for @playerAndRegistrations.
  ///
  /// In en, this message translates to:
  /// **'Player and Registrations'**
  String get playerAndRegistrations;

  /// No description provided for @playerManagement.
  ///
  /// In en, this message translates to:
  /// **'Manage players'**
  String get playerManagement;

  /// No description provided for @competitionManagement.
  ///
  /// In en, this message translates to:
  /// **'Competition management'**
  String get competitionManagement;

  /// No description provided for @courtManagement.
  ///
  /// In en, this message translates to:
  /// **'Court management'**
  String get courtManagement;

  /// No description provided for @drawManagement.
  ///
  /// In en, this message translates to:
  /// **'Draw management'**
  String get drawManagement;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'birthday'**
  String get birthday;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'date of birth'**
  String get dateOfBirth;

  /// No description provided for @personalData.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personalData;

  /// No description provided for @registeredCompetitions.
  ///
  /// In en, this message translates to:
  /// **'Registered competitions'**
  String get registeredCompetitions;

  /// No description provided for @pleaseFillIn.
  ///
  /// In en, this message translates to:
  /// **'Please fill in'**
  String get pleaseFillIn;

  /// No description provided for @formatError.
  ///
  /// In en, this message translates to:
  /// **'Format error'**
  String get formatError;

  /// No description provided for @playerListLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the list of players'**
  String get playerListLoadingError;

  /// No description provided for @playerEditorLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the player editor'**
  String get playerEditorLoadingError;

  /// No description provided for @competitionListLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the competition list'**
  String get competitionListLoadingError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Saving failed'**
  String get saveError;

  /// No description provided for @addRegistration.
  ///
  /// In en, this message translates to:
  /// **'Add registration'**
  String get addRegistration;

  /// No description provided for @deleteRegistration.
  ///
  /// In en, this message translates to:
  /// **'Delete registration'**
  String get deleteRegistration;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @partner.
  ///
  /// In en, this message translates to:
  /// **'partner'**
  String get partner;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'register'**
  String get register;

  /// No description provided for @registerPartner.
  ///
  /// In en, this message translates to:
  /// **'register partner'**
  String get registerPartner;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @continueMsg.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueMsg;

  /// No description provided for @registrationWarning.
  ///
  /// In en, this message translates to:
  /// **'Registration notice'**
  String get registrationWarning;

  /// No description provided for @ageGroupWarning.
  ///
  /// In en, this message translates to:
  /// **'The registered age group is {ageGroup}, the player is {age} years old.'**
  String ageGroupWarning(Object age, Object ageGroup);

  /// No description provided for @playingLevelWarning.
  ///
  /// In en, this message translates to:
  /// **'The registered playing level is {playingLevel}, the player is of {playerLevel}.'**
  String playingLevelWarning(Object playerLevel, Object playingLevel);

  /// No description provided for @genderWarning.
  ///
  /// In en, this message translates to:
  /// **'Player is already registered in a {presentGender} competition. The registration is for a {conflictingGender} competition.'**
  String genderWarning(Object conflictingGender, Object presentGender);

  /// No description provided for @withPartner.
  ///
  /// In en, this message translates to:
  /// **'with {partnerName}'**
  String withPartner(Object partnerName);

  /// No description provided for @noPartner.
  ///
  /// In en, this message translates to:
  /// **'no partner registered'**
  String get noPartner;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get unsavedChanges;

  /// No description provided for @dismissChanges.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismissChanges;

  /// No description provided for @expand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expand;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @bulkEditStatus.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Edit status for 1 player} other{Edit status for {count} players}}'**
  String bulkEditStatus(num count);

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'none'**
  String get none;

  /// No description provided for @playerStatus.
  ///
  /// In en, this message translates to:
  /// **'{type, select, notAttending{Not attending} attending{Attending} forfeited{Gave up} injured{Injured} disqualified{Disqualified} other{Other}}'**
  String playerStatus(String type);

  /// No description provided for @changeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get changeStatus;

  /// No description provided for @confirmAttendance.
  ///
  /// In en, this message translates to:
  /// **'Confirm attendance'**
  String get confirmAttendance;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @searchPartner.
  ///
  /// In en, this message translates to:
  /// **'Search partner'**
  String get searchPartner;

  /// No description provided for @partnerNeeded.
  ///
  /// In en, this message translates to:
  /// **'Partner needed'**
  String get partnerNeeded;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear filter'**
  String get clearFilter;

  /// No description provided for @deletePlayer.
  ///
  /// In en, this message translates to:
  /// **'Delete player'**
  String get deletePlayer;

  /// No description provided for @reallyDeletePlayer.
  ///
  /// In en, this message translates to:
  /// **'Really delete player?'**
  String get reallyDeletePlayer;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @nPlayersShown.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 player listed} other{{count} players listed}}'**
  String nPlayersShown(num count);

  /// No description provided for @ofN.
  ///
  /// In en, this message translates to:
  /// **'of {number}'**
  String ofN(Object number);

  /// No description provided for @nSubjectsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No {subject} selected} other{{count} {subject} selected}}'**
  String nSubjectsSelected(num count, Object subject);

  /// No description provided for @categorizationHint.
  ///
  /// In en, this message translates to:
  /// **'Enable categorization of the competitions into {category}. This way the same competition (e.g. mixed) can be held more than once for different groups of players.'**
  String categorizationHint(Object category);

  /// No description provided for @activatePlayingLevels.
  ///
  /// In en, this message translates to:
  /// **'Use playing levels'**
  String get activatePlayingLevels;

  /// No description provided for @activateAgeGroups.
  ///
  /// In en, this message translates to:
  /// **'Use age groups'**
  String get activateAgeGroups;

  /// No description provided for @categorizationCantBeChanged.
  ///
  /// In en, this message translates to:
  /// **'The categorization can\'t be changed while the tournament is running'**
  String get categorizationCantBeChanged;

  /// No description provided for @categorizationCantBeEdited.
  ///
  /// In en, this message translates to:
  /// **'{category} can\'t be added or removed while the tournament is running'**
  String categorizationCantBeEdited(Object category);

  /// No description provided for @editSubject.
  ///
  /// In en, this message translates to:
  /// **'Edit {subject}'**
  String editSubject(Object subject);

  /// No description provided for @addSubject.
  ///
  /// In en, this message translates to:
  /// **'Add {subject}'**
  String addSubject(Object subject);

  /// No description provided for @deleteSubject.
  ///
  /// In en, this message translates to:
  /// **'Delete {subject}'**
  String deleteSubject(Object subject);

  /// No description provided for @deleteSubjectQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete {subject}?'**
  String deleteSubjectQuestion(Object subject);

  /// No description provided for @nameSubject.
  ///
  /// In en, this message translates to:
  /// **'name {subject}'**
  String nameSubject(Object subject);

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @renameSubject.
  ///
  /// In en, this message translates to:
  /// **'Rename {subject}'**
  String renameSubject(Object subject);

  /// No description provided for @chooseCompetitions.
  ///
  /// In en, this message translates to:
  /// **'Choose base competitions'**
  String get chooseCompetitions;

  /// No description provided for @chooseCategoriesAndCompetitions.
  ///
  /// In en, this message translates to:
  /// **'Choose categories and base competitions'**
  String get chooseCategoriesAndCompetitions;

  /// No description provided for @newCategories.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No new categories} =1{1 new category} other{{count} new categories}}'**
  String newCategories(num count);

  /// No description provided for @newCompetitions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No new competitions} =1{1 new competition} other{{count} new competitions}}'**
  String newCompetitions(num count);

  /// No description provided for @totalNewCompetitions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No new competitions} =1{1 new competition total} other{{count} new competitions total}}'**
  String totalNewCompetitions(num count);

  /// No description provided for @competitionAddingTooltip.
  ///
  /// In en, this message translates to:
  /// **'You chose {categoryCount} {categories} each of which have {baseCompetitionCount} of the base competitions to register players in.'**
  String competitionAddingTooltip(
      Object baseCompetitionCount, Object categories, Object categoryCount);

  /// No description provided for @combinationsOf.
  ///
  /// In en, this message translates to:
  /// **'combinations of {firstSubject} and {secondSubject}'**
  String combinationsOf(Object firstSubject, Object secondSubject);

  /// No description provided for @categoryAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'All base competitions already exist for this category'**
  String get categoryAlreadyExists;

  /// No description provided for @competitionAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This competition already exists in one of the selected categories'**
  String get competitionAlreadyExists;

  /// No description provided for @chooseAtLeastN.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Select at least one {subject}} other{Select at least {count} {subject}}}'**
  String chooseAtLeastN(num count, Object subject);

  /// No description provided for @createCategories.
  ///
  /// In en, this message translates to:
  /// **'Create {category}, to be able to add competitions!'**
  String createCategories(Object category);

  /// No description provided for @defaultPlayingLevel.
  ///
  /// In en, this message translates to:
  /// **'Placeholder playing level'**
  String get defaultPlayingLevel;

  /// No description provided for @disableCategorization.
  ///
  /// In en, this message translates to:
  /// **'Stop using {categorization}?'**
  String disableCategorization(Object categorization);

  /// No description provided for @mergeRegistrationsWarning.
  ///
  /// In en, this message translates to:
  /// **'There are registrations in multiple {categorization}. By deactivating {categorization} the competitions and their registration lists are merged.\n\nAny existing seedings and draws cannot be combined and will be lost.\n\nThis can\'t be undone. Continue?'**
  String mergeRegistrationsWarning(Object categorization);

  /// No description provided for @deleteCategoryWarning.
  ///
  /// In en, this message translates to:
  /// **'By deleting the {category} {categoryName} the corresponding competitions are also deleted.\n\nContinue?'**
  String deleteCategoryWarning(Object category, Object categoryName);

  /// No description provided for @selection.
  ///
  /// In en, this message translates to:
  /// **'Selection'**
  String get selection;

  /// No description provided for @noSelection.
  ///
  /// In en, this message translates to:
  /// **'No selection'**
  String get noSelection;

  /// No description provided for @continueWithoutSelection.
  ///
  /// In en, this message translates to:
  /// **'Continue without selection'**
  String get continueWithoutSelection;

  /// No description provided for @deleteAndMergeCategoryWarning.
  ///
  /// In en, this message translates to:
  /// **'By deleting the {category} {categoryName} the corresponding competitions including registrations are also deleted.\nA replacement {category} can be selected where the registrations will be transferred to:'**
  String deleteAndMergeCategoryWarning(Object category, Object categoryName);

  /// No description provided for @deleteCompetitions.
  ///
  /// In en, this message translates to:
  /// **'Delete competitions?'**
  String get deleteCompetitions;

  /// No description provided for @deleteCompetitionsWarning.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Really delete the selected competition?} other{Really delete the selected competitions?}}'**
  String deleteCompetitionsWarning(num count);

  /// No description provided for @deleteCompetitionsWithTeamsWarning.
  ///
  /// In en, this message translates to:
  /// **'The competitions already have registered players.'**
  String get deleteCompetitionsWithTeamsWarning;

  /// No description provided for @competitionCantBeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Running competitions cannot be deleted'**
  String get competitionCantBeDeleted;

  /// No description provided for @orMore.
  ///
  /// In en, this message translates to:
  /// **'or more'**
  String get orMore;

  /// No description provided for @orLess.
  ///
  /// In en, this message translates to:
  /// **'or less'**
  String get orLess;

  /// No description provided for @showRegistrations.
  ///
  /// In en, this message translates to:
  /// **'Show registration list'**
  String get showRegistrations;

  /// No description provided for @gym.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Hall} other{Halls}}'**
  String gym(num count);

  /// No description provided for @row.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Row} other{Rows}}'**
  String row(num count);

  /// No description provided for @column.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Column} other{Columns}}'**
  String column(num count);

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @gymFloorPlan.
  ///
  /// In en, this message translates to:
  /// **'Hall floor plan'**
  String get gymFloorPlan;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @gymFloorPlanHelpMessage.
  ///
  /// In en, this message translates to:
  /// **'The plan describes how the courts are arranged in the hall. Thus, a maximum of {rows}x{columns} courts fit into the hall. It is up to you which of the courts are actually used.'**
  String gymFloorPlanHelpMessage(Object columns, Object rows);

  /// No description provided for @courtN.
  ///
  /// In en, this message translates to:
  /// **'Court {n}'**
  String courtN(Object n);

  /// No description provided for @noGymnasiumSelected.
  ///
  /// In en, this message translates to:
  /// **'Select a hall to edit the courts'**
  String get noGymnasiumSelected;

  /// No description provided for @addFirstGymnasium.
  ///
  /// In en, this message translates to:
  /// **'Add your first hall'**
  String get addFirstGymnasium;

  /// No description provided for @zoom.
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get zoom;

  /// No description provided for @resetView.
  ///
  /// In en, this message translates to:
  /// **'Reset view'**
  String get resetView;

  /// No description provided for @deleteGymWarning.
  ///
  /// In en, this message translates to:
  /// **'Really delete the hall with all courts?'**
  String get deleteGymWarning;

  /// No description provided for @addAllMissingCourts.
  ///
  /// In en, this message translates to:
  /// **'Add all missing courts'**
  String get addAllMissingCourts;

  /// No description provided for @reduceHall.
  ///
  /// In en, this message translates to:
  /// **'Reduce hall?'**
  String get reduceHall;

  /// No description provided for @reduceHallWarning.
  ///
  /// In en, this message translates to:
  /// **'By shrinking the hall\'s floor plan, court will be deleted. Continue?'**
  String get reduceHallWarning;

  /// No description provided for @numberCourts.
  ///
  /// In en, this message translates to:
  /// **'Number courts consecutively'**
  String get numberCourts;

  /// No description provided for @cantReduceHall.
  ///
  /// In en, this message translates to:
  /// **'Hall size can\'t be reduced'**
  String get cantReduceHall;

  /// No description provided for @cantReduceHallInfo.
  ///
  /// In en, this message translates to:
  /// **'Reducing the hall size would delete courts where matches are running.'**
  String get cantReduceHallInfo;

  /// No description provided for @cantDeleteHall.
  ///
  /// In en, this message translates to:
  /// **'Hall can\'t be deleted'**
  String get cantDeleteHall;

  /// No description provided for @cantDeleteHallInfo.
  ///
  /// In en, this message translates to:
  /// **'The hall can not be deleted because there are matches running there.'**
  String get cantDeleteHallInfo;

  /// No description provided for @countingDirection.
  ///
  /// In en, this message translates to:
  /// **'Counting direction'**
  String get countingDirection;

  /// No description provided for @rowWise.
  ///
  /// In en, this message translates to:
  /// **'Row by row'**
  String get rowWise;

  /// No description provided for @columnWise.
  ///
  /// In en, this message translates to:
  /// **'Column by colum'**
  String get columnWise;

  /// No description provided for @allGyms.
  ///
  /// In en, this message translates to:
  /// **'Throughout all halls'**
  String get allGyms;

  /// No description provided for @onlyGym.
  ///
  /// In en, this message translates to:
  /// **'Just this hall'**
  String get onlyGym;

  /// No description provided for @emptyCourts.
  ///
  /// In en, this message translates to:
  /// **'Empty courts'**
  String get emptyCourts;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count in'**
  String get count;

  /// No description provided for @assign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// No description provided for @assignTournamentMode.
  ///
  /// In en, this message translates to:
  /// **'Assign tournament mode'**
  String get assignTournamentMode;

  /// No description provided for @changeTournamentMode.
  ///
  /// In en, this message translates to:
  /// **'Change tournament mode'**
  String get changeTournamentMode;

  /// No description provided for @tournamentModeCantBeAssigned.
  ///
  /// In en, this message translates to:
  /// **'Tournament mode can\'t be change on a running competition'**
  String get tournamentModeCantBeAssigned;

  /// No description provided for @roundRobin.
  ///
  /// In en, this message translates to:
  /// **'Round robin'**
  String get roundRobin;

  /// No description provided for @singleElimination.
  ///
  /// In en, this message translates to:
  /// **'Single elimination'**
  String get singleElimination;

  /// No description provided for @doubleElimination.
  ///
  /// In en, this message translates to:
  /// **'Double elimination'**
  String get doubleElimination;

  /// No description provided for @consolationElimination.
  ///
  /// In en, this message translates to:
  /// **'Elimination with consolation rounds'**
  String get consolationElimination;

  /// No description provided for @groupKnockout.
  ///
  /// In en, this message translates to:
  /// **'Group tournament'**
  String get groupKnockout;

  /// No description provided for @roundRobinHelp.
  ///
  /// In en, this message translates to:
  /// **'Each participant plays everyone else. How often is determined by the configurable number of rounds.'**
  String get roundRobinHelp;

  /// No description provided for @singleEliminationHelp.
  ///
  /// In en, this message translates to:
  /// **'A tournament bracket that ends in a final. To make a match for 3rd place or play out more ranks use the \"elimination with consolation rounds\" mode.'**
  String get singleEliminationHelp;

  /// No description provided for @doubleEliminationHelp.
  ///
  /// In en, this message translates to:
  /// **'In a double elimination participants go into a \"lower\" bracket after their first loss. Another loss eliminates the participant. The final is played between the last unbeaten participant and the winner of the lower bracket.'**
  String get doubleEliminationHelp;

  /// No description provided for @consolationEliminationHelp.
  ///
  /// In en, this message translates to:
  /// **'In this elimination format, additional consolation rounds can be scheduled for the losers of the main round. A minimum number of matches per participant can be guaranteed and/or a certain number of final placements can be played out.'**
  String get consolationEliminationHelp;

  /// No description provided for @groupKnockoutHelp.
  ///
  /// In en, this message translates to:
  /// **'The group stage consists of a round robin in each group. The top ranked participants of each group advance to an elimination stage.'**
  String get groupKnockoutHelp;

  /// No description provided for @pleaseChoose.
  ///
  /// In en, this message translates to:
  /// **'Please choose'**
  String get pleaseChoose;

  /// No description provided for @tournamentMode.
  ///
  /// In en, this message translates to:
  /// **'Tournament mode'**
  String get tournamentMode;

  /// No description provided for @seedingMode.
  ///
  /// In en, this message translates to:
  /// **'Seeding mode'**
  String get seedingMode;

  /// No description provided for @seedingModeLabel.
  ///
  /// In en, this message translates to:
  /// **'{type, select, single{Single} tiered{Tiered} other{Other}}'**
  String seedingModeLabel(String type);

  /// No description provided for @singleSeedingHelp.
  ///
  /// In en, this message translates to:
  /// **'Every seed list entry gets their own rank.'**
  String get singleSeedingHelp;

  /// No description provided for @tieredSeedingHelp.
  ///
  /// In en, this message translates to:
  /// **'1st and 2nd seed are individually set. Afterwards the ranks will be staggered in tiers: 3/4, 5/8, 9/16, etc.'**
  String get tieredSeedingHelp;

  /// No description provided for @passes.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get passes;

  /// No description provided for @roundRobinPassesHelp.
  ///
  /// In en, this message translates to:
  /// **'How often everyone plays everyone else. E.g. 2 means each matchup happens twice.'**
  String get roundRobinPassesHelp;

  /// No description provided for @numGroups.
  ///
  /// In en, this message translates to:
  /// **'Number of groups'**
  String get numGroups;

  /// No description provided for @numGroupsHelp.
  ///
  /// In en, this message translates to:
  /// **'How many groups the participants will be divided among. Manual assignments are possible after the draw.'**
  String get numGroupsHelp;

  /// No description provided for @numQualifications.
  ///
  /// In en, this message translates to:
  /// **'Number of qualifications'**
  String get numQualifications;

  /// No description provided for @numQualificationsHelp.
  ///
  /// In en, this message translates to:
  /// **'How many will advance from the groups to the knockout round.'**
  String get numQualificationsHelp;

  /// No description provided for @entryList.
  ///
  /// In en, this message translates to:
  /// **'Entry list/Seeds'**
  String get entryList;

  /// No description provided for @addToSeeds.
  ///
  /// In en, this message translates to:
  /// **'Add to seeds'**
  String get addToSeeds;

  /// No description provided for @removeFromSeeds.
  ///
  /// In en, this message translates to:
  /// **'Remove from seeds'**
  String get removeFromSeeds;

  /// No description provided for @noDrawCompetitionSelected.
  ///
  /// In en, this message translates to:
  /// **'Select a competition to make a draw'**
  String get noDrawCompetitionSelected;

  /// No description provided for @noResultCompetitionSelected.
  ///
  /// In en, this message translates to:
  /// **'Select a competition to see the results'**
  String get noResultCompetitionSelected;

  /// No description provided for @noResultsYet.
  ///
  /// In en, this message translates to:
  /// **'There are no scores for this competition yet'**
  String get noResultsYet;

  /// No description provided for @noTournamentMode.
  ///
  /// In en, this message translates to:
  /// **'This competition has no tournament mode assigned'**
  String get noTournamentMode;

  /// No description provided for @makeDraw.
  ///
  /// In en, this message translates to:
  /// **'Make draw'**
  String get makeDraw;

  /// No description provided for @bye.
  ///
  /// In en, this message translates to:
  /// **'Bye'**
  String get bye;

  /// No description provided for @freeOfPlay.
  ///
  /// In en, this message translates to:
  /// **'Free of play'**
  String get freeOfPlay;

  /// No description provided for @encounterNumber.
  ///
  /// In en, this message translates to:
  /// **'{number}. Encounter'**
  String encounterNumber(Object number);

  /// No description provided for @participant.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Participant} other{Participants}}'**
  String participant(num count);

  /// No description provided for @groupNumber.
  ///
  /// In en, this message translates to:
  /// **'Group {number}'**
  String groupNumber(Object number);

  /// No description provided for @groupQualification.
  ///
  /// In en, this message translates to:
  /// **'{place}. Place, Group {group}'**
  String groupQualification(Object group, Object place);

  /// No description provided for @contestedGroupQualification.
  ///
  /// In en, this message translates to:
  /// **'{place}. Place, dependant on group results'**
  String contestedGroupQualification(Object place);

  /// No description provided for @roundOfN.
  ///
  /// In en, this message translates to:
  /// **'{participants, select, 2{Final} 4{Semi-Final} 8{Quarter-Final} other{Round of {participants}}}'**
  String roundOfN(String participants);

  /// No description provided for @roundN.
  ///
  /// In en, this message translates to:
  /// **'Round {roundNumber}'**
  String roundN(Object roundNumber);

  /// No description provided for @matchN.
  ///
  /// In en, this message translates to:
  /// **'Match {matchNumber}'**
  String matchN(Object matchNumber);

  /// No description provided for @loserRoundN.
  ///
  /// In en, this message translates to:
  /// **'Loser\'s {round}'**
  String loserRoundN(Object round);

  /// No description provided for @groupPhaseRoundN.
  ///
  /// In en, this message translates to:
  /// **'Gruppenphase {round}'**
  String groupPhaseRoundN(Object round);

  /// No description provided for @collapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapse;

  /// No description provided for @undoManualDraw.
  ///
  /// In en, this message translates to:
  /// **'Reset manual changes'**
  String get undoManualDraw;

  /// No description provided for @redraw.
  ///
  /// In en, this message translates to:
  /// **'Redraw'**
  String get redraw;

  /// No description provided for @undoManualDrawWarning.
  ///
  /// In en, this message translates to:
  /// **'Really reset the manual changes to the draw?\nThis will update entries who\'s attendance status changed since the last draw.'**
  String get undoManualDrawWarning;

  /// No description provided for @redrawWarning.
  ///
  /// In en, this message translates to:
  /// **'Really redo the draw?\nThis will update entries who\'s attendance status changed since the last draw.'**
  String get redrawWarning;

  /// No description provided for @deleteDrawWarning.
  ///
  /// In en, this message translates to:
  /// **'Really delete the draw?\nAfterwards the tournament mode and seed list will be editable again.'**
  String get deleteDrawWarning;

  /// No description provided for @seedsNotEditable.
  ///
  /// In en, this message translates to:
  /// **'The seeds can\'t be edited because a draw already exists. Delete the draw to be able to edit the seeds.'**
  String get seedsNotEditable;

  /// No description provided for @teamNotAttending.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The player does not have the \'attending\' status yet. They wont be included in the match plan when drawing.} other{One or more players on this team do not have the \'attending\' status yet. The team wont be included in the match plan when drawing.}}'**
  String teamNotAttending(num count);

  /// No description provided for @teamNotComplete.
  ///
  /// In en, this message translates to:
  /// **'This team does not have enough members. They wont be included in the match plan when drawing.'**
  String get teamNotComplete;

  /// No description provided for @teamsReady.
  ///
  /// In en, this message translates to:
  /// **'{ready, plural, =1{{ready} Team ready (of {total})} other{{ready} Teams ready (of {total})}}'**
  String teamsReady(num ready, Object total);

  /// No description provided for @notEnoughDrawParticipants.
  ///
  /// In en, this message translates to:
  /// **'Not enough teams'**
  String get notEnoughDrawParticipants;

  /// No description provided for @notEnoughDrawParticipantsInfo.
  ///
  /// In en, this message translates to:
  /// **'At least {count} teams need to be ready to make a draw for the given tournament mode.\nRegister more teams or change the tournament mode.\n\nHint: Players need to have the \'attending\' status to be considered ready.'**
  String notEnoughDrawParticipantsInfo(Object count);

  /// No description provided for @drawsWillBeOverridden.
  ///
  /// In en, this message translates to:
  /// **'Existing draws'**
  String get drawsWillBeOverridden;

  /// No description provided for @drawsWillBeOverriddenInfo.
  ///
  /// In en, this message translates to:
  /// **'By changing the tournament mode existing draws will be removed.\n\nContinue?'**
  String get drawsWillBeOverriddenInfo;

  /// No description provided for @noCompetitionsRegistrationHint.
  ///
  /// In en, this message translates to:
  /// **'Add a competition to become able to make registrations'**
  String get noCompetitionsRegistrationHint;

  /// No description provided for @allCompetitionsRunningHint.
  ///
  /// In en, this message translates to:
  /// **'All competitions are running or have been registered for'**
  String get allCompetitionsRunningHint;

  /// No description provided for @noCompetitionsDrawHint.
  ///
  /// In en, this message translates to:
  /// **'No competitions.\n\nAdd a competition and register participants to make a draw.'**
  String get noCompetitionsDrawHint;

  /// No description provided for @noCompetitionsResultHint.
  ///
  /// In en, this message translates to:
  /// **'Keine Disziplinen.\n\nAdd a competition and start it to see results.'**
  String get noCompetitionsResultHint;

  /// No description provided for @matchOperations.
  ///
  /// In en, this message translates to:
  /// **'Match operations'**
  String get matchOperations;

  /// No description provided for @startTournament.
  ///
  /// In en, this message translates to:
  /// **'Start tournament'**
  String get startTournament;

  /// No description provided for @startTournamentInfo.
  ///
  /// In en, this message translates to:
  /// **'You are about to start the tournament for the selected competitions.\nThe matches will appear on the \'Matches\' tab and the tournament operations can commence!'**
  String get startTournamentInfo;

  /// No description provided for @cancelTournament.
  ///
  /// In en, this message translates to:
  /// **'Cancel tournament'**
  String get cancelTournament;

  /// No description provided for @cancelTournamentInfo.
  ///
  /// In en, this message translates to:
  /// **'Canceling the tournament for this competition means deleting all previously played matches and results in this competition. The tournament mode and draw for the competition can then be edited again. The deletion of the match results cannot be undone.\n\nDo you really want to cancel the tournament for this competition and delete the previous match results?'**
  String get cancelTournamentInfo;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @tournamentCouldNotStart.
  ///
  /// In en, this message translates to:
  /// **'The tournament could not be started'**
  String get tournamentCouldNotStart;

  /// No description provided for @matchQueue.
  ///
  /// In en, this message translates to:
  /// **'Match queue'**
  String get matchQueue;

  /// No description provided for @readyForCallout.
  ///
  /// In en, this message translates to:
  /// **'Ready for call out'**
  String get readyForCallout;

  /// No description provided for @runningMatches.
  ///
  /// In en, this message translates to:
  /// **'Running matches'**
  String get runningMatches;

  /// No description provided for @matchWaitingStatus.
  ///
  /// In en, this message translates to:
  /// **'{status, select, waitingForCourt{Waiting for court} waitingForRest{Waiting for rest time} waitingForPlayer{Waiting for player} waitingForProgress{Waiting for tournament progress} other{OTHER}}'**
  String matchWaitingStatus(String status);

  /// No description provided for @matchesReady.
  ///
  /// In en, this message translates to:
  /// **'{ready, plural, =1{Match ready} other{Matches ready}}'**
  String matchesReady(num ready);

  /// No description provided for @nextMatch.
  ///
  /// In en, this message translates to:
  /// **'Next match'**
  String get nextMatch;

  /// No description provided for @showFullRound.
  ///
  /// In en, this message translates to:
  /// **'Show full round'**
  String get showFullRound;

  /// No description provided for @versusAbbreviated.
  ///
  /// In en, this message translates to:
  /// **'vs'**
  String get versusAbbreviated;

  /// No description provided for @versus.
  ///
  /// In en, this message translates to:
  /// **'versus'**
  String get versus;

  /// No description provided for @qualificationPending.
  ///
  /// In en, this message translates to:
  /// **'Qualification pending'**
  String get qualificationPending;

  /// No description provided for @playMatchHere.
  ///
  /// In en, this message translates to:
  /// **'Play match here'**
  String get playMatchHere;

  /// No description provided for @assignCourt.
  ///
  /// In en, this message translates to:
  /// **'Assign court'**
  String get assignCourt;

  /// No description provided for @roundRobinMatchN.
  ///
  /// In en, this message translates to:
  /// **'Round robin\nRound {number}'**
  String roundRobinMatchN(Object number);

  /// No description provided for @groupNMatchN.
  ///
  /// In en, this message translates to:
  /// **'Group {group}\nRound {match}'**
  String groupNMatchN(Object group, Object match);

  /// No description provided for @callOutMatch.
  ///
  /// In en, this message translates to:
  /// **'Call out match'**
  String get callOutMatch;

  /// No description provided for @backToWaitList.
  ///
  /// In en, this message translates to:
  /// **'Back to wait list'**
  String get backToWaitList;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get on;

  /// No description provided for @matchCalledOut.
  ///
  /// In en, this message translates to:
  /// **'Match called out'**
  String get matchCalledOut;

  /// No description provided for @matchCallOut.
  ///
  /// In en, this message translates to:
  /// **'Match call'**
  String get matchCallOut;

  /// No description provided for @callOutAll.
  ///
  /// In en, this message translates to:
  /// **'Call out all'**
  String get callOutAll;

  /// No description provided for @nMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 minute} other{{minutes} minutes}}'**
  String nMinutes(num minutes);

  /// No description provided for @playingTime.
  ///
  /// In en, this message translates to:
  /// **'Playing time'**
  String get playingTime;

  /// No description provided for @matchPlanned.
  ///
  /// In en, this message translates to:
  /// **'Match planned'**
  String get matchPlanned;

  /// No description provided for @enterResult.
  ///
  /// In en, this message translates to:
  /// **'Enter result'**
  String get enterResult;

  /// No description provided for @editResult.
  ///
  /// In en, this message translates to:
  /// **'Edit result'**
  String get editResult;

  /// No description provided for @deleteResult.
  ///
  /// In en, this message translates to:
  /// **'Delete result'**
  String get deleteResult;

  /// No description provided for @deleteResultInfo.
  ///
  /// In en, this message translates to:
  /// **'Really delete the result? Matches that might be depending on this result will be reset to the match queue.'**
  String get deleteResultInfo;

  /// No description provided for @callOutHelp.
  ///
  /// In en, this message translates to:
  /// **'Tell the match participants, who and where they play. The match is then considered to be running.'**
  String get callOutHelp;

  /// No description provided for @resultEnteringHelp.
  ///
  /// In en, this message translates to:
  /// **'When a match is finished enter the result here.\n\nTip: For each game, just enter the loser\'s points and press ENTER to autocomplete the game score!'**
  String get resultEnteringHelp;

  /// No description provided for @nBlockingPlayers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 player\nis in another match} other{{count} players\nare in another match}}'**
  String nBlockingPlayers(num count);

  /// No description provided for @blockingGames.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Blocking match} other{Blocking matches}}'**
  String blockingGames(num count);

  /// No description provided for @tournamentIsStarted.
  ///
  /// In en, this message translates to:
  /// **'Tournament has been started'**
  String get tournamentIsStarted;

  /// No description provided for @playMode.
  ///
  /// In en, this message translates to:
  /// **'Play mode'**
  String get playMode;

  /// No description provided for @winningPoints.
  ///
  /// In en, this message translates to:
  /// **'Winning points'**
  String get winningPoints;

  /// No description provided for @winningPointsHelp.
  ///
  /// In en, this message translates to:
  /// **'Number of points required to win a game'**
  String get winningPointsHelp;

  /// No description provided for @winningSets.
  ///
  /// In en, this message translates to:
  /// **'Winning games'**
  String get winningSets;

  /// No description provided for @winningSetsHelp.
  ///
  /// In en, this message translates to:
  /// **'Number of games required to win a match. With {count} winning games, there will be {maxCount} games at most.'**
  String winningSetsHelp(Object count, Object maxCount);

  /// No description provided for @twoPointMargin.
  ///
  /// In en, this message translates to:
  /// **'2-point margin'**
  String get twoPointMargin;

  /// No description provided for @twoPointMarginHelp.
  ///
  /// In en, this message translates to:
  /// **'Whether the winner needs a minimum 2-point margin to win a game. If the winning points are reached without this margin, play continues until a player can establish the lead.'**
  String get twoPointMarginHelp;

  /// No description provided for @maxPoints.
  ///
  /// In en, this message translates to:
  /// **'Max. points'**
  String get maxPoints;

  /// No description provided for @maxPointsHelp.
  ///
  /// In en, this message translates to:
  /// **'The maximum number of points that can be reached. If no player can establish the 2-point margin, the one who reaches the maximum points first wins.'**
  String get maxPointsHelp;

  /// No description provided for @maxPointsError.
  ///
  /// In en, this message translates to:
  /// **'Value too low'**
  String get maxPointsError;

  /// No description provided for @gameSheetPrintingTitle.
  ///
  /// In en, this message translates to:
  /// **'Which game sheets should be printed?'**
  String get gameSheetPrintingTitle;

  /// No description provided for @gameSheetPrintingHelp.
  ///
  /// In en, this message translates to:
  /// **'The players can record their match results on the game sheets and return them to the tournament administration.\n\nOutside the manual selection, game sheets will only be printed once. Depending on the used print option, some game sheets need to be completed by hand.'**
  String get gameSheetPrintingHelp;

  /// No description provided for @gameSheetPrinting.
  ///
  /// In en, this message translates to:
  /// **'Game sheet printing'**
  String get gameSheetPrinting;

  /// No description provided for @gameSheetPrintSelection.
  ///
  /// In en, this message translates to:
  /// **'{selection, select, readyForCallOut{Matches that are ready for call out} playersQualified{Matches where both opponents are determined} playersPartiallyQualified{Matches where at least one opponent is determined} allUpcoming{All game sheets} custom{Manual selection} other{OTHER}}'**
  String gameSheetPrintSelection(String selection);

  /// No description provided for @gameSheetPrintSelectionHelp.
  ///
  /// In en, this message translates to:
  /// **'{selection, select, readyForCallOut{On these game sheets, no handwritten entries need to be made, as the opponents and fields are already determined.} playersQualified{With this option, sheets are also printed that do not have a court assigned. Instead, a blank space is printed for handwritten completion.} playersPartiallyQualified{With this option, sheets are also printed that only have one opponent determined. When the other opponent qualifies, the sheet has to be completed with handwriting.} allUpcoming{With this option, sheets are printed for all upcoming matches. It doesn\'t matter whether the court and opponents have already been determined; for the missing data, blank spaces are printed for handwritten completion.} custom{This option allows making a selection for printing sheets from all matches of the currently running tournament. Can be used to reprint sheets.} other{OTHER}}'**
  String gameSheetPrintSelectionHelp(String selection);

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Vorschau'**
  String get preview;

  /// No description provided for @gameSheetPrintPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview ({sheets} on {pages})'**
  String gameSheetPrintPreview(Object pages, Object sheets);

  /// No description provided for @nSheets.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 sheet} other{{count} sheets}}'**
  String nSheets(num count);

  /// No description provided for @nPages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String nPages(num count);

  /// No description provided for @saveAndOpenPdf.
  ///
  /// In en, this message translates to:
  /// **'Save PDF and open'**
  String get saveAndOpenPdf;

  /// No description provided for @openSaveLocation.
  ///
  /// In en, this message translates to:
  /// **'Open save location'**
  String get openSaveLocation;

  /// No description provided for @noSheetsToPrint.
  ///
  /// In en, this message translates to:
  /// **'The current selection icludes no game sheets that need printing.'**
  String get noSheetsToPrint;

  /// No description provided for @changeSelection.
  ///
  /// In en, this message translates to:
  /// **'Change selection'**
  String get changeSelection;

  /// No description provided for @selectGameSheetsToPrint.
  ///
  /// In en, this message translates to:
  /// **'Select matches for printing'**
  String get selectGameSheetsToPrint;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @sheetCreated.
  ///
  /// In en, this message translates to:
  /// **'Game sheet already created once'**
  String get sheetCreated;

  /// No description provided for @sheetNotCreated.
  ///
  /// In en, this message translates to:
  /// **'Game sheet not created yet'**
  String get sheetNotCreated;

  /// No description provided for @printingCategory.
  ///
  /// In en, this message translates to:
  /// **'{status, select, readyForCallOut{Ready for call out} noCourt{No court assigned} waitingForQualification{Waiting for qualification} alreadyRunning{Running matches} other{OTHER}}'**
  String printingCategory(String status);

  /// No description provided for @dontReprintGameSheets.
  ///
  /// In en, this message translates to:
  /// **'Don\'t reprint game sheets'**
  String get dontReprintGameSheets;

  /// No description provided for @dontReprintGameSheetsHelp.
  ///
  /// In en, this message translates to:
  /// **'With this option, game sheets that have been printed before wont be reprinted (except in a manual selection).'**
  String get dontReprintGameSheetsHelp;

  /// No description provided for @printQrCodes.
  ///
  /// In en, this message translates to:
  /// **'Print QR codes'**
  String get printQrCodes;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @cancelMatch.
  ///
  /// In en, this message translates to:
  /// **'Cancel match\n(back to call out list)'**
  String get cancelMatch;

  /// No description provided for @cancelMatchConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Really cancel match?'**
  String get cancelMatchConfirmation;

  /// No description provided for @cancelMatchInfo.
  ///
  /// In en, this message translates to:
  /// **'The match can be started again, the match duration will be reset.'**
  String get cancelMatchInfo;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @courtModeSetting.
  ///
  /// In en, this message translates to:
  /// **'Court assignment mode'**
  String get courtModeSetting;

  /// No description provided for @courtMode.
  ///
  /// In en, this message translates to:
  /// **'{mode, select, manual{Manual} autoCourtAssignment{Automatic} other{OTHER}}'**
  String courtMode(String mode);

  /// No description provided for @courtModeHelp.
  ///
  /// In en, this message translates to:
  /// **'{mode, select, manual{Court assignment is done manually.} autoCourtAssignment{Matches are automatically assigned to an open court.} other{OTHER}}'**
  String courtModeHelp(String mode);

  /// No description provided for @playerRestTime.
  ///
  /// In en, this message translates to:
  /// **'Rest time'**
  String get playerRestTime;

  /// No description provided for @playerRestTimeHelp.
  ///
  /// In en, this message translates to:
  /// **'Matches are held in the queue until all participants have had at least {minutes} break since their last game.'**
  String playerRestTimeHelp(Object minutes);

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{minute} other{minutes}}'**
  String minute(num count);

  /// No description provided for @nOpenCourts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No open courts} =1{1 open court} other{{count} open courts}}'**
  String nOpenCourts(num count);

  /// No description provided for @matchWaitsForCourt.
  ///
  /// In en, this message translates to:
  /// **'Match is waiting for open court'**
  String get matchWaitsForCourt;

  /// No description provided for @playerWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal of a tournament participant'**
  String get playerWithdrawal;

  /// No description provided for @playerWithdrawalInfo.
  ///
  /// In en, this message translates to:
  /// **'You have withdrawn the \'Attending\' status of {playerName}.\n\nSelect the competitions in which the player no longer competes. The listed matches will then be counted as lost:'**
  String playerWithdrawalInfo(Object playerName);

  /// No description provided for @playerReentering.
  ///
  /// In en, this message translates to:
  /// **'Re-entering of a tournament participant'**
  String get playerReentering;

  /// No description provided for @playerReenteringInfo.
  ///
  /// In en, this message translates to:
  /// **'You have set the status of {playerName} back to \'Attending\'.\n\nThe player can re-enter competitions if the competition has not progressed since the withdrawal.\n\nSelect the competitions in which re-entry is desired. The listed matches will then be scored normally again or must still be played:'**
  String playerReenteringInfo(Object playerName);

  /// No description provided for @playerCannotReenter.
  ///
  /// In en, this message translates to:
  /// **'Competition progressed.\nRe-entry not possible.'**
  String get playerCannotReenter;

  /// No description provided for @unlockCourt.
  ///
  /// In en, this message translates to:
  /// **'Unlock court\n(Enter result later)'**
  String get unlockCourt;

  /// No description provided for @matchEnded.
  ///
  /// In en, this message translates to:
  /// **'Match ended'**
  String get matchEnded;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Result} other{Results}}'**
  String result(num count);

  /// No description provided for @resultManagement.
  ///
  /// In en, this message translates to:
  /// **'Manage results'**
  String get resultManagement;

  /// No description provided for @win.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Win} other{Wins}}'**
  String win(num count);

  /// No description provided for @game.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Game} other{Games}}'**
  String game(num count);

  /// No description provided for @point.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Point} other{Points}}'**
  String point(num count);

  /// No description provided for @walkover.
  ///
  /// In en, this message translates to:
  /// **'Walkover'**
  String get walkover;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @provisionalLeaderboardInfo.
  ///
  /// In en, this message translates to:
  /// **'The competition has not yet been completed. The current provisional status of the leaderboard is displayed.'**
  String get provisionalLeaderboardInfo;

  /// No description provided for @nthPlace.
  ///
  /// In en, this message translates to:
  /// **'{place}. Place'**
  String nthPlace(Object place);

  /// No description provided for @breakTie.
  ///
  /// In en, this message translates to:
  /// **'Break tie'**
  String get breakTie;

  /// No description provided for @breakTieInfo.
  ///
  /// In en, this message translates to:
  /// **'Break the tie of these participants. Order the list using drag & drop.'**
  String get breakTieInfo;

  /// No description provided for @editTieBreaker.
  ///
  /// In en, this message translates to:
  /// **'Edit tie breaker'**
  String get editTieBreaker;

  /// No description provided for @deleteTieBreaker.
  ///
  /// In en, this message translates to:
  /// **'Delete tie breaker'**
  String get deleteTieBreaker;

  /// No description provided for @tournamentProgressBlocked.
  ///
  /// In en, this message translates to:
  /// **'Tournament progress blocked.'**
  String get tournamentProgressBlocked;

  /// No description provided for @tieBreakerRequired.
  ///
  /// In en, this message translates to:
  /// **'Tie breaker required!'**
  String get tieBreakerRequired;

  /// No description provided for @noMatchesHint.
  ///
  /// In en, this message translates to:
  /// **'Start a competition that has a draw on the \'Competitions\' tab to see the matches here'**
  String get noMatchesHint;

  /// No description provided for @losersBracket.
  ///
  /// In en, this message translates to:
  /// **'Losers Bracket'**
  String get losersBracket;

  /// No description provided for @smallFinal.
  ///
  /// In en, this message translates to:
  /// **'Small Final'**
  String get smallFinal;

  /// No description provided for @smallLoserFinal.
  ///
  /// In en, this message translates to:
  /// **'Small Loser\'s Final'**
  String get smallLoserFinal;

  /// No description provided for @loserOfMatch.
  ///
  /// In en, this message translates to:
  /// **'Loser {match}'**
  String loserOfMatch(Object match);

  /// No description provided for @numConsolationRounds.
  ///
  /// In en, this message translates to:
  /// **'Guaranteed matches'**
  String get numConsolationRounds;

  /// No description provided for @numConsolationRoundsHelp.
  ///
  /// In en, this message translates to:
  /// **'Each player is allowed to lose at least {matches} before being eliminated. The required number of consolation rounds will be added automatically.\n\nNote: With certain odd numbers of participants, it may happen that a player finishes last after losing the first game despite a consolation round being present.'**
  String numConsolationRoundsHelp(Object matches);

  /// No description provided for @placesToPlayOut.
  ///
  /// In en, this message translates to:
  /// **'Placements to play out'**
  String get placesToPlayOut;

  /// No description provided for @placesToPlayOutHelp.
  ///
  /// In en, this message translates to:
  /// **'The tournament bracket will produce at least {numPlaces} untied top placements. The required consolation rounds will be added automatically.'**
  String placesToPlayOutHelp(Object numPlaces);

  /// No description provided for @tooFewPlacesToPlayOut.
  ///
  /// In en, this message translates to:
  /// **'At least 2 places have to be played out'**
  String get tooFewPlacesToPlayOut;

  /// No description provided for @upperToLowerRank.
  ///
  /// In en, this message translates to:
  /// **'Rank {upper} – {lower}'**
  String upperToLowerRank(Object lower, Object upper);

  /// No description provided for @matchForThrid.
  ///
  /// In en, this message translates to:
  /// **'Match for 3rd place'**
  String get matchForThrid;

  /// No description provided for @matchForNthPlace.
  ///
  /// In en, this message translates to:
  /// **'Match for\n{place}. place'**
  String matchForNthPlace(Object place);

  /// No description provided for @noneOf.
  ///
  /// In en, this message translates to:
  /// **'No {subject}'**
  String noneOf(Object subject);

  /// No description provided for @noCategoryWarning.
  ///
  /// In en, this message translates to:
  /// **'The {categorization} can\'t be activated because no {category} has been created.'**
  String noCategoryWarning(Object categorization, Object category);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @crossGroupTies.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Cross Group Tie} other{Cross Group Ties}}'**
  String crossGroupTies(num count);

  /// No description provided for @knockOutMode.
  ///
  /// In en, this message translates to:
  /// **'Knock-Out mode'**
  String get knockOutMode;

  /// No description provided for @planPrinting.
  ///
  /// In en, this message translates to:
  /// **'Print match plans'**
  String get planPrinting;

  /// No description provided for @pageNofM.
  ///
  /// In en, this message translates to:
  /// **'Page {n} of {m}'**
  String pageNofM(Object m, Object n);

  /// No description provided for @noMatchPlans.
  ///
  /// In en, this message translates to:
  /// **'Select the competitions that the plans should be generated for'**
  String get noMatchPlans;

  /// No description provided for @noDrawnCompetitions.
  ///
  /// In en, this message translates to:
  /// **'There are no competitions with drawn match plan yet'**
  String get noDrawnCompetitions;

  /// No description provided for @matchPlanPrintPages.
  ///
  /// In en, this message translates to:
  /// **'Choose page mode'**
  String get matchPlanPrintPages;

  /// No description provided for @multiPagePlan.
  ///
  /// In en, this message translates to:
  /// **'Distribute over pages'**
  String get multiPagePlan;

  /// No description provided for @bigPagePlan.
  ///
  /// In en, this message translates to:
  /// **'One big page'**
  String get bigPagePlan;

  /// No description provided for @multiPagePlanHelp.
  ///
  /// In en, this message translates to:
  /// **'The match plan is distributed across multiple pages if needed. After printing the plan can be cut out and pieced together.'**
  String get multiPagePlanHelp;

  /// No description provided for @bigPagePlanHelp.
  ///
  /// In en, this message translates to:
  /// **'The plan is put onto a single page. The page size follows the format of the plan. Note: The text can get an unreadable size when printing large plans.'**
  String get bigPagePlanHelp;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
