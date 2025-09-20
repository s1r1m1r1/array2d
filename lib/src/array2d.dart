import 'package:array2d/src/point_data.dart';

/// Represents a fixed-size two-dimensional array.
///
/// Provides methods for accessing, modifying, and iterating over elements
/// in the 2D array using x and y coordinates.  The array is initialized
/// using a `valueBuilder` function which provides the initial value for each cell.
class Array2d<T> {
  /// The underlying 2D array.
  late final List<List<T>> array;

  /// A function that builds the initial value for each cell in the array.
  /// Takes the x and y coordinates as arguments.
  final T Function(int x, int y) valueBuilder;

  /// Creates a new [Array2d] with the specified width and height.
  ///
  /// The [valueBuilder] function is used to initialize each element of the array.
  /// It is called with the x and y coordinates of each cell.
  /// Throws an [ArgumentError] if width or height are not positive.
  Array2d(int width, int height, {required this.valueBuilder}) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError("Width and height must be positive integers.");
    }
    array = List.generate(
        width, (x) => List.generate(height, (y) => valueBuilder(x, y)),
        growable: false);
  }

  /// Accesses the row at the given x-coordinate.
  ///  array2d[x][y]
  ///
  List<T> operator [](int y) => array[y];

  /// The width of the 2D array.
  int get width => array.length;

  /// The height of the 2D array.
  /// height is always positive and greater than 0
  int get height => array[0].length;

  /// Returns the first row of the 2D array.
  get first => array.first;

  /// Returns the number of rows (width) of the array.  (Same as [width])
  get length => array.length;

  /// Sets the value at the specified x and y coordinates.
  ///
  /// Throws a [RangeError] if the coordinates are out of bounds.
  void setValue(int x, int y, T value) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      array[x][y] = value;
    } else {
      throw RangeError(
          "Index out of bounds: x=$x, y=$y, width=$width, height=$height");
    }
  }

  /// Gets the value at the specified x and y coordinates.
  ///
  /// Throws a [RangeError] if the coordinates are out of bounds.
  T getValue(int x, int y) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      return array[x][y];
    } else {
      throw RangeError(
          "Index out of bounds: x=$x, y=$y, width=$width, height=$height");
    }
  }

  /// Iterates over each element in the 2D array and calls the provided function.
  void forEach(void Function(T value, int x, int y) action) {
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        action(array[x][y], x, y);
      }
    }
  }

  /// Iterates over each row in the 2D array and calls the provided function.
  void forEachRow(void Function(List<T> row, int x) action) {
    for (int x = 0; x < width; x++) {
      action(array[x], x);
    }
  }

  /// Iterates over each column in the 2D array and calls the provided function.
  void forEachColumn(void Function(List<T> column, int y) action) {
    for (int y = 0; y < height; y++) {
      List<T> column = [];
      for (int x = 0; x < width; x++) {
        column.add(array[x][y]);
      }
      action(column, y);
    }
  }

  /// Returns the first element in the 2D array for which the provided test function returns true.
  ///
  /// If no element matches, returns null.
  PointData<T>? firstWhereabout(bool Function(T element) test) {
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        T element = array[x][y];
        if (test(element)) {
          return PointData(element, x, y);
        }
      }
    }
    return null;
  }

  /// Returns the first element in the 2D array that is of the specified type `R`.
  ///
  /// If no element matches, returns null.
  PointData<R>? firstWhereaboutType<R>() {
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        var element = array[x][y];
        if (element is R) {
          return PointData(element, x, y);
        }
      }
    }
    return null;
  }

  // Add this method to your Array2d class
  List<PointData<T>> whereabout(bool Function(T element) test) {
    final data = <PointData<T>>[];
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        T element = array[x][y];
        if (test(element)) {
          data.add(PointData<T>(element, x, y));
        }
      }
    }
    return data;
  }

  List<PointData<R>> whereaboutType<R>(bool Function(R element)? test) {
    final data = <PointData<R>>[];
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        T element = array[x][y];
        if (element is R) {
          if (test == null) {
            data.add(PointData<R>(element, x, y));
          } else if (test(element)) {
            data.add(PointData<R>(element, x, y));
          }
        }
      }
    }
    return data;
  }
}
