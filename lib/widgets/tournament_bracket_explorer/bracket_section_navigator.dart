import 'dart:math';

import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/bracket_section_navigator_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/tournament_bracket_explorer_controller.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/section_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BracketSectionNavigator extends StatelessWidget {
  BracketSectionNavigator({
    super.key,
    required this.constraints,
    required this.sectionLabels,
    required this.viewController,
  })  : _totalSectionWidth =
            sectionLabels.fold(0, (width, section) => width + section.width),
        _navigatorWidth = constraints.maxWidth {
    _widthScale = _navigatorWidth / _totalSectionWidth;
  }

  final BoxConstraints constraints;

  final List<SectionLabel> sectionLabels;

  final TournamentBracketExplorerController viewController;

  final double _totalSectionWidth;
  final double _navigatorWidth;
  late final double _widthScale;

  @override
  Widget build(BuildContext context) {
    const double height = 30;
    const double indicatorHeigt = 2;

    return Column(
      children: [
        Row(
          children: sectionLabels.map((section) {
            return Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              height: height,
              width: _widthScale * section.width,
              child: section.label != null
                  ? Container(
                      color: Theme.of(context).highlightColor.withOpacity(.2),
                      child: SizedBox.expand(
                        child: TextButton(
                          onPressed: () {
                            viewController.focusHorizontal(
                              _getTotalOffset(section),
                            );
                          },
                          child: Text(
                            section.label!,
                            style: const TextStyle(
                              fontSize: 12,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    )
                  : null,
            );
          }).toList(),
        ),
        _SectionIndicator(
          width: viewController.viewConstraints!.maxWidth,
          height: indicatorHeigt,
        ),
      ],
    );
  }

  double _getTotalOffset(SectionLabel sectionLabel) {
    double offset = sectionLabels
        .sublist(0, sectionLabels.indexOf(sectionLabel))
        .fold(0.0, (offset, element) => offset + element.width);

    return offset + sectionLabel.width * 0.5;
  }
}

class _SectionIndicator extends StatelessWidget {
  const _SectionIndicator({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BracketSectionNavigatorCubit,
        BracketSectionNavigatorState>(
      builder: (context, state) {
        final double offset = max(0, state.horizontalOffset);
        final double visibleWidth = max(
          0,
          min(
            state.visibleWidth,
            min(
              width - offset,
              state.visibleWidth + offset,
            ),
          ),
        );

        return Row(
          children: [
            SizedBox(width: offset),
            Container(
              height: height,
              width: visibleWidth,
              color: Theme.of(context).primaryColor.withOpacity(.75),
            )
          ],
        );
      },
    );
  }
}
