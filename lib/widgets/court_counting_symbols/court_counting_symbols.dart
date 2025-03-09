import 'package:ez_badminton_admin_app/court_management/court_numbering/models/court_numbering_type.dart';
import 'package:ez_badminton_admin_app/widgets/badminton_court/badminton_court.dart';
import 'package:flutter/material.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';

class NumberingDirectionSymbol extends StatelessWidget {
  const NumberingDirectionSymbol({
    super.key,
    required this.countingDirection,
    required this.color,
  });

  final Axis countingDirection;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
          color: color,
          width: 1.5,
        )),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: color,
            fontSize: 13,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text('1'),
                  Text(countingDirection == Axis.vertical ? '2' : '3'),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(countingDirection == Axis.vertical ? '3' : '2'),
                  const Text('4'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NumberingTypeSymbol extends StatelessWidget {
  const NumberingTypeSymbol({
    super.key,
    required this.numberingType,
    required this.color,
  });

  final CourtNumberingType numberingType;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(
        color: color,
        fontSize: 14,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            height: 38,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: color,
                  width: 1.5,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('1'),
                  Text('2'),
                ],
              ),
            ),
          ),
          if (numberingType == CourtNumberingType.global) ...[
            const SizedBox(width: 5),
            SizedBox(
              width: 38,
              height: 38,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: color,
                    width: 1.5,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('3'),
                    Text('4'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CountingTypeSymbol extends StatelessWidget {
  const CountingTypeSymbol({
    super.key,
    required this.countingType,
    required this.color,
  });

  final CourtCountingType countingType;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(
        color: color,
        fontSize: 14,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            height: 21,
            child: BadmintonCourt(
              lineColor: color,
              netColor: Colors.transparent,
              lineWidthScale: 5,
              child: const Center(
                child: Text('1'),
              ),
            ),
          ),
          const SizedBox(width: 5),
          SizedBox(
            width: 38,
            height: 21,
            child: Container(
              decoration: BoxDecoration(
                border: DashedBorder.all(
                  color: color,
                  width: 1,
                  dashLength: 4,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          SizedBox(
            width: 38,
            height: 21,
            child: BadmintonCourt(
              lineColor: color,
              netColor: Colors.transparent,
              lineWidthScale: 5,
              child: Center(
                child: Text(
                  countingType == CourtCountingType.countAll ? '3' : '2',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
