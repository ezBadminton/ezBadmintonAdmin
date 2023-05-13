import 'package:equatable/equatable.dart';

abstract class Model extends Equatable {
  const Model();
  Map<String, dynamic> toCollapsedJson();
  String get id;
  DateTime get created;
  DateTime get updated;

  @override
  List<Object?> get props => [id, updated];

  @override
  bool? get stringify => false;
}
