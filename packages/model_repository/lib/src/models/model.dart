import 'package:equatable/equatable.dart';

abstract class Model extends Equatable {
  /// Base for all data classes (models)
  ///
  /// All model classes use the freezed package to generate boilerplate code
  /// for json (de-)serialization and `copyWith` methods.
  const Model();

  String get id;

  Map<String, dynamic> toJson();

  @override
  List<Object?> get props => [id];

  @override
  bool? get stringify => false;
}
