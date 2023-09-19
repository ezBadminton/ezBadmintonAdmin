import 'dart:math';

/// Returns the power of two that is immediately bigger than or equal to
/// [from].
int nextPowerOfTwo(int from) {
  int nextPowerOfTwo = 1;
  while (nextPowerOfTwo < from) {
    nextPowerOfTwo *= 2;
  }

  return nextPowerOfTwo;
}

/// Returns a power of two that is immediately smaller than
/// or equal to [from].
///
/// Only works with [from] >= 1
int previousPowerOfTwo(int from) {
  int shifts = 0;
  while (from > 1) {
    from >>= 1;
    shifts += 1;
  }

  return pow(2, shifts) as int;
}
