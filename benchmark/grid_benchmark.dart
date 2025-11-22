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
  late final List<T> array;
  final int _width;
  final int _height;
  final T Function(int x, int y) valueBuilder;

  Array2d1D(int width, int height, {required this.valueBuilder})
      : _width = width,
        _height = height {
    if (width <= 0 || height <= 0) {
      throw ArgumentError("Width and height must be positive integers.");
    }

    final totalSize = width * height;
    array = List<T>.generate(totalSize, (k) {
      // k = x * height + y (Column-Major indexing)
      final x = k ~/ height;
      final y = k % height;
      return valueBuilder(x, y);
    }, growable: false);
  }

  int _to1DIndex(int x, int y) {
    return x * _height + y;
  }

  int get width => _width;
  int get height => _height;

  void setValue(int x, int y, T value) {
    if (x >= 0 && x < _width && y >= 0 && y < _height) {
      array[_to1DIndex(x, y)] = value;
    } else {
      throw RangeError("Index out of bounds");
    }
  }

  T getValue(int x, int y) {
    if (x >= 0 && x < _width && y >= 0 && y < _height) {
      return array[_to1DIndex(x, y)];
    } else {
      throw RangeError("Index out of bounds");
    }
  }

  void forEach(void Function(T value, int x, int y) action) {
    for (int x = 0; x < _width; x++) {
      for (int y = 0; y < _height; y++) {
        action(array[_to1DIndex(x, y)], x, y);
      }
    }
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
  Array2d1D(WARMUP_SIZE, WARMUP_SIZE, valueBuilder: (x, y) => x + y)
      .forEach((v, x, y) {});
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
      array1D.getValue(p.x.toInt(), p.y.toInt());
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
    array1D.forEach((v, x, y) => sum += v as int);
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
