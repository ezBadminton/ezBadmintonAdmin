import 'package:equatable/equatable.dart';

abstract class Model extends Equatable {
  /// Base for all data classes (models)
  ///
  /// All model classes use the freezed package to generate boilerplate code
  /// for json (de-)serialization and `copyWith` methods.
  const Model();

  /// Serializes the model into a json map.
  ///
  /// If the model has relations they are not added as fully serialized models
  /// but collapsed to Strings holding the relation's ID.
  Map<String, dynamic> toCollapsedJson();

  String get id;
  DateTime get created;
  DateTime get updated;

  @override
  List<Object?> get props => [id];

  @override
  bool? get stringify => false;
}
