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

  bool isInCategory(Model category) {
    switch (category) {
      case AgeGroup _:
        return category == ageGroup;
      case PlayingLevel _:
        return category == playingLevel;
      default:
        return false;
    }
  }

  C? getCategory<C extends Model>() {
    switch (C) {
      case AgeGroup:
        return ageGroup as C?;
      case PlayingLevel:
        return playingLevel as C?;
      default:
        return null;
    }
  }

  @override
  List<Object?> get props => [ageGroup, playingLevel];
}
