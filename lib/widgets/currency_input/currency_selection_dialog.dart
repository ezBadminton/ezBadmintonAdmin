import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/constants.dart';
import 'package:ez_badminton_admin_app/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:sealed_currencies/sealed_currencies.dart';

class CurrencySelectionDialog extends StatefulWidget {
  const CurrencySelectionDialog({
    super.key,
    this.currencies = bwfCurrencies,
    this.onSelected,
  });

  final List<FiatCurrency> currencies;
  final ValueChanged<FiatCurrency>? onSelected;

  @override
  State<CurrencySelectionDialog> createState() =>
      _CurrencySelectionDialogState();
}

class _CurrencySelectionDialogState extends State<CurrencySelectionDialog> {
  late List<FiatCurrency> _currencies;
  late List<FiatCurrency> _displayCurrencies;
  late Map<FiatCurrency, String> _searchStrings;

  @override
  void initState() {
    _currencies = widget.currencies.sortedBy((currency) => currency.name);
    _displayCurrencies = _currencies;

    _searchStrings = {};
    for (final currency in _currencies) {
      assert(
        currency.subunitToUnit == 100 || currency.subunitToUnit == 1,
        'Not 100 or 1 subunits ${currency.code}',
      );

      final buf = StringBuffer();
      buf.write(currency.name);
      buf.write(' ');
      buf.write(currency.code);
      buf.write(' ');
      buf.write(currency.symbol);
      buf.write(' ');
      if (currency.disambiguateSymbol != null) {
        buf.write(currency.disambiguateSymbol);
        buf.write(' ');
      }
      for (final nativeName in currency.namesNative) {
        buf.write(nativeName);
        buf.write(' ');
      }
      final searchString = buf.toString().toLowerCase();
      _searchStrings[currency] = searchString;
    }

    super.initState();
  }

  void filterCurrencies(String searchTerm) {
    if (searchTerm.isEmpty) {
      setState(() {
        _displayCurrencies = _currencies;
      });
      return;
    }
    searchTerm = searchTerm.toLowerCase();
    final filtered = _currencies.where((currency) {
      return _searchStrings[currency]!.contains(searchTerm);
    }).toList();
    setState(() {
      _displayCurrencies = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 700, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.only(top: 28.0, left: 28.0, right: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.editStartingFeeCurrency,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: filterCurrencies,
                onSubmitted: (_) {
                  if (_displayCurrencies.length == 1) {
                    widget.onSelected?.call(_displayCurrencies.first);
                  }
                },
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchCurrency,
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    for (final currency in _displayCurrencies)
                      _CurrencyEntry(
                        currency: currency,
                        onSelected: widget.onSelected,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencyEntry extends StatelessWidget {
  const _CurrencyEntry({
    required this.currency,
    required this.onSelected,
  });

  final FiatCurrency currency;
  final ValueChanged<FiatCurrency>? onSelected;

  @override
  Widget build(BuildContext context) {
    String symbol = currency.disambiguateSymbol ??
        currency.symbol ??
        currency.alternateSymbols?.firstOrNull ??
        '\$';
    String name = currency.name;
    String? nativeName = currency.namesNative.firstOrNull;
    String code = currency.code;

    StringBuffer buf = StringBuffer('(');
    if (nativeName != null && name.toLowerCase() != nativeName.toLowerCase()) {
      buf.write(nativeName);
      buf.write(', ');
    }
    buf.write(code);
    buf.write(')');

    String details = buf.toString();

    return InkWell(
      onTap: onSelected == null ? null : () => onSelected!(currency),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 80,
              child: Text(
                symbol,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(
              width: 220,
              child: Text(name),
            ),
            SizedBox(
              width: 220,
              child: Text(details),
            ),
          ],
        ),
      ),
    );
  }
}
