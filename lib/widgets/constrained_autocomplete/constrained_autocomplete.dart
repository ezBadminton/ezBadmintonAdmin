import 'package:flutter/material.dart';

class ConstrainedAutocomplete<T extends Object> extends RawAutocomplete<T> {
  const ConstrainedAutocomplete._({
    super.key,
    required super.optionsBuilder,
    required super.optionsViewBuilder,
    super.displayStringForOption,
    super.fieldViewBuilder,
    super.onSelected,
    super.initialValue,
    super.focusNode,
    super.textEditingController,
  });

  factory ConstrainedAutocomplete({
    required AutocompleteOptionsBuilder<T> optionsBuilder,
    required BoxConstraints constraints,
    AutocompleteOptionToString<T> displayStringForOption =
        RawAutocomplete.defaultStringForOption,
    required AutocompleteFieldViewBuilder fieldViewBuilder,
    AutocompleteOnSelected<T>? onSelected,
    double optionsMaxHeight = 200.0,
    TextEditingValue? initialValue,
    FocusNode? focusNode,
    TextEditingController? textEditingController,
  }) {
    assert((focusNode == null) == (textEditingController == null));
    return ConstrainedAutocomplete._(
      optionsBuilder: optionsBuilder,
      optionsViewBuilder: (context, onSelected, options) =>
          _constrainedAutocompleteOptionsViewBuilder<T>(
        context,
        onSelected,
        options,
        constraints,
        displayStringForOption,
        optionsMaxHeight,
      ),
      displayStringForOption: displayStringForOption,
      fieldViewBuilder: fieldViewBuilder,
      onSelected: onSelected,
      initialValue: initialValue,
      focusNode: focusNode,
      textEditingController: textEditingController,
    );
  }

  static Widget _constrainedAutocompleteOptionsViewBuilder<T extends Object>(
    BuildContext context,
    void Function(T option) onSelected,
    Iterable<T> options,
    BoxConstraints constraints,
    AutocompleteOptionToString<T> displayStringForOption,
    double optionsMaxHeight,
  ) {
    double optionsHeight = 52.0 * options.length;
    optionsHeight =
        optionsHeight > optionsMaxHeight ? optionsMaxHeight : optionsHeight;
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(4.0),
          ),
        ),
        child: SizedBox(
          height: optionsHeight,
          width: constraints.biggest.width,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: options.length,
            shrinkWrap: false,
            itemBuilder: (BuildContext context, int index) {
              final T option = options.elementAt(index);
              return InkWell(
                onTap: () => onSelected(option),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(displayStringForOption(option)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
