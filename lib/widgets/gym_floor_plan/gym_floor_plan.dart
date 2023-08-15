import 'package:flutter/material.dart';

/// A depiction if a badminton gym's floor plan
class GymFloorPlan extends StatelessWidget {
  /// The plan contains a grid of courts with the given amount of [rows] and
  /// [columns]
  const GymFloorPlan({
    super.key,
    required this.rows,
    required this.columns,
    this.wallWidth = 5,
    this.wallColor = Colors.black54,
    this.courtColor = const Color.fromARGB(255, 105, 209, 108),
  });

  final int rows;
  final int columns;
  final double wallWidth;
  final Color wallColor;
  final Color courtColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: wallColor,
          width: wallWidth,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              rows,
              (row) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  columns,
                  (column) => SizedBox(
                    width: constraints.maxWidth / columns * 0.7,
                    height: constraints.maxHeight / rows * 0.7,
                    child: _MiniBadmintonCourt(color: courtColor),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MiniBadmintonCourt extends StatelessWidget {
  const _MiniBadmintonCourt({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: 134 / 61,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: Colors.black45,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
