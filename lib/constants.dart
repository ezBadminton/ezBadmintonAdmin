import 'package:model_repository/model_repository.dart';
import 'package:flutter/material.dart';
import 'package:authentication_repository/authentication_repository.dart';

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
