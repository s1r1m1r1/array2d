import 'package:array2d/array2d.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test initializaition', () {
    final array = Array2d.build<bool>(3, 4, valueBuilder: (x, y) => true);
    expect(array.width, 3); // Check number of rows in first row
    expect(array.height, 4); // Check number of rows in first row
    expect(array.elementAt(0, 0), true); // Check default value for elements
  });

  test('test String defaultValue', () {
    final array = Array2d.build<String>(2, 2, valueBuilder: (x, y) => "empty");
    expect(array.elementAt(0, 1), "empty"); // Check custom default value
  });

  test('test modification', () {
    final array = Array2d.build<bool>(3, 2, valueBuilder: (x, y) => true);
    array.setValue(1, 0, false);
    expect(array.elementAt(1, 0), false);
  });

  test('test modification', () {
    final array = Array2d.build<bool>(3, 2, valueBuilder: (x, y) => true);
    array.setValue(1, 0, false);
    expect(array.elementAt(1, 0), false);
  });
}
