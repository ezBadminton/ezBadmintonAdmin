import 'package:model_repository/model_repository.dart';

class SingleRelation<M extends Model> {
  SingleRelation({this.relationId = ""});

  SingleRelation.fromModel(M? model) : relationId = model?.id ?? "";

  final String relationId;

  M? get model => ModelRepository.instance.models[relationId] as M?;

  factory SingleRelation.fromJson(String relationId) {
    return SingleRelation<M>(relationId: relationId);
  }

  String toJson() {
    return relationId;
  }
}

class MultiRelation<M extends Model> {
  MultiRelation({this.relationIds = const []});

  MultiRelation.fromModels(List<M> models)
      : relationIds = models.map((e) => e.id).toList();

  final List<String> relationIds;

  List<M> get models => relationIds
      .map((id) => ModelRepository.instance.models[id])
      .whereType<M>()
      .toList();

  factory MultiRelation.fromJson(List relationIds) {
    List<String> stringIds = relationIds.cast<String>();
    return MultiRelation<M>(relationIds: stringIds);
  }

  List<String> toJson() {
    return relationIds;
  }
}
