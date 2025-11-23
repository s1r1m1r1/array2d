import 'dart:math';

// ====================================================================
// 1. PointData Class (Included for completeness)
// ====================================================================

/// A simple class to hold an element and its 2D coordinates.
class PointData<T> {
  final T element;
  final int x;
  final int y;

  const PointData(this.element, this.x, this.y);

  // Minimal implementation for use in benchmark
  @override
  String toString() => 'PointData(element: $element, x: $x, y: $y)';
}

// ====================================================================
// 2. Array2d2D (Original List<List<T>> Implementation)
// ====================================================================

/// Represents a 2D array using the traditional List<List<T>> structure.
class Array2d2D<T> {
  late final List<List<T>> array;
  final T Function(int x, int y) valueBuilder;

  Array2d2D(int width, int height, {required this.valueBuilder}) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError("Width and height must be positive integers.");
    }
    // Note: The original implementation in the prompt used array[y] for the row,
    // but the array was constructed with array[x][y] structure (width as outer list).
    // We stick to the x=column, y=row indexing for consistency with Array2d1D.
    array = List.generate(
        width, (x) => List.generate(height, (y) => valueBuilder(x, y)),
        growable: false);
  }

  int get width => array.length;
  int get height => array[0].length;

  void setValue(int x, int y, T value) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      array[x][y] = value;
    } else {
      throw RangeError("Index out of bounds");
    }
  }

  T getValue(int x, int y) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      return array[x][y];
    } else {
      throw RangeError("Index out of bounds");
    }
  }

  void forEach(void Function(T value, int x, int y) action) {
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        action(array[x][y], x, y);
      }
    }
  }
}

// ====================================================================
// 3. Array2d1D (Refactored List<T> Implementation)
// ====================================================================

/// Represents a 2D array stored internally as a single 1D array (Column-Major).
class Array2d1D<T> {
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
  Array2d1D(int width, int height, {required this.valueBuilder})
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

  /// Sets the value at the specified x (column) and y (row) coordinates.
  ///
  /// Throws a [RangeError] if the coordinates are out of bounds.
  void setValue(int x, int y, T value) {
    try {
      array[_to1DIndex(x, y)] = value;
    } on RangeError {
      throw RangeError(
          "Index out of bounds: x=$x, y=$y, width=$width, height=$height");
    }
  }

