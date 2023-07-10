import 'package:collection_repository/collection_repository.dart';

class CompetitionCategory {
  /// A tuple of [GenderCategory] and [CompetitionType] forming a competition
  /// category like ([GenderCategory.female], [CompetitionType.singles])
  const CompetitionCategory(this.genderCategory, this.competitionType);

  final GenderCategory genderCategory;
  final CompetitionType competitionType;

  /// The 5 default competitions of every badminton tournament
  static const List<CompetitionCategory> defaultCompetitions = [
    CompetitionCategory(GenderCategory.female, CompetitionType.doubles),
    CompetitionCategory(GenderCategory.male, CompetitionType.doubles),
    CompetitionCategory(GenderCategory.female, CompetitionType.singles),
    CompetitionCategory(GenderCategory.male, CompetitionType.singles),
    CompetitionCategory(GenderCategory.mixed, CompetitionType.mixed),
  ];
}
