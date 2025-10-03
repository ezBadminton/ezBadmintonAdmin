import 'package:model_repository/model_repository.dart';
import 'package:flutter/material.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:sealed_currencies/sealed_currencies.dart';

// Max characters in the player search text field
const int playerSearchMaxLength = 50;

const int playingLevelNameMaxLength = 30;

const int courtNameMaxLength = 14;

const int roundRobinMaxPasses = 16;

const int maxGroups = 64;
const int minGroups = 2;

const int maxQualificationsPerGroup = 64;
const int minQualificationsPerGroup = 1;

const Map<PlayerStatus, IconData> playerStatusIcons = {
  PlayerStatus.notAttending: Icons.question_mark,
  PlayerStatus.attending: Icons.done,
  PlayerStatus.forfeited: Icons.flag_outlined,
  PlayerStatus.injured: Icons.local_hospital_outlined,
  PlayerStatus.disqualified: Icons.person_off,
};

const IconData partnerMissingIcon = Icons.group;

const List<Type> tournamentModes = [
  RoundRobinSettings,
  SingleEliminationSettings,
  GroupKnockoutSettings,
  DoubleEliminationSettings,
  SingleEliminationWithConsolationSettings,
];
const String matchQrPrefix = '\$match:';
const String matchQrSuffix = '\$';

class OrganizerAuthCollectionName extends AuthCollectionName {
  const OrganizerAuthCollectionName();
  @override
  String get authCollectionName => "tournament_organizer";
}

const OrganizerAuthCollectionName organizerAuthCollectionName =
    OrganizerAuthCollectionName();

class InfoscreenAuthCollectionName extends AuthCollectionName {
  const InfoscreenAuthCollectionName();
  @override
  String get authCollectionName => "infoscreen_users";
}

const InfoscreenAuthCollectionName infoscreenAuthCollectionName =
    InfoscreenAuthCollectionName();

