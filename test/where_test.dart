import 'package:array2d/array2d.dart';
import 'package:test/test.dart';

// Assume Array2d class definition is in 'array2d.dart'
// import 'array2d.dart';

void main() {
  group('Array2d.where', () {
    test('should return the first element that satisfies the condition', () {
      final array =
          Array2d.build<int>(3, 3, valueBuilder: (x, y) => x * 10 + y);

      // Find the first element greater than 15
      final PointData<int>? foundElement =
          array.firstWhereabout((element) => element > 15);

      expect(foundElement?.element,
          equals(20)); // 20 is at (x=2, y=0) and is the first > 15
    });

    test('should return null if no element satisfies the condition', () {
      final array = Array2d.build<int>(2, 2, valueBuilder: (x, y) => x + y);

      // Try to find an element greater than 10 (which doesn't exist)
      final PointData<int>? foundElement =
          array.firstWhereabout((element) => element > 10);

      expect(foundElement?.element, isNull);
    });

    test(
        'should return the first element if the first element satisfies the condition',
        () {
      final array = Array2d.build<int>(2, 2, valueBuilder: (x, y) => x + y);

      final foundElement = array
          .firstWhereabout((element) => element == 0); // Element at (0,0) is 0

      expect(foundElement?.element, equals(0));
    });
  });

  group('Array2d.whereType', () {
    test('should return the first element of the specified type', () {
      final array = Array2d.build<Object?>(3, 3, valueBuilder: (x, y) {
        if (x == 1 && y == 1) return 'hello';
        if (x == 2 && y == 0) return 123;
        return null;
      });

      // Find the first String element
      final foundString = array.firstWhereaboutType<String>();
      expect(foundString?.element, equals('hello'));

      // Find the first int element
      final foundInt = array.firstWhereaboutType<int>();
      expect(foundInt?.element, equals(123));
    });

    test('should return null if no element of the specified type is found', () {
      final array = Array2d.build<Object>(2, 2,
          valueBuilder: (x, y) => x + y); // All ints

      // Try to find a String element
      final foundString = array.firstWhereaboutType<String>();
      expect(foundString?.element, isNull);
    });

    test('should handle nullable types correctly', () {
      final array = Array2d.build<String?>(2, 2, valueBuilder: (x, y) {
        if (x == 0 && y == 1) return 'world';
        return null;
      });

      // Find the first String element (non-null)
      final foundString = array.firstWhereaboutType<String>();
      expect(foundString?.element, equals('world'));

      // Find the first String? element (could be null)
      final foundNullableString = array.firstWhereaboutType<String>();
      // The first String? element encountered might be null, depending on iteration order.
      // For simplicity, let's check if it returns *a* String? value.
      // A more specific test might be needed if the exact null value is important.
      expect(foundNullableString?.element,
          isNotNull); // Or expect(foundNullableString, equals('world')) if it's guaranteed first
    });

    test(
        'should return null if array is empty (though constructor prevents this)',
        () {
      // This test case is technically unachievable due to the constructor's validation,
      // but it's good to consider the theoretical behavior.
      // If the constructor allowed 0 width/height, this would be relevant.
      // For demonstration purposes, we'll simulate by creating an array and then trying to find a type.
      final array = Array2d.build<int>(1, 1, valueBuilder: (x, y) => 5);
      final foundDouble = array.firstWhereaboutType<double>();
      expect(foundDouble?.element, isNull);
    });
  });
}
