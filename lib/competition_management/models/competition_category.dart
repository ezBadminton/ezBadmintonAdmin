import 'package:collection_repository/collection_repository.dart';
import 'package:equatable/equatable.dart';

/// A tuple of [GenderCategory] and [CompetitionType] forming a competition
/// discipline like ([GenderCategory.female], [CompetitionType.singles])
class CompetitionDiscipline extends Equatable {
  const CompetitionDiscipline(this.genderCategory, this.competitionType);

  CompetitionDiscipline.fromCompetition(Competition competition)
      : this(competition.genderCategory, competition.type);

  final GenderCategory genderCategory;
  final CompetitionType competitionType;

  @override
  List<Object?> get props => [genderCategory, competitionType];

  /// The 5 base competitions of every badminton tournament
  static const List<CompetitionDiscipline> baseCompetitions = [
    CompetitionDiscipline(GenderCategory.female, CompetitionType.doubles),
    CompetitionDiscipline(GenderCategory.male, CompetitionType.doubles),
    CompetitionDiscipline(GenderCategory.female, CompetitionType.singles),
    CompetitionDiscipline(GenderCategory.male, CompetitionType.singles),
    CompetitionDiscipline(GenderCategory.mixed, CompetitionType.mixed),
  ];

  static CompetitionDiscipline womensDoubles = baseCompetitions[0];
  static CompetitionDiscipline mensDoubles = baseCompetitions[1];
  static CompetitionDiscipline womensSingles = baseCompetitions[2];
  static CompetitionDiscipline mensSingles = baseCompetitions[3];
  static CompetitionDiscipline mixed = baseCompetitions[4];
}
