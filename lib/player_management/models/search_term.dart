import 'package:ez_badminton_admin_app/constants.dart';
import 'package:formz/formz.dart';

enum SearchTermValidationError { empty, tooLong }

class SearchTerm extends FormzInput<String, SearchTermValidationError> {
  const SearchTerm.pure([super.value = '']) : super.pure();
  const SearchTerm.dirty([super.value = '']) : super.dirty();

  @override
  SearchTermValidationError? validator(String value) {
    if (value.isEmpty) {
      return SearchTermValidationError.empty;
    }
    if (value.length > playerSearchMaxLength) {
      return SearchTermValidationError.tooLong;
    }
    return null;
  }
}
