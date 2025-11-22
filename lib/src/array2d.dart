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

  /// Accesses the column at the given x-coordinate (List<T>).
  ///
  /// Note: This operation creates a new List from the contiguous slice
  /// of the 1D array, which is efficient under Column-Major ordering.
  List<T> operator [](int x) {
    if (x >= 0 && x < _width) {
      final startIndex = _to1DIndex(x, 0);
      // The column is stored contiguously from startIndex to startIndex + _height - 1
      return array.sublist(startIndex, startIndex + _height);
    }
    throw RangeError("Column index $x out of bounds for width $_width");
  }

  /// The width (number of columns) of the 2D array.
  int get width => _width;

  /// The height (number of rows) of the 2D array.
  int get height => _height;

  /// Returns the total number of elements in the 2D array.
  int get length => array.length;

  /// Sets the value at the specified x (column) and y (row) coordinates.
  ///
  /// Throws a [RangeError] if the coordinates are out of bounds.
  void setValue(int x, int y, T value) {
    if (x >= 0 && x < _width && y >= 0 && y < _height) {
      array[_to1DIndex(x, y)] = value;
    } else {
      throw RangeError(
          "Index out of bounds: x=$x, y=$y, width=$width, height=$height");
    }
  }

  /// Gets the value at the specified x (column) and y (row) coordinates.
  ///
  /// Throws a [RangeError] if the coordinates are out of bounds.
  T getValue(int x, int y) {
    if (x >= 0 && x < _width && y >= 0 && y < _height) {
      return array[_to1DIndex(x, y)];
    } else {
      throw RangeError(
          "Index out of bounds: x=$x, y=$y, width=$width, height=$height");
    }
  }

  /// Iterates over each element in the 2D array and calls the provided function.
  void forEach(void Function(T value, int x, int y) action) {
    for (int x = 0; x < _width; x++) {
      for (int y = 0; y < _height; y++) {
        action(array[_to1DIndex(x, y)], x, y);
      }
    }
  }

  /// Iterates over each row in the 2D array and calls the provided function.
  void forEachRow(void Function(List<T> row, int y) action) {
    for (int y = 0; y < _height; y++) {
      List<T> row = [];
      for (int x = 0; x < _width; x++) {
        // Elements in a row are NOT contiguous in the 1D array.
        row.add(array[_to1DIndex(x, y)]);
      }
      action(row, y);
    }
  }

  /// Iterates over each column in the 2D array and calls the provided function.
  void forEachColumn(void Function(List<T> column, int x) action) {
    for (int x = 0; x < _width; x++) {
      // Elements in a column ARE contiguous (Column-Major order)
      final startIndex = _to1DIndex(x, 0);
      // Create a sublist view for the column
      final column = array.sublist(startIndex, startIndex + _height);
      action(column, x);
    }
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
          return PointData(element as R, x, y);
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

  /// Provides safe, nullable access to the column (List<T>) at the given x-coordinate.
  ///
  /// If the x-coordinate is out of bounds, returns `null`.
  List<T>? getColumnOrNull(int x) {
    if (x >= 0 && x < _width) {
      final startIndex = _to1DIndex(x, 0);
      return array.sublist(startIndex, startIndex + _height);
    }
    return null;
  }

  /// Provides safe, nullable access to the element at the specified x and y coordinates.
  ///
  /// If the coordinates are out of bounds, returns `null`.
  T? getValueOrNull(int x, int y) {
    if (x >= 0 && x < _width && y >= 0 && y < _height) {
      return array[_to1DIndex(x, y)];
    }
    return null;
  }
}
