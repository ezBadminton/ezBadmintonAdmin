import 'package:ez_badminton_admin_app/player_management/starting_fees/currency_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sealed_currencies/sealed_currencies.dart';

class CurrencyInput extends StatefulWidget {
  const CurrencyInput({
    super.key,
    required this.currency,
    required this.amount,
    this.onChanged,
    this.onSubmitted,
  });

  final FiatCurrency currency;
  final int amount;
  final ValueChanged<int>? onChanged;
  final VoidCallback? onSubmitted;

  @override
  State<CurrencyInput> createState() => _CurrencyInputState();
}

class _CurrencyInputState extends State<CurrencyInput> {
  static const String zeroWidthSpace = '​';
  final controller = TextEditingController();
  final focus = FocusNode();

  @override
  void initState() {
    super.initState();
    controller.text = zeroWidthSpace;
    controller.addListener(_onChange);
    focus.requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    focus.dispose();
  }

  void _onChange() {
    final textLength = controller.text.length;
    assert(textLength <= 2);

    if (textLength == 2) {
      final String typedDigit = controller.text.substring(1);
      final int? typedDigitInt = int.tryParse(typedDigit);
      if (typedDigitInt != null) {
        _digitTyped(typedDigitInt);
      }
    } else if (textLength == 0) {
      _digitDeleted();
    }

    if (textLength != 1 || controller.selection.baseOffset != 1) {
      // The zero width space is always kept in the text field to capture
      // backspace presses (which delete the zero width space)
      controller.value = TextEditingValue(
        text: zeroWidthSpace,
        selection: TextSelection.collapsed(offset: 1),
      );
    }
  }

  void _digitTyped(int digit) {
    assert(digit >= 0 && digit <= 9);
    final newAmount = 10 * widget.amount + digit;
    if (newAmount > (1 << 58)) {
      return;
    }
    widget.onChanged?.call(newAmount);
  }

  void _digitDeleted() {
    if (widget.amount == 0) {
      return;
    }
    final newAmount = widget.amount ~/ 10;
    widget.onChanged?.call(newAmount);
  }

  @override
  Widget build(BuildContext context) {
    final String formattedAmount =
        formatCurrency(widget.amount, widget.currency);
    return TextField(
      controller: controller,
      focusNode: focus,
      keyboardType: TextInputType.numberWithOptions(),
      inputFormatters: [
        // Digits and the zero width space
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]|\u200B')),
      ],
      enabled: widget.onChanged != null,
      onSubmitted: (_) => widget.onSubmitted?.call(),
      decoration: InputDecoration(
        prefixIcon: Text(
          "${widget.currency.symbol ?? '\$'} $formattedAmount",
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}
