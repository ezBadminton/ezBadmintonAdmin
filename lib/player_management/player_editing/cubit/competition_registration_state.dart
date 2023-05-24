import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/input_models/no_validation.dart';
import 'package:ez_badminton_admin_app/input_models/selection.dart';

class CompetitionRegistrationState {
  CompetitionRegistrationState({
    required this.competitionType,
    required this.genderCategory,
    required this.partnerName,
    required this.ageGroup,
  });
  final SelectionInput<Competition> competitionType;
  final SelectionInput<GenderCategory> genderCategory;
  final NoValidationInput partnerName;
  final SelectionInput<AgeGroup> ageGroup;
}
