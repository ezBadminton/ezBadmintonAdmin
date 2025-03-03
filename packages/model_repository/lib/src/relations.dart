import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:model_repository/model_repository.dart';

abstract class Relation {
  /// Takes the string IDs of the relation,
  /// looks them up in the model repository
  /// and pupulates its mutable model field
  /// with them.
  expandRelation();
}

class SingleRelation<M extends Model> implements Relation {
  SingleRelation({this.relationId = ""});

  SingleRelation.fromModel(this.model) : relationId = model?.id ?? "";

  final String relationId;

  M? model;

  @override
  expandRelation() {
    if (relationId == "") {
      return;
    }

    var modelRepo = ModelRepository.instance;
    var modelStore = modelRepo.findStore<M>()!;

    model = modelStore.getModel(relationId) as M;
  }
}

class MultiRelation<M extends Model> implements Relation {
  MultiRelation({this.relationIds = const []});

  MultiRelation.fromModels(this.models)
      : relationIds = models.map((e) => e.id).toList();

  final List<String> relationIds;

  List<M> models = const [];

  @override
  expandRelation() {
    if (relationIds.isEmpty) {
      return;
    }

    var modelRepo = ModelRepository.instance;
    var modelStore = modelRepo.findStore<M>()!;

    models = relationIds.map((e) => modelStore.getModel(e)!).toList();
  }
}

class _SingleRelationConverter<M extends Model>
    implements JsonConverter<SingleRelation<M>, String> {
  const _SingleRelationConverter();

  @override
  SingleRelation<M> fromJson(String relationId) {
    return SingleRelation(relationId: relationId);
  }

  @override
  String toJson(SingleRelation<M> relationPointer) {
    return relationPointer.relationId;
  }
}

class _MultiRelationConverter<M extends Model>
    implements JsonConverter<MultiRelation<M>, List> {
  const _MultiRelationConverter();

  @override
  MultiRelation<M> fromJson(List relationIds) {
    List<String> stringIds = relationIds.cast<String>();
    return MultiRelation(relationIds: stringIds);
  }

  @override
  List<String> toJson(MultiRelation<M> relationPointer) {
    return relationPointer.relationIds;
  }
}

// Sadly cannot use the generic converter directly because json_annotation
// does not support generic converters. So we manually type every converter:

class MultiRelationTeamConverter extends _MultiRelationConverter<Team> {
  const MultiRelationTeamConverter();
}

class MultiRelationPlayerConverter extends _MultiRelationConverter<Player> {
  const MultiRelationPlayerConverter();
}

class MultiRelationMatchDataConverter
    extends _MultiRelationConverter<MatchData> {
  const MultiRelationMatchDataConverter();
}

class MultiRelationMatchSetConverter extends _MultiRelationConverter<MatchSet> {
  const MultiRelationMatchSetConverter();
}

class MultiRelationTieBreakerConverter
    extends _MultiRelationConverter<TieBreaker> {
  const MultiRelationTieBreakerConverter();
}

class SingleRelationAgeGroupConverter
    extends _SingleRelationConverter<AgeGroup> {
  const SingleRelationAgeGroupConverter();
}

class SingleRelationPlayingLevelConverter
    extends _SingleRelationConverter<PlayingLevel> {
  const SingleRelationPlayingLevelConverter();
}

class SingleRelationClubConverter extends _SingleRelationConverter<Club> {
  const SingleRelationClubConverter();
}

class SingleRelationCourtConverter extends _SingleRelationConverter<Court> {
  const SingleRelationCourtConverter();
}

class SingleRelationTournamentModeSettingsConverter
    extends _SingleRelationConverter<TournamentModeSettings> {
  const SingleRelationTournamentModeSettingsConverter();
}

class SingleRelationGymnasiumConverter
    extends _SingleRelationConverter<Gymnasium> {
  const SingleRelationGymnasiumConverter();
}

class SingleRelationCompetitionConverter
    extends _SingleRelationConverter<Competition> {
  const SingleRelationCompetitionConverter();
}

class SingleRelationTeamConverter extends _SingleRelationConverter<Team> {
  const SingleRelationTeamConverter();
}
