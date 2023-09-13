import 'package:flutter/material.dart';

class IntegerStepper extends StatefulWidget {
  const IntegerStepper({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.minValue = 0,
    this.maxValue = 99,
  });

  final int initialValue;
  final Function(int value) onChanged;
  final int minValue;
  final int maxValue;

  @override
  State<IntegerStepper> createState() => _IntegerStepperState();
}

class _IntegerStepperState extends State<IntegerStepper> {
  int _value = 0;

  @override
  void initState() {
    _value = widget.initialValue;
    super.initState();
  }

  void _increment() {
    int newValue = _value + 1;
    if (newValue > widget.maxValue) {
      return;
    }

    _setValue(newValue);
  }

  void _decrement() {
    int newValue = _value - 1;
    if (newValue < widget.minValue) {
      return;
    }

    _setValue(newValue);
  }

  void _setValue(int newValue) {
    setState(() {
      _value = newValue;
      widget.onChanged(newValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    Color iconColor = Theme.of(context).colorScheme.onSurface.withOpacity(.7);
    double splashRadius = 20;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _value <= widget.minValue ? null : _decrement,
          icon: const Icon(
            Icons.remove_circle_outline,
          ),
          color: iconColor,
          splashRadius: splashRadius,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 24),
          child: Center(
            child: DefaultTextStyle.merge(
              style: const TextStyle(fontSize: 18),
              child: Text('$_value'),
            ),
          ),
        ),
        IconButton(
          onPressed: _value >= widget.maxValue ? null : _increment,
          icon: const Icon(
            Icons.add_circle_outline,
          ),
          color: iconColor,
          splashRadius: splashRadius,
        ),
      ],
    );
  }
}
