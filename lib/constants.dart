import 'package:collection_repository/collection_repository.dart';
import 'package:flutter/material.dart';

// Max characters in the player search text field
const int playerSearchMaxLength = 50;

const int playingLevelNameMaxLength = 30;

const int courtNameMaxLength = 14;

const Map<PlayerStatus, IconData> playerStatusIcons = {
  PlayerStatus.notAttending: Icons.question_mark,
  PlayerStatus.attending: Icons.done,
  PlayerStatus.forfeited: Icons.flag_outlined,
  PlayerStatus.injured: Icons.local_hospital_outlined,
  PlayerStatus.disqualified: Icons.person_off,
};

const IconData partnerMissingIcon = Icons.group;
