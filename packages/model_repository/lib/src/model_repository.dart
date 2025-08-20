// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:model_repository/model_repository.dart';

abstract class ModelRepository {
  static late final ModelRepository instance;

  ModelRepository() {
    instance = this;
  }

  bool get isLoaded;
  Stream<RepositoryEvent> get loadStream;

  loadModels();

  ModelStore<M>? findStore<M extends Model>();

  created(Model model);
  updated(Model model);
  deleted(Model model);

  /// All currently loaded models mapped by their id
  Map<String, Model> models = {};
}

enum RepositoryEvent {
  loaded,
  reset,
}
