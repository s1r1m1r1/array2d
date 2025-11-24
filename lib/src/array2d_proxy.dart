part of 'array2d.dart';

/// A helper class to enable `array[x][y]` syntax.
/// Represents a column in the 2D array (since x is the column index).
class Array2dColumn<T> {
  final Array2d<T> _array;
  final int _x;

  Array2dColumn(this._array, this._x);

  /// Gets the value at the specified y (row) coordinate.
  T operator [](int y) {
    return _array[_x][y];
  }

  /// Sets the value at the specified y (row) coordinate.
  void operator []=(int y, T value) {
    _array[_x][y] = value;
  }
}
