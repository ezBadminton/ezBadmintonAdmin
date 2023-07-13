import 'package:collection_repository/collection_repository.dart';
import 'package:equatable/equatable.dart';

/// A tuple of [GenderCategory] and [CompetitionType] forming a competition
/// category like ([GenderCategory.female], [CompetitionType.singles])
class CompetitionCategory extends Equatable {
  const CompetitionCategory(this.genderCategory, this.competitionType);

  CompetitionCategory.fromCompetition(Competition competition)
      : this(competition.genderCategory, competition.type);

  final GenderCategory genderCategory;
  final CompetitionType competitionType;

  @override
  List<Object?> get props => [genderCategory, competitionType];

  /// The 5 default competitions of every badminton tournament
  static const List<CompetitionCategory> defaultCompetitions = [
    CompetitionCategory(GenderCategory.female, CompetitionType.doubles),
    CompetitionCategory(GenderCategory.male, CompetitionType.doubles),
    CompetitionCategory(GenderCategory.female, CompetitionType.singles),
    CompetitionCategory(GenderCategory.male, CompetitionType.singles),
    CompetitionCategory(GenderCategory.mixed, CompetitionType.mixed),
  ];
}
