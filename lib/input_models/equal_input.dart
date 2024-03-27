import 'package:formz/formz.dart';

enum EqualInputError { notEqual }

/// The [EqualInput] is only valid when its value is equal to the given
/// reference value.
class EqualInput extends FormzInput<String, EqualInputError> {
  const EqualInput.pure(this.reference, [String value = ''])
      : super.pure(value);
  const EqualInput.dirty(this.reference, [String value = ''])
      : super.dirty(value);

  final String reference;

  @override
  EqualInputError? validator(String value) {
    if (reference != value) {
      return EqualInputError.notEqual;
    }

    return null;
  }
}
