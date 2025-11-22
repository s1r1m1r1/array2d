import 'package:test/test.dart';
import 'package:array2d/array2d.dart'; // Adjust import to your actual path

// A simple mutable class to test object reference behavior
class BoxedInt {
  int value;
  BoxedInt(this.value);
}

void main() {
  group('Array2d Mutation Tests', () {
    // --- TEST 1: The Correct API Usage ---
    test('setValue updates the internal storage correctly', () {
      final matrix = Array2d<int>(3, 3, valueBuilder: (x, y) => 0);

      // Mutate using the class method
      matrix.setValue(1, 2, 99);

      // Verify
      expect(matrix.elementAt(1, 2), equals(99));
    });

    // --- TEST 3: Mutable Objects (Reference) ---
    test('Mutating properties of objects retrieved via operator[] DOES persist',
        () {
      // Initialize with mutable objects
      final matrix =
          Array2d<BoxedInt>(2, 2, valueBuilder: (x, y) => BoxedInt(0));

      // Access the object via the column accessor
      // logic: matrix[x] returns a list of references.
      // matrix[x][y] returns the reference to the specific BoxedInt.
      matrix.elementAt(0, 1).value = 100;

      // Verify the original matrix holds the updated value
      // This works because we modified the OBJECT, not the ARRAY slot.
      expect(matrix.elementAt(0, 1).value, equals(100));
    });

    // --- TEST 4: Bounds Checking ---
    test('setValue throws RangeError when out of bounds', () {
      final matrix = Array2d<int>(2, 2, valueBuilder: (x, y) => 0);

      expect(() => matrix.setValue(99, 0, 5), throwsRangeError);
      expect(() => matrix.setValue(0, 99, 5), throwsRangeError);
    });
  });
}
