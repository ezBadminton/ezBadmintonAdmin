import 'dart:math';

import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/court_management/court_editing/view/court_slot.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

const double courtWidth = 134 * 3;
const double courtHeight = 61 * 3;

const double baseHorizontalPadding = 22;
const double baseVerticalPadding = 15;

const double baseWidth = courtWidth + baseHorizontalPadding * 2;
const double baseHeight = courtHeight + baseVerticalPadding * 2;

const double maxHorizontalPadding = courtWidth * 0.5;
const double maxVertialPadding = courtHeight * 0.75;

/// Calculates the padding of the [CourtSlot] widgets inside the
/// gymnasium court view.
///
/// It pads the courts such that the court grid has the same aspect ratio as the
/// constraints of the view. That makes them fit nicely.
/// If the view is large enough to have excess space that space is also used.
EdgeInsets getGymCourtPadding(
  BoxConstraints constraints,
  Gymnasium gymnasium,
) {
  double viewAspectRatio = constraints.maxWidth / constraints.maxHeight;
  if (!viewAspectRatio.isFinite) {
    return EdgeInsets.zero;
  }
  double gridAspectRatio =
      (gymnasium.columns * baseWidth) / (gymnasium.rows * baseHeight);

  double aspectRatioRatio = viewAspectRatio / gridAspectRatio;

  double correctedWidth = baseWidth;
  double correctedHeight = baseHeight;

  if (aspectRatioRatio > 1) {
    correctedWidth *= aspectRatioRatio;
  } else {
    correctedHeight *= (1 / aspectRatioRatio);
  }

  double availableViewWidth = constraints.maxWidth / gymnasium.columns;
  double availableViewHeight = constraints.maxHeight / gymnasium.rows;

  correctedWidth = max(correctedWidth, availableViewWidth);
  correctedHeight = max(correctedHeight, availableViewHeight);

  double horizontalPadding = (correctedWidth - courtWidth) / 2;
  double verticalPadding = (correctedHeight - courtHeight) / 2;

  horizontalPadding = min(horizontalPadding, maxHorizontalPadding);
  verticalPadding = min(verticalPadding, maxVertialPadding);

  EdgeInsets courtPadding = EdgeInsets.symmetric(
    horizontal: horizontalPadding,
    vertical: verticalPadding,
  );

  return courtPadding;
}
