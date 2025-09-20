import 'dart:math';

/// A simple class to hold an element and its coordinates.
class PointData<T> extends Point<int> {
  final T element;
  PointData(this.element, super.x, super.y);
}
