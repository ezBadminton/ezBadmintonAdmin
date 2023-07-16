import 'package:collection_repository/collection_repository.dart';

// Updates the cached competitions when their PlayingLevel is updated
List<Competition> onCompetitionRelationUpdate(
  List<Competition> competitions,
  CollectionUpdateEvent updateEvent,
) {
  if (updateEvent.model is PlayingLevel &&
      updateEvent.updateType == UpdateType.update) {
    PlayingLevel updatedPlayingLevel = updateEvent.model as PlayingLevel;

    return competitions
        .where((c) => c.playingLevel == updatedPlayingLevel)
        .map((c) => c.copyWith(playingLevel: updatedPlayingLevel))
        .toList();
  }

  return [];
}
