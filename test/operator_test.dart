import 'package:array2d/array2d.dart';
import 'package:test/test.dart';

void main() {
  group('Array2d Operators and toString', () {
    test('operator [] access works', () {
      final array = Array2d<String>(2, 2, valueBuilder: (x, y) => '$x,$y');
      expect(array[0][0], equals('0,0'));
      expect(array[1][1], equals('1,1'));
    });

    test('operator []= modification works', () {
      final array = Array2d<int>(2, 2, valueBuilder: (x, y) => 0);
      array[0][0] = 10;
      expect(array[0][0], equals(10));
      expect(array.elementAt(0, 0), equals(10));
    });

    test('operator [] throws RangeError for invalid column', () {
      final array = Array2d<int>(2, 2, valueBuilder: (x, y) => 0);
      expect(() => array[2], throwsA(isA<RangeError>()));
      expect(() => array[-1], throwsA(isA<RangeError>()));
    });

    test('operator [] throws RangeError for invalid row', () {
      final array = Array2d<int>(2, 2, valueBuilder: (x, y) => 0);
      expect(() => array[0][2], throwsA(isA<RangeError>()));
      expect(() => array[0][-1], throwsA(isA<RangeError>()));
    });

    test('toString returns correct format', () {
      final array = Array2d<int>(2, 2, valueBuilder: (x, y) => x + y);
      // 0, 1
      // 1, 2
      // Note: toString iterates y then x (rows then columns)
      // Row 0: (0,0)=0, (1,0)=1
      // Row 1: (0,1)=1, (1,1)=2
      final expected = '0, 1\n1, 2\n';
      expect(array.toString(), equals(expected));
    });
  });
}
