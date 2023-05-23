part of 'player_editing_cubit.dart';

@immutable
class PlayerEditingState with FormzMixin {
  const PlayerEditingState({
    required this.formStatus,
    required this.player,
    required this.firstName,
    required this.lastName,
    required this.clubName,
    required this.eMail,
    required this.dateOfBirth,
    required this.playingLevel,
    required this.playingLevels,
    required this.clubs,
    required this.competitionType,
    required this.genderCategory,
  });

  PlayerEditingState.fromPlayer({
    required context,
    required this.player,
    this.formStatus = FormzSubmissionStatus.initial,
    this.playingLevels = const [],
    this.clubs = const [],
    this.competitionType = const SelectionInput.dirty(emptyAllowed: true),
    this.genderCategory =
        const SelectionInput.dirty(value: GenderCategory.male),
  })  : firstName = NonEmptyInput.pure(player.firstName),
        lastName = NonEmptyInput.pure(player.lastName),
        clubName = NoValidationInput.pure(player.club?.name ?? ''),
        eMail = EMailInput.pure(emptyAllowed: true, value: player.eMail ?? ''),
        dateOfBirth = player.dateOfBirth != null
            ? DateInput.pure(
                context: context,
                emptyAllowed: true,
                value: MaterialLocalizations.of(context)
                    .formatCompactDate(player.dateOfBirth!),
              )
            : DateInput.pure(context: context, emptyAllowed: true),
        playingLevel = SelectionInput.pure(
          emptyAllowed: true,
          value: player.playingLevel,
        );

  final FormzSubmissionStatus formStatus;
  final Player player;
  final NonEmptyInput firstName;
  final NonEmptyInput lastName;
  final NoValidationInput clubName;
  final EMailInput eMail;
  final DateInput dateOfBirth;
  final SelectionInput<PlayingLevel> playingLevel;

  final SelectionInput<CompetitionType> competitionType;
  final SelectionInput<GenderCategory> genderCategory;

  final List<PlayingLevel> playingLevels;
  final List<Club> clubs;

  @override
  List<FormzInput> get inputs => [
        firstName,
        lastName,
        clubName,
        eMail,
        dateOfBirth,
        playingLevel,
      ];

  PlayerEditingState copyWith({
    Player? player,
    FormzSubmissionStatus? formStatus,
    NonEmptyInput? firstName,
    NonEmptyInput? lastName,
    NoValidationInput? clubName,
    EMailInput? eMail,
    DateInput? dateOfBirth,
    SelectionInput<PlayingLevel>? playingLevel,
    List<PlayingLevel>? playingLevels,
    List<Club>? clubs,
    SelectionInput<CompetitionType>? competitionType,
    SelectionInput<GenderCategory>? genderCategory,
  }) =>
      PlayerEditingState(
        player: player ?? this.player,
        formStatus: formStatus ?? this.formStatus,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        clubName: clubName ?? this.clubName,
        eMail: eMail ?? this.eMail,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        playingLevel: playingLevel ?? this.playingLevel,
        playingLevels: playingLevels ?? this.playingLevels,
        clubs: clubs ?? this.clubs,
        competitionType: competitionType ?? this.competitionType,
        genderCategory: genderCategory ?? this.genderCategory,
      );
}