/// Currencies used of all BWF national member associations
/// https://en.wikipedia.org/wiki/Badminton_World_Federation
const List<FiatCurrency> bwfCurrencies = [
  // ----- Badminton Asia -----
  // West
  // FiatBhd(), // Bahrain not supported because 1000 subunits
  FiatIrr(), // Iran
  // FiatIqd(), // Iraq not supported because 1000 subunits
  // FiatJod(), // Jordan not supported because 1000 subunits
  // FiatKwd(), // Kuwait not supported because 1000 subunits
  FiatLbp(), // Lebanon
  FiatIls(), // Palestine
  FiatQar(), // Qatar
  FiatSar(), // Saudi Arabia
  FiatSyp(), // Syria
  FiatAed(), // UAE
  // Central
  FiatKzt(), // Kazakhstan
  FiatKgs(), // Kyrgyzstan
  FiatTjs(), // Tajikistan
  FiatTmt(), // Turkmenistan
  FiatUzs(), // Uzbekistan
  // South
  FiatAfn(), // Afghanistan
  FiatBdt(), // Bangladesh
  FiatBtn(), // Bhutan
  FiatInr(), // India
  FiatMvr(), // Maledives
  FiatNpr(), // Nepal
  FiatPkr(), // Pakistan
  FiatLkr(), // Sri Lanka
  // East
  FiatCny(), // PR China
  FiatHkd(), // Hong Kong
  FiatJpy(), // Japan
  FiatMop(), // Macau
  FiatMnt(), // Mongolia
  // FiatKpw(), // North Korea not supported for lack of Badminton community
  FiatKrw(), // South Korea
  FiatTwd(), // Taiwan
  // Southeast
  FiatBnd(), // Brunei
  FiatKhr(), // Cambodia
  FiatIdr(), // Indonesia
  FiatLak(), // Laos
  FiatMyr(), // Malaysia
  FiatMmk(), // Myanmar
  FiatPhp(), // Philippines
  FiatSgd(), // Singapore
  FiatThb(), // Thailand
  // Timor Leste uses USD
  FiatVnd(), // Vietnam
  // Associates
  // FiatOmr(), // Oman not supported because 1000 subunits
  FiatYer(), // Yemen
  // ----- Badminton Europe -----
  FiatEur(),
  FiatAll(), // Albania
  FiatAmd(), // Armenia
  // Austria uses EUR
  FiatAzn(), // Azerbaijan
  // FiatByn(), // Belarus not supported because of federation's suspension
  // Belgium uses EUR
  FiatBam(), // Bosnia and Herzigovina
  FiatBgn(), // Bulgaria
  // Croatia uses EUR
  // Cyprus uses EUR
  FiatCzk(), // Czeck Republic
  FiatDkk(), // Denmark
  FiatGbp(), // England
  // Estonia uses EUR
  // Faroe Islands uses DKK
  // Finland uses EUR
  // France uses EUR
  FiatGel(), // Geogria
  // Germany uses EUR
  FiatGip(), // Gibraltar
  // Greece uses EUR
  // Greenland uses DKK
  FiatHuf(), // Hungary
  FiatIsk(), // Iceland
  // Ireland uses EUR
  // Israel uses ILS
  // Italy uses EUR
  // Kosovo uses EUR
  // Latvia uses EUR
  // Liechtenstein uses CHF
  // Lithuania uses EUR
  // Luxembourg uses EUR
  FiatMkd(), // North Macedonia
  // Malta uses EUR
  FiatMdl(), // Moldova
  // Monaco uses EUR
  // Montenegro uses EUR
  // Netherlands uses EUR
  FiatNok(), // Norway
  FiatPln(), // Poland
  // Portugal uses EUR
  FiatRon(), // Romania
  // FiatRub(), // Russia not supported because of federation's suspension
  // Scotland uses GBP
  FiatRsd(), // Serbia
  // Slovak Republic uses EUR
  // Slovenia uses EUR
  // Spain uses EUR
  FiatSek(), // Sweden
  FiatChf(), // Switzerland
  FiatTry(), // Turkey
  FiatUah(), // Ukraine
  // Wales uses GBP
  // Isle of Man uses GBP
  // ----- Badminton Pan America -----
  FiatArs(), // Argentina
  FiatAwg(), // Aruba
  FiatBbd(), // Barbados
  FiatBmd(), // Bermuda
  FiatBrl(), // Brazil
  FiatBob(), // Bolivia
  FiatCad(), // Canada
  FiatKyd(), // Cayman Islands
  FiatClp(), // Chile
  FiatCop(), // Colombia
  FiatCrc(), // Costa Rica
  FiatCup(), // Cuba
  FiatAng(), // Curaçao
  FiatDop(), // Dominican Republic
  // Ecuador uses USD
  // El Salvador uses USD
  FiatFkp(), // Falkland Islands
  // French Guiana uses EUR
  FiatXcd(), // Grenada
  // Guadeloupe uses EUR
  FiatGtq(), // Guatemala
  FiatGyd(), // Guyana
  FiatHtg(), // Haiti
  FiatHnl(), // Honduras
  FiatJmd(), // Jamaica
  // Martinique uses EUR
  FiatMxn(), // Mexico
  FiatPab(), // Panama
  FiatPyg(), // Paraguay
  FiatPen(), // Peru
  // Puerto Rico uses USD
  // Saint Lucia uses XCD
  FiatSrd(), // Suriname
  FiatTtd(), // Trinidad and Tobago
  FiatUsd(), // USA
  FiatUyu(), // Uruguay
  FiatVes(), // Venezuela
  // ----- Badminton Africa -----
  FiatDzd(), // Algeria
  FiatXof(), // Benin
  FiatBwp(), // Botswana
  // Burkina Faos uses XOF
  FiatBif(), // Burundi
  FiatXaf(), // Cameroon
  // Central African Republic uses XAF
  // Chad uses XAF
  FiatKmf(), // Comoros
  // Congo uses XAF
  FiatDjf(), // Djibouti
  FiatCdf(), // DR Congo
  FiatEgp(), // Egypt
  // Equatorial Guinea uses XAF
  FiatErn(), // Eritrea
  FiatSzl(), // Eswatini
  FiatEtb(), // Ethiopia
  FiatGmd(), // Gambia
  FiatGhs(), // Ghana
  FiatGnf(), // Guinea
  // Ivory Coast uses XOF
  FiatKes(), // Kenia
  FiatLsl(), // Lesoto
  // FiatLyd(), // Libya not supported because 1000 subunits
  // FiatMga(), // Madagascar not supported because 5 subunits
  FiatMwk(), // Malawi
  // FiatMru(), // Mauritania not supported because 5 subunits
  FiatMur(), // Mauritius
  // Mayotte uses EUR
  FiatMad(), // Marocco
  FiatMzn(), // Mozambique
  FiatNad(), // Namibia
  // Niger uses XOF
  FiatNgn(), // Nigeria
  FiatRwf(), // Ruanda
  // Réunion uses EUR
  // Saint Helena uses SHP, it is 1:1 with GPB wich is also accepted
  // Senegal uses XOF
  FiatScr(), // Seychelles
  FiatSle(), // Sierra Leona
  FiatSos(), // Somalia
  FiatZar(), // South Africa
  FiatSdg(), // Sudan
  FiatTzs(), // Tanzania
  // Togo uses XOF
  // FiatTnd(), // Tunisia not supported because 1000 subunits
  FiatUgx(), // Uganda
  FiatZmw(), // Zambia
  FiatZwl(), // Zimbabwe
  // ----- Badminton Oceania -----
  FiatAud(), // Australia
  // Cook Islands uses NZD
  FiatFjd(), // Fiji
  // Guam uses USD
  // Kiribati uses AUD
  // Nauru uses AUD
  FiatNzd(), // New Zealand
  // Norfolk Island uses AUD
  FiatPgk(), // Papua New Guinea
  FiatWst(), // Samoa
  FiatSbd(), // Solomon Islands
  FiatXpf(), // Tahiti
  FiatTop(), // Tonga
  // Tuvalu uses AUD
  // New Caledonia uses XPF
  // Northern Mariana uses USD
  // Wallis and Futuna uses XPF
];
