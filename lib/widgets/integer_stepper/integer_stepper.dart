import 'package:flutter/material.dart';

class IntegerStepper extends StatefulWidget {
  const IntegerStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.minValue = 0,
    this.maxValue = 99,
  });

  final int value;
  final ValueChanged<int>? onChanged;
  final int minValue;
  final int maxValue;

  @override
  State<IntegerStepper> createState() => _IntegerStepperState();
}

class _IntegerStepperState extends State<IntegerStepper> {
  void _increment() {
    int newValue = widget.value + 1;
    if (newValue > widget.maxValue) {
      return;
    }

    _setValue(newValue);
  }

  void _decrement() {
    int newValue = widget.value - 1;
    if (newValue < widget.minValue) {
      return;
    }

    _setValue(newValue);
  }

  void _setValue(int newValue) {
    setState(() {
      widget.onChanged?.call(newValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    Color iconColor = Theme.of(context).colorScheme.onSurface.withOpacity(.7);
    double splashRadius = 20;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: widget.value <= widget.minValue ? null : _decrement,
          icon: const Icon(
            Icons.remove_circle_outline,
          ),
          color: iconColor,
          splashRadius: splashRadius,
        ),
        const SizedBox(width: 6),
        DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 18),
          child: Text('${widget.value}'),
        ),
        const SizedBox(width: 6),
        IconButton(
          onPressed: widget.value >= widget.maxValue ? null : _increment,
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
