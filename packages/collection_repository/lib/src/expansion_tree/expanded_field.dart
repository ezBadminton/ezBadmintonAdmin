class ExpandedField {
  /// Models an expanded field of a model
  ///
  /// They [key] is the json key under which the field is found. [isRequired]
  /// and [isSingle] specify if the field can be null and wether the expansion
  /// links to a list or a single instance.
  const ExpandedField({
    required this.model,
    required this.key,
    required this.isRequired,
    required this.isSingle,
  });
  final Type model;
  final String key;
  final bool isRequired;
  final bool isSingle;
  bool get isMulti => !isSingle;
}
