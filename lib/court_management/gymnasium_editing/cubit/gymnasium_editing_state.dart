part of 'gymnasium_editing_cubit.dart';

class GymnasiumEditingState with FormzMixin implements DialogState {
  GymnasiumEditingState({
    this.formStatus = FormzSubmissionStatus.initial,
    Gymnasium? gymnasium,
    this.name = const NonEmptyInput.pure(),
    this.directions = const NoValidationInput.pure(),
    this.rows = const PositiveNonzeroNumber.pure(Gymnasium.defaultGridSize),
    this.columns = const PositiveNonzeroNumber.pure(Gymnasium.defaultGridSize),
    this.dialog = const CubitDialog(),
  }) : gymnasium = gymnasium ?? Gymnasium.newGymnasium();

  final FormzSubmissionStatus formStatus;

  final Gymnasium gymnasium;

  final NonEmptyInput name;
  final NoValidationInput directions;

  final PositiveNonzeroNumber rows;
  final PositiveNonzeroNumber columns;

  @override
  final CubitDialog dialog;

  GymnasiumEditingState copyWithGymnasium(Gymnasium gymnasium) => copyWith(
        name: NonEmptyInput.pure(gymnasium.name),
        directions: NoValidationInput.pure(gymnasium.directions ?? ''),
        rows: PositiveNonzeroNumber.pure(gymnasium.rows),
        columns: PositiveNonzeroNumber.pure(gymnasium.columns),
      );

  GymnasiumEditingState copyWith({
    FormzSubmissionStatus? formStatus,
    Gymnasium? gymnasium,
    NonEmptyInput? name,
    NoValidationInput? directions,
    PositiveNonzeroNumber? rows,
    PositiveNonzeroNumber? columns,
    CubitDialog? dialog,
  }) {
    return GymnasiumEditingState(
      formStatus: formStatus ?? this.formStatus,
      gymnasium: gymnasium ?? this.gymnasium,
      name: name ?? this.name,
      directions: directions ?? this.directions,
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      dialog: dialog ?? this.dialog,
    );
  }

  @override
  List<FormzInput> get inputs => [
        name,
        directions,
        rows,
        columns,
      ];
}
