import 'package:array2d/src/grid_array2d.dart';
import 'package:array2d/src/i_array2d.dart';
import 'package:array2d/src/line_array2d.dart';

/// Represents a fixed-size two-dimensional array stored internally as a
/// single one-dimensional array using a Column-Major mapping scheme.
///
/// Provides methods for accessing, modifying, and iterating over elements
/// using x (column) and y (row) coordinates.
abstract class Array2d {
  static int effectiveSize = 1000;
  static IArray2d<T> build<T>(int width, int height,
      {required T Function(int x, int y) valueBuilder}) {
    final size = width * height;
    if (size > effectiveSize) {
      return LineArray2d<T>(width, height, valueBuilder: valueBuilder)
          as IArray2d<T>;
    }
    return GridArray2d<T>(width, height, valueBuilder: valueBuilder)
        as IArray2d<T>;
  }
}
