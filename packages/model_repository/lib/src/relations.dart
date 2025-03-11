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

    model = modelStore.getModel(relationId);
  }

  factory SingleRelation.fromJson(String relationId) {
    return SingleRelation<M>(relationId: relationId);
  }

  String toJson() {
    return relationId;
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

    models =
        relationIds.map((e) => modelStore.getModel(e)).whereType<M>().toList();
  }

  factory MultiRelation.fromJson(List relationIds) {
    List<String> stringIds = relationIds.cast<String>();
    return MultiRelation<M>(relationIds: stringIds);
  }

  List<String> toJson() {
    return relationIds;
  }
}
