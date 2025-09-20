import 'package:array2d/array2d.dart';
import 'package:test/test.dart';

void main() {
  group('Array2d', () {
    // A simple builder function for testing
    int valueBuilder(int x, int y) => x * 10 + y;

    // Test case for constructor with valid dimensions
    test('Constructor creates a valid array with positive dimensions', () {
      final array = Array2d<int>(3, 4, valueBuilder: valueBuilder);
      expect(array.width, equals(3));
      expect(array.height, equals(4));
    });

    // Test case for constructor with invalid dimensions (zero or negative)
    test('Constructor throws ArgumentError for non-positive dimensions', () {
      expect(() => Array2d<int>(0, 5, valueBuilder: valueBuilder),
          throwsA(isA<ArgumentError>()));
      expect(() => Array2d<int>(5, 0, valueBuilder: valueBuilder),
          throwsA(isA<ArgumentError>()));
      expect(() => Array2d<int>(-1, 5, valueBuilder: valueBuilder),
          throwsA(isA<ArgumentError>()));
      expect(() => Array2d<int>(5, -1, valueBuilder: valueBuilder),
          throwsA(isA<ArgumentError>()));
    });

    // Test case for getting and setting values
    test('getValue and setValue work correctly', () {
      final array = Array2d<String>(2, 2, valueBuilder: (x, y) => '($x,$y)');
      expect(array.getValue(0, 0), equals('(0,0)'));
      array.setValue(0, 0, 'new_value');
      expect(array.getValue(0, 0), equals('new_value'));
    });

    // Test for out-of-bounds access
    test('getValue and setValue throw RangeError for out-of-bounds access', () {
      final array = Array2d<int>(2, 2, valueBuilder: (x, y) => 0);
      expect(() => array.getValue(2, 0), throwsA(isA<RangeError>()));
      expect(() => array.getValue(0, 2), throwsA(isA<RangeError>()));
      expect(() => array.setValue(2, 0, 1), throwsA(isA<RangeError>()));
      expect(() => array.setValue(0, 2, 1), throwsA(isA<RangeError>()));
    });

    // Test for the `forEach` method
    test('forEach iterates through all elements', () {
      final array = Array2d<int>(2, 3, valueBuilder: valueBuilder);
      final visited = <int>[];
      array.forEach((value, x, y) {
        visited.add(value);
      });
      expect(visited, equals([0, 1, 2, 10, 11, 12]));
    });

    // Test for the `where` method
    test('where returns the first matching element', () {
      final array = Array2d<int>(3, 3, valueBuilder: valueBuilder);
      final PointData<int>? result = array.firstWhereabout((
        element,
      ) =>
          element == 11);
      expect(result?.element, equals(11));
    });
  });
  // Test `where` returns null
}
