import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/utils/playing_levels.dart';
import 'package:flutter_test/flutter_test.dart';

var playingLevels = [0, 1, 2]
    .map(
      (level) => PlayingLevel(
        id: 'level$level',
        created: DateTime.now(),
        updated: DateTime.now(),
        name: 'Level $level',
        index: level,
      ),
    )
    .toList();

void main() {
  test('compareTo() extension method correctly compares PlayingLevels', () {
    expect(playingLevels[0].compareTo(playingLevels[0]), 0);
    expect(playingLevels[0].compareTo(playingLevels[1]), -1);
    expect(playingLevels[2].compareTo(playingLevels[1]), 1);
  });

  test(
    """compareToList() extension method correctly compares to a List of
    PlayingLevels""",
    () {
      expect(
        playingLevels[1].compareToList([
          playingLevels[1],
          playingLevels[2],
        ]),
        0,
      );
      expect(
        playingLevels[1].compareToList([
          playingLevels[0],
          playingLevels[2],
        ]),
        0,
      );
      expect(
        playingLevels[0].compareToList([
          playingLevels[1],
          playingLevels[2],
        ]),
        -1,
      );
      expect(
        playingLevels[2].compareToList([
          playingLevels[0],
          playingLevels[1],
        ]),
        1,
      );
    },
  );
}
