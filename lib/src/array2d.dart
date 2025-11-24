import 'package:array2d/src/point_data.dart';

/// Represents a fixed-size two-dimensional array stored internally as a
/// single one-dimensional array using a Column-Major mapping scheme.
///
/// Provides methods for accessing, modifying, and iterating over elements
/// using x (column) and y (row) coordinates.
class Array2d<T> {
  /// The underlying 1D array storage.
  late final List<T> array;

  /// Private storage for the dimensions.
  final int _width;
  final int _height;

  /// A function that builds the initial value for each cell in the array.
  /// Takes the x (column) and y (row) coordinates as arguments.
  final T Function(int x, int y) valueBuilder;

  /// Creates a new [Array2d] with the specified width (columns) and height (rows).
  ///
  /// The [valueBuilder] function is used to initialize each element of the array.
  /// Throws an [ArgumentError] if width or height are not positive.
  Array2d(int width, int height, {required this.valueBuilder})
      : _width = width,
        _height = height {
    if (width <= 0 || height <= 0) {
      throw ArgumentError("Width and height must be positive integers.");
    }

    final totalSize = width * height;

    // Initialize the single 1D array
    array = List<T>.generate(totalSize, (k) {
      // Map 1D index k back to 2D coordinates (x, y) for the builder
      // k = x * height + y (Column-Major indexing)
      final x = k ~/ height; // Integer division gives the column index
      final y = k % height; // Modulo gives the row index
      return valueBuilder(x, y);
    }, growable: false);
  }

  /// Helper to convert 2D coordinates (x, y) into a 1D array index (k).
  /// Uses Column-Major ordering: k = x * height + y.
  int _to1DIndex(int x, int y) {
    return x * _height + y;
  }

  /// The width (number of columns) of the 2D array.
  int get width => _width;

  /// The height (number of rows) of the 2D array.
  int get height => _height;

  /// Returns the total number of elements in the 2D array.
  int get length => array.length;

  void setValue(int x, int y, T value) {
    if (x < 0 || x >= _width || y < 0 || y >= _height) {
      throw RangeError(
          "Index out of bounds: x=$x, y=$y, width=$width, height=$height");
    }
    array[_to1DIndex(x, y)] = value;
  }

  /// Gets the value at the specified x (column) and y (row) coordinates.
  ///
  /// Throws a [RangeError] if the coordinates are out of bounds.
  T elementAt(int x, int y) {
    if (x < 0 || x >= _width || y < 0 || y >= _height) {
      throw RangeError(
          "Index out of bounds: x=$x, y=$y, width=$width, height=$height");
    }
    return array[_to1DIndex(x, y)];
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        buffer.write(array[_to1DIndex(x, y)]);
        if (x < _width - 1) {
          buffer.write(', ');
        }
      }
      buffer.writeln();
    }
    return buffer.toString();
  }

  /// Returns the first element in the 2D array for which the provided test function returns true,
  /// along with its coordinates.
  ///
  /// If no element matches, returns null.
  PointData<T>? firstWhereabout(bool Function(T element) test) {
    for (int x = 0; x < _width; x++) {
      for (int y = 0; y < _height; y++) {
        final element = array[_to1DIndex(x, y)];
        if (test(element)) {
          return PointData(element, x, y);
        }
      }
    }
    return null;
  }

  /// Returns the first element in the 2D array that is of the specified type `R`,
  /// along with its coordinates.
  ///
  /// If no element matches, returns null.
  PointData<R>? firstWhereaboutType<R>() {
    for (int x = 0; x < _width; x++) {
      for (int y = 0; y < _height; y++) {
        final element = array[_to1DIndex(x, y)];
        if (element is R) {
          // Cast is safe due to the check
          return PointData<R>(element as R, x, y);
        }
      }
    }
    return null;
  }

  /// Returns a list of all elements in the 2D array for which the provided test function returns true,
  /// each wrapped with its coordinates.
  List<PointData<T>> whereabout(bool Function(T element) test) {
    final data = <PointData<T>>[];
    for (int x = 0; x < _width; x++) {
      for (int y = 0; y < _height; y++) {
        final element = array[_to1DIndex(x, y)];
        if (test(element)) {
          data.add(PointData<T>(element, x, y));
        }
      }
    }
    return data;
  }

  /// Returns a list of all elements that are of the specified type `R`, optionally filtered by a test function.
  List<PointData<R>> whereaboutType<R>(bool Function(R element)? test) {
    final data = <PointData<R>>[];
    for (int x = 0; x < _width; x++) {
      for (int y = 0; y < _height; y++) {
        final element = array[_to1DIndex(x, y)];
        if (element is R) {
          // Cast to R is safe due to the check
          final rElement = element as R;
          if (test == null || test(rElement)) {
            data.add(PointData<R>(rElement, x, y));
          }
        }
      }
    }
    return data;
  }

  /// Provides safe, nullable access to the element at the specified x and y coordinates.
  ///
  /// If the coordinates are out of bounds, returns `null`.
  T? elementAtOrNull(int x, int y) {
    if (x >= 0 && x < _width && y >= 0 && y < _height) {
      return array[_to1DIndex(x, y)];
    }
    return null;
  }
}
