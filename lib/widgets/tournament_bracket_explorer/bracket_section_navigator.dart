import 'dart:math';

import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/bracket_section_navigator_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/tournament_bracket_explorer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vector_math/vector_math_64.dart';

class BracketSectionNavigator extends StatefulWidget {
  BracketSectionNavigator({
    super.key,
    required this.constraints,
    required this.sections,
    required this.viewController,
  }) : _navigatorWidth = constraints.maxWidth;

  final BoxConstraints constraints;

  final List<BracketSection> sections;

  final TournamentBracketExplorerController viewController;

  final double _navigatorWidth;

  @override
  State<BracketSectionNavigator> createState() =>
      _BracketSectionNavigatorState();
}

class _BracketSectionNavigatorState extends State<BracketSectionNavigator> {
  Map<BracketSection, Rect>? _sectionRects;

  @override
  void initState() {
    super.initState();

    // Delay the section rect getter by one frame so the widgets of the sections
    // are layed out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _sectionRects = _getSectionRects();
      });
    });
  }

  @override
  void didUpdateWidget(BracketSectionNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // When the section keys change, do not redetermine the section rects
    // because they never change. Just map the new keys to the existing rects.
    if (oldWidget.sections == widget.sections) {
      return;
    }

    assert(oldWidget.sections.length == widget.sections.length);

    List<Rect> rects = _sectionRects!.values.toList();
    Map<BracketSection, Rect> newSectionRects = Map.fromEntries(widget.sections
        .mapIndexed((index, key) => MapEntry(key, rects[index])));

    setState(() {
      _sectionRects = newSectionRects;
    });
  }

  @override
  Widget build(BuildContext context) {
    const double height = 30;
    const double indicatorHeigt = 2;

    if (_sectionRects == null) {
      return const SizedBox();
    }

    double totalSectionWidth = _getTotalSectionWidth();
    double widthScale = widget._navigatorWidth / totalSectionWidth;

    return Column(
      children: [
        Row(
          children: _sectionRects!.entries
              .map((entry) {
                BracketSection section = entry.key;
                double sectionWidth = entry.value.width;

                double? distanceToNextSection =
                    _getDistanceToNextSection(section);

                return [
                  Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    height: height,
                    width: widthScale * sectionWidth,
                    child: Container(
                      color: Theme.of(context).highlightColor.withOpacity(.2),
                      child: SizedBox.expand(
                        child: TextButton(
                          onPressed: () {
                            widget.viewController.focusGlobalKey(
                              GlobalObjectKey(section.tournamentDataObject),
                            );
                          },
                          child: Text(
                            section.labelBuilder(context),
                            style: const TextStyle(
                              fontSize: 12,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (distanceToNextSection != null)
                    Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      height: height,
                      width: widthScale * distanceToNextSection,
                    ),
                ];
              })
              .expand((list) => list)
              .toList(),
        ),
        _SectionIndicator(
          width: widget.viewController.viewConstraints!.maxWidth,
          height: indicatorHeigt,
        ),
      ],
    );
  }

  Map<BracketSection, Rect> _getSectionRects() {
    RenderObject? viewRenderObject =
        widget.viewController.bracketViewKey.currentContext?.findRenderObject();

    if (viewRenderObject == null) {
      return {};
    }

    Map<BracketSection, Rect> sectionRects = Map.fromEntries(
      widget.sections
          .map(
            (section) {
              GlobalKey key = GlobalObjectKey(section.tournamentDataObject);

              RenderBox? renderBox =
                  key.currentContext?.findRenderObject() as RenderBox?;

              bool hasSize = renderBox?.hasSize ?? false;

              Rect? sectionRect = hasSize ? renderBox!.semanticBounds : null;

              if (sectionRect == null) {
                return null;
              }

              Vector3 translation =
                  renderBox!.getTransformTo(viewRenderObject).getTranslation();

              sectionRect = sectionRect.translate(translation.x, translation.y);

              return MapEntry<BracketSection, Rect>(section, sectionRect);
            },
          )
          .whereType<MapEntry<BracketSection, Rect>>()
          .sortedBy<num>((entry) => entry.value.left),
    );

    return sectionRects;
  }

  double _getTotalSectionWidth() {
    Iterable<Rect> sectionRects = _sectionRects!.values;

    if (sectionRects.isEmpty) {
      return widget._navigatorWidth;
    }

    double leftMost = sectionRects.first.left;
    double rightMost = sectionRects.last.right;

    return rightMost - leftMost;
  }

  double? _getDistanceToNextSection(BracketSection section) {
    List<Rect> sectionRects = _sectionRects!.values.toList();

    int sectionIndex = _sectionRects!.keys.toList().indexOf(section);

    if (sectionIndex == _sectionRects!.length - 1) {
      return null;
    }

    double distance =
        sectionRects[sectionIndex + 1].left - sectionRects[sectionIndex].right;

    return distance;
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
