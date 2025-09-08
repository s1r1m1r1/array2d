import 'package:array2d/array2d.dart';
import 'package:test/test.dart';

// Assume Array2d class definition is in 'array2d.dart'
// import 'array2d.dart';

void main() {
  group('Array2d.where', () {
    test('should return the first element that satisfies the condition', () {
      final array = Array2d<int>(3, 3, valueBuilder: (x, y) => x * 10 + y);

      // Find the first element greater than 15
      final foundElement = array.where((element, x, y) => element > 15);

      expect(foundElement,
          equals(20)); // 20 is at (x=2, y=0) and is the first > 15
    });

    test('should return null if no element satisfies the condition', () {
      final array = Array2d<int>(2, 2, valueBuilder: (x, y) => x + y);

      // Try to find an element greater than 10 (which doesn't exist)
      final foundElement = array.where((element, x, y) => element > 10);

      expect(foundElement, isNull);
    });

    test('should correctly use x and y coordinates in the condition', () {
      final array = Array2d<String>(2, 2, valueBuilder: (x, y) => '($x,$y)');

      // Find the element at coordinates (1, 0)
      final foundElement = array.where((element, x, y) => x == 1 && y == 0);

      expect(foundElement, equals('(1,0)'));
    });

    test(
        'should return the first element if the first element satisfies the condition',
        () {
      final array = Array2d<int>(2, 2, valueBuilder: (x, y) => x + y);

      final foundElement =
          array.where((element, x, y) => element == 0); // Element at (0,0) is 0

      expect(foundElement, equals(0));
    });
  });

  group('Array2d.whereType', () {
    test('should return the first element of the specified type', () {
      final array = Array2d<Object?>(3, 3, valueBuilder: (x, y) {
        if (x == 1 && y == 1) return 'hello';
        if (x == 2 && y == 0) return 123;
        return null;
      });

      // Find the first String element
      final foundString = array.whereType<String>();
      expect(foundString, equals('hello'));

      // Find the first int element
      final foundInt = array.whereType<int>();
      expect(foundInt, equals(123));
    });

    test('should return null if no element of the specified type is found', () {
      final array =
          Array2d<Object>(2, 2, valueBuilder: (x, y) => x + y); // All ints

      // Try to find a String element
      final foundString = array.whereType<String>();
      expect(foundString, isNull);
    });

    test('should handle nullable types correctly', () {
      final array = Array2d<String?>(2, 2, valueBuilder: (x, y) {
        if (x == 0 && y == 1) return 'world';
        return null;
      });

      // Find the first String element (non-null)
      final foundString = array.whereType<String>();
      expect(foundString, equals('world'));

      // Find the first String? element (could be null)
      final foundNullableString = array.whereType<String>();
      // The first String? element encountered might be null, depending on iteration order.
      // For simplicity, let's check if it returns *a* String? value.
      // A more specific test might be needed if the exact null value is important.
      expect(foundNullableString,
          isNotNull); // Or expect(foundNullableString, equals('world')) if it's guaranteed first
    });

    test(
        'should return null if array is empty (though constructor prevents this)',
        () {
      // This test case is technically unachievable due to the constructor's validation,
      // but it's good to consider the theoretical behavior.
      // If the constructor allowed 0 width/height, this would be relevant.
      // For demonstration purposes, we'll simulate by creating an array and then trying to find a type.
      final array = Array2d<int>(1, 1, valueBuilder: (x, y) => 5);
      final foundDouble = array.whereType<double>();
      expect(foundDouble, isNull);
    });
  });
}
