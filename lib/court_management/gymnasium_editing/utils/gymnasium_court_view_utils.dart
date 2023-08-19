import 'dart:math';

import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/court_management/court_editing/view/court_slot.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

const double courtWidth = 134 * 3;
const double courtHeight = 61 * 3;

const double _baseHorizontalPadding = 22;
const double _baseVerticalPadding = 15;

const double _baseWidth = courtWidth + _baseHorizontalPadding * 2;
const double _baseHeight = courtHeight + _baseVerticalPadding * 2;

const double _maxHorizontalPadding = courtWidth * 0.5;
const double _maxVertialPadding = courtHeight * 0.75;

const double _relativeBoundaryMargin = 0.14;

/// Calculates the padding of the [CourtSlot] widgets inside the
/// gymnasium court view.
///
/// If possible within the max padding values, it pads the courts such that the
/// court grid has the same aspect ratio as the constraints of the view.
/// If the view is large enough to have excess space that space is also used.
EdgeInsets getGymCourtPadding(
  BoxConstraints constraints,
  Gymnasium gymnasium,
) {
  double viewAspectRatio = constraints.biggest.aspectRatio;
  if (!viewAspectRatio.isFinite) {
    return EdgeInsets.zero;
  }
  double gridAspectRatio =
      (gymnasium.columns * _baseWidth) / (gymnasium.rows * _baseHeight);

  double aspectRatioRatio = viewAspectRatio / gridAspectRatio;

  double correctedWidth = _baseWidth;
  double correctedHeight = _baseHeight;

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

  horizontalPadding = min(horizontalPadding, _maxHorizontalPadding);
  verticalPadding = min(verticalPadding, _maxVertialPadding);

  EdgeInsets courtPadding = EdgeInsets.symmetric(
    horizontal: horizontalPadding,
    vertical: verticalPadding,
  );

  return courtPadding;
}

/// Calculates the boundary margins of the gymnasium court view.
///
/// It pads the court grid such that it has the same aspect ratio as the
/// constraints of the view. This ensures that the view fully fills the
/// constraints when zoomed all the way out.
EdgeInsets getGymBoundaryMargin(
  BoxConstraints constraints,
  Gymnasium gymnasium,
) {
  double horizontalMargin = constraints.maxWidth * _relativeBoundaryMargin;
  double verticalMargin = constraints.maxHeight * _relativeBoundaryMargin;

  Size gymSize = getGymSize(
    constraints,
    gymnasium,
    withPadding: true,
  );

  Size baseBoundarySize =
      gymSize + Offset(horizontalMargin * 2, verticalMargin * 2);

  double viewAspectRatio = constraints.biggest.aspectRatio;
  if (!viewAspectRatio.isFinite) {
    return EdgeInsets.zero;
  }
  double boundaryAspectRatio = baseBoundarySize.aspectRatio;

  double aspectRatioRatio = viewAspectRatio / boundaryAspectRatio;

  double correctedWidth = baseBoundarySize.width;
  double correctedHeight = baseBoundarySize.height;

  if (aspectRatioRatio > 1) {
    correctedWidth *= aspectRatioRatio;
  } else {
    correctedHeight *= (1 / aspectRatioRatio);
  }

  horizontalMargin = (correctedWidth - gymSize.width) / 2;
  verticalMargin = (correctedHeight - gymSize.height) / 2;

  return EdgeInsets.symmetric(
    horizontal: horizontalMargin,
    vertical: verticalMargin,
  );
}

Size getGymSize(
  BoxConstraints constraints,
  Gymnasium gymnasium, {
  bool withPadding = false,
  bool withBoundaryMargin = false,
}) {
  Size size = Size(
    courtWidth * gymnasium.columns,
    courtHeight * gymnasium.rows,
  );

  if (withPadding) {
    EdgeInsets courtPadding = getGymCourtPadding(constraints, gymnasium);
    size += Offset(
      courtPadding.horizontal * gymnasium.columns,
      courtPadding.vertical * gymnasium.rows,
    );
  }

  if (withBoundaryMargin) {
    EdgeInsets boundaryMargin = getGymBoundaryMargin(constraints, gymnasium);
    size += Offset(
      boundaryMargin.horizontal,
      boundaryMargin.vertical,
    );
  }

  return size;
}
