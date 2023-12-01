import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:flutter/material.dart';

/// A part of a tournamet bracket.
///
/// All information bearing widgets in a tournament bracket have to be wrapped
/// by this widget.
///
/// They can be nested. A section ranges from an entire elimination tree down
/// to a single match.
///
/// The widget only adds a [GlobalObjectKey] by which the the tournament data
/// objects are linked to their widgets in the bracket. This is similar to
/// [KeyedSubtree].
///
/// This is done to be able to find the position of the sections on screen when
/// the bracket is viewed in an [InteractiveViewer].
///
/// For example the widget that displays a tournament match is wrapped by a
/// [BracketSectionSubtree] with the [BadmintonMatch] object as its
/// data object.
class BracketSectionSubtree extends StatelessWidget {
  /// Creates a [BracketSectionSubtree] building its [child] and attaching a
  /// [GlobalObjectKey] that has the [tournamentDataObject] as its value.
  BracketSectionSubtree({
    required Object tournamentDataObject,
    required this.child,
  }) : super(key: GlobalObjectKey(tournamentDataObject));

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
