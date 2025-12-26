import 'package:array2d/array2d.dart';

abstract class IArray2d<T> {
  final int width;
  final int height;
  IArray2d(this.width, this.height, {required this.valueBuilder});

  /// A function that builds the initial value for each cell in the array.
  /// Takes the x (column) and y (row) coordinates as arguments.
  final T Function(int x, int y) valueBuilder;

  void setValue(int x, int y, T value);
  T elementAt(int x, int y);

  PointData<T>? firstWhereabout(bool Function(T element) test);

  PointData<R>? firstWhereaboutType<R>();

  /// Returns a list of all elements in the 2D array for which the provided test function returns true,
  /// each wrapped with its coordinates.
  List<PointData<T>> whereabout(bool Function(T element) test);
  List<PointData<R>> whereaboutType<R>(bool Function(R element)? test);

  T? elementAtOrNull(int x, int y);
}
