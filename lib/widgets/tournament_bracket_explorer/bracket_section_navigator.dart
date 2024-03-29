import 'dart:math';

import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/bracket_section_navigator_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/tournament_bracket_explorer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const double _height = 30;
const double _indicatorHeigt = 2;

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

  void _updateSectionRects() {
    // Delay the section rect getter by one frame so the widgets of the sections
    // are layed out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _sectionRects = _getSectionRects();
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _updateSectionRects();
  }

  @override
  void didUpdateWidget(BracketSectionNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.sections == widget.sections) {
      return;
    }

    if (oldWidget.sections.length != widget.sections.length) {
      _updateSectionRects();
      return;
    }

    List<Rect> rects = _sectionRects!.values.toList();
    Map<BracketSection, Rect> newSectionRects = Map.fromEntries(widget.sections
        .mapIndexed((index, key) => MapEntry(key, rects[index])));

    setState(() {
      _sectionRects = newSectionRects;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sectionRects == null) {
      return const SizedBox(height: _height + _indicatorHeigt);
    }

    double totalWidth = widget.viewController.sceneSize.width;
    double widthScale = widget._navigatorWidth / totalWidth;

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
                  _SectionButton(
                      width: widthScale * sectionWidth,
                      controller: widget.viewController,
                      section: section),
                  if (distanceToNextSection != null)
                    Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      height: _height,
                      width: widthScale * distanceToNextSection,
                    ),
                ];
              })
              .expand((list) => list)
              .toList(),
        ),
        _SectionIndicator(
          width: widget.viewController.viewConstraints!.maxWidth,
          height: _indicatorHeigt,
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
              List<GlobalKey> keys = section.tournamentDataObjects
                  .map(
                    (tournamentDataObject) =>
                        GlobalObjectKey(tournamentDataObject),
                  )
                  .toList();

              Rect? sectionRect =
                  BracketSection.getEnclosingRect(keys, viewRenderObject);

              if (sectionRect == null) {
                return null;
              }

              return MapEntry<BracketSection, Rect>(section, sectionRect);
            },
          )
          .whereType<MapEntry<BracketSection, Rect>>()
          .sortedBy<num>((entry) => entry.value.left),
    );

    return sectionRects;
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

class _SectionButton extends StatelessWidget {
  const _SectionButton({
    required this.width,
    required this.controller,
    required this.section,
  });

  final double width;
  final TournamentBracketExplorerController controller;
  final BracketSection section;

  @override
  Widget build(BuildContext context) {
    List<GlobalKey> keys = section.tournamentDataObjects
        .map(
          (tournamentDataObject) => GlobalObjectKey(tournamentDataObject),
        )
        .toList();

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      height: _height,
      width: width,
      child: Container(
        color: Theme.of(context).highlightColor.withOpacity(.2),
        child: SizedBox.expand(
          child: TextButton(
            onPressed: () {
              controller.focusGlobalKeys(keys);
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
    );
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
