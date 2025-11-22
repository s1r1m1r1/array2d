import 'package:array2d/array2d.dart';

/// A view of a specific column that redirects writes back to the parent Array2d.
class ColumnView<T> {
  final Array2d<T> _parent;
  final int _x;

  ColumnView(this._parent, this._x);

  /// Gets the value at row [y].
  T operator [](int y) => _parent.getValue(_x, y);

  /// Sets the value at row [y], modifying the original Array2d.
  void operator []=(int y, T value) => _parent.setValue(_x, y, value);

  /// Optional: Allows you to check the height of the column
  int get length => _parent.height;
}
