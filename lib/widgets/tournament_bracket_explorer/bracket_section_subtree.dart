// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/bracket_explorer_cubit.dart';

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
/// [BracketSectionSubtree] with the [TournamentMatch] object as its
/// data object.
class BracketSectionSubtree extends StatelessWidget {
  /// Creates a [BracketSectionSubtree] building its [child] and attaching a
  /// [GlobalObjectKey] that has the [tournamentDataObject] as its value.
  const BracketSectionSubtree({
    required this.tournamentDataObject,
    required this.child,
    super.key,
  });

  final Object tournamentDataObject;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: getBracketSectionKey(context, tournamentDataObject),
      child: child,
    );
  }
}

GlobalKey getBracketSectionKey(
  BuildContext context,
  Object tournamentDataObject,
) {
  final bracketCubit = context.read<BracketExplorerCubit>();
  return bracketCubit.getBracketSectionKey(tournamentDataObject);
}
