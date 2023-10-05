import 'dart:ui';

/// Returns a copy of [size] with one of its dimensions extended so that it has
/// the same aspect ratio as the [reference].
///
/// If one of the aspect ratios is infinite or 0 the [size] is returned
/// as it is.
Size alignAspectRatios(
  Size reference,
  Size size,
) {
  double referenceRatio = reference.aspectRatio;
  double sizeAspectRatio = size.aspectRatio;
  if (!referenceRatio.isFinite ||
      !sizeAspectRatio.isFinite ||
      referenceRatio == 0 ||
      sizeAspectRatio == 0) {
    return size;
  }

  double aspectRatioRatio = referenceRatio / sizeAspectRatio;

  double alignedWidth = size.width;
  double alignedHeight = size.height;

  if (aspectRatioRatio > 1) {
    // Reference is wider than size
    alignedWidth *= aspectRatioRatio;
  } else {
    // Reference is taller than size
    alignedHeight *= (1 / aspectRatioRatio);
  }

  return Size(alignedWidth, alignedHeight);
}