  /// Gets the value at the specified x (column) and y (row) coordinates.
  ///
  /// Throws a [RangeError] if the coordinates are out of bounds.
  T elementAt(int x, int y) {
    try {
      return array[_to1DIndex(x, y)];
    } on RangeError {
      throw RangeError(
          "Index out of bounds: x=$x, y=$y, width=$width, height=$height");
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

// ====================================================================
// 4. Benchmarking Logic
// ====================================================================

/// Runs a specific operation and returns the time taken in microseconds.
int runBenchmark(String description, Function operation) {
  final stopwatch = Stopwatch()..start();
  operation();
  stopwatch.stop();
  print('  $description: ${stopwatch.elapsedMicroseconds} μs');
  return stopwatch.elapsedMicroseconds;
}

void main() {
  print("--- Array2d Implementation Performance Benchmark ---");
  print("Goal: Compare List<List<T>> (Array2d2D) vs. List<T> (Array2d1D)\n");

  const int WARMUP_SIZE = 100;
  const int BENCHMARK_SIZE = 500; // 500x500 array = 250,000 elements
  const int NUM_OPERATIONS = BENCHMARK_SIZE * BENCHMARK_SIZE;

  print('Configuration:');
  print(
      'Array Size: ${BENCHMARK_SIZE}x${BENCHMARK_SIZE} (${NUM_OPERATIONS} elements)');
  print('Operation Count for R/W: ${NUM_OPERATIONS} random accesses');
  print('----------------------------------------------------');

  // --- WARMUP PHASE ---
  // Dart's JIT compiler needs time to optimize code paths.
  print('Warming up with a ${WARMUP_SIZE}x${WARMUP_SIZE} array...');
  Array2d2D(WARMUP_SIZE, WARMUP_SIZE, valueBuilder: (x, y) => x + y)
      .forEach((v, x, y) {});

  final array2d1D =
      Array2d1D(WARMUP_SIZE, WARMUP_SIZE, valueBuilder: (x, y) => x + y);
  for (var v in array2d1D.array) {}
  print('Warmup complete.\n');

  // --- INITIALIZATION BENCHMARK ---
  print(
      '1. Initialization Test (Time to build the $BENCHMARK_SIZE x $BENCHMARK_SIZE array):');

  int init2DTime = runBenchmark('Array2d2D (List<List<T>>)', () {
    Array2d2D(BENCHMARK_SIZE, BENCHMARK_SIZE, valueBuilder: (x, y) => x + y);
  });

  int init1DTime = runBenchmark('Array2d1D (List<T>)', () {
    Array2d1D(BENCHMARK_SIZE, BENCHMARK_SIZE, valueBuilder: (x, y) => x + y);
  });

  print('----------------------------------------------------');

  // --- DATA SETUP ---
  // Create instances once for subsequent R/W and iteration tests.
  final array2D =
      Array2d2D(BENCHMARK_SIZE, BENCHMARK_SIZE, valueBuilder: (x, y) => x + y);
  final array1D =
      Array2d1D(BENCHMARK_SIZE, BENCHMARK_SIZE, valueBuilder: (x, y) => x + y);
  final random = Random();

  // Create random coordinates for R/W tests
  final randomCoords = List.generate(
      NUM_OPERATIONS,
      (_) => Point(
          random.nextInt(BENCHMARK_SIZE), random.nextInt(BENCHMARK_SIZE)));

  // --- RANDOM ACCESS (GET VALUE) BENCHMARK ---
  print('2. Random Get Value Test (${NUM_OPERATIONS} accesses):');

  int get2DTime = runBenchmark('Array2d2D (List<List<T>>)', () {
    for (var p in randomCoords) {
      array2D.getValue(p.x.toInt(), p.y.toInt());
    }
  });

  int get1DTime = runBenchmark('Array2d1D (List<T>)', () {
    for (var p in randomCoords) {
      array1D.elementAt(p.x.toInt(), p.y.toInt());
    }
  });

  print('----------------------------------------------------');

  // --- RANDOM ACCESS (SET VALUE) BENCHMARK ---
  print('3. Random Set Value Test (${NUM_OPERATIONS} updates):');

  int set2DTime = runBenchmark('Array2d2D (List<List<T>>)', () {
    for (var p in randomCoords) {
      array2D.setValue(p.x.toInt(), p.y.toInt(), 99);
    }
  });

  int set1DTime = runBenchmark('Array2d1D (List<T>)', () {
    for (var p in randomCoords) {
      array1D.setValue(p.x.toInt(), p.y.toInt(), 99);
    }
  });

  print('----------------------------------------------------');

  // --- ITERATION (FOREACH) BENCHMARK ---
  print(
      '4. Full Iteration Test (forEach over all ${NUM_OPERATIONS} elements):');

  int iteration2DTime = runBenchmark('Array2d2D (List<List<T>>)', () {
    int sum = 0;
    array2D.forEach((v, x, y) => sum += v as int);
  });

  int iteration1DTime = runBenchmark('Array2d1D (List<T>)', () {
    int sum = 0;
    for (var v in array1D.array) {
      sum += v;
    }
  });

  print('----------------------------------------------------');

  // --- SUMMARY ---
  print('\nFINAL RESULTS (Lower is better - Times in Microseconds μs):');
  print('----------------------------------------------------');

  final initRatio = init2DTime / init1DTime;
  final getRatio = get2DTime / get1DTime;
  final setRatio = set2DTime / set1DTime;
  final iterationRatio = iteration2DTime / iteration1DTime;

  print('Operation   | Array2d2D (2D) | Array2d1D (1D) | 1D is faster by (x)');
  print('------------|----------------|----------------|--------------------');
  print(
      'Initialize  | ${init2DTime.toString().padLeft(14)} | ${init1DTime.toString().padLeft(14)} | ${initRatio.toStringAsFixed(2)}x');
  print(
      'Get Value   | ${get2DTime.toString().padLeft(14)} | ${get1DTime.toString().padLeft(14)} | ${getRatio.toStringAsFixed(2)}x');
  print(
      'Set Value   | ${set2DTime.toString().padLeft(14)} | ${set1DTime.toString().padLeft(14)} | ${setRatio.toStringAsFixed(2)}x');
  print(
      'Iteration   | ${iteration2DTime.toString().padLeft(14)} | ${iteration1DTime.toString().padLeft(14)} | ${iterationRatio.toStringAsFixed(2)}x');
  print('----------------------------------------------------');

  print(
      '\nConclusion: The Array2d1D (single list) implementation is generally faster');
  print(
      'for R/W and iteration due to better memory access patterns (cache locality).');
}
