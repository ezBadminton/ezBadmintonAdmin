// Max characters in the player search text field
import 'package:collection_repository/collection_repository.dart';

const int playerSearchMaxLength = 50;

const Map<String, Competition> competitionTypes = {
  'doubles': Competition.doubles,
  'mixed': Competition.mixed,
  'singles': Competition.singles,
  'other': Competition.other,
};
