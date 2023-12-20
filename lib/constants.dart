import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:collection_repository/collection_repository.dart';
import 'package:flutter/material.dart';

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

final String fontDirPath = p.join(Directory.current.path, 'fonts');

const String matchQrPrefix = '\$match:';
const String matchQrSuffix = '\$';
