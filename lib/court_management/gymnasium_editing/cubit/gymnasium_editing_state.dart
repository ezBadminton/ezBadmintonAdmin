part of 'gymnasium_editing_cubit.dart';

class GymnasiumEditingState
    extends CollectionFetcherState<GymnasiumEditingState> with FormzMixin {
  GymnasiumEditingState({
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    Gymnasium? gymnasium,
    this.name = const NonEmptyInput.pure(),
    this.directions = const NoValidationInput.pure(),
    this.rows = const PositiveNonzeroNumber.pure(Gymnasium.defaultGridSize),
    this.columns = const PositiveNonzeroNumber.pure(Gymnasium.defaultGridSize),
    super.collections = const {},
  }) : gymnasium = gymnasium ?? Gymnasium.newGymnasium();

  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  final Gymnasium gymnasium;

  final NonEmptyInput name;
  final NoValidationInput directions;

  final PositiveNonzeroNumber rows;
  final PositiveNonzeroNumber columns;

  GymnasiumEditingState copyWithGymnasium(Gymnasium gymnasium) => copyWith(
        name: NonEmptyInput.pure(gymnasium.name),
        directions: NoValidationInput.pure(gymnasium.directions ?? ''),
        rows: PositiveNonzeroNumber.pure(gymnasium.rows),
        columns: PositiveNonzeroNumber.pure(gymnasium.columns),
      );

  GymnasiumEditingState copyWith({
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    Gymnasium? gymnasium,
    NonEmptyInput? name,
    NoValidationInput? directions,
    PositiveNonzeroNumber? rows,
    PositiveNonzeroNumber? columns,
    Map<Type, List<Model>>? collections,
  }) {
    return GymnasiumEditingState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      formStatus: formStatus ?? this.formStatus,
      gymnasium: gymnasium ?? this.gymnasium,
      name: name ?? this.name,
      directions: directions ?? this.directions,
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      collections: collections ?? this.collections,
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
