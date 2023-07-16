import 'package:collection_repository/collection_repository.dart';
import 'package:equatable/equatable.dart';

/// A tuple of [ageGroup] and [playingLevel] forming a playing category.
///
/// [ageGroup] and [playingLevel] can be null when the current [Tournament]
/// does not use these categorizations.
class PlayingCategory extends Equatable {
  const PlayingCategory({
    required this.ageGroup,
    required this.playingLevel,
  });

  PlayingCategory.fromCompetition(
    Competition competition, {
    bool ignoreAgeGroup = false,
    bool ignorePlayingLevel = false,
  }) : this(
          ageGroup: ignoreAgeGroup ? null : competition.ageGroup,
          playingLevel: ignorePlayingLevel ? null : competition.playingLevel,
        );

  final AgeGroup? ageGroup;
  final PlayingLevel? playingLevel;

  @override
  List<Object?> get props => [ageGroup, playingLevel];
}
