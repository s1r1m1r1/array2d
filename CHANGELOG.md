## 2.3.0
elementAt(x,y) instead getter [x][y]
setValue(x,y,value) instead setter [x][y]

## 2.2.0
 removed forEachRow , forEachColumn

## 2.1.0
Restored Mutable Indexing & Performance Optimization

FIX: Restored support for the intuitive assignment syntax array[x][y] = value.

Technical Detail: The operator [] now returns a lightweight ColumnView proxy instead of a List copy. This allows modifications to propagate directly to the internal storage without overhead.

PERFORMANCE: Retained the internal flat-array architecture introduced in 2.0.0.


# 2.0.0
Performance & Refactoring

BREAKING CHANGE (Internal Access): Refactored the internal storage of Array2d<T> from List<List<T>> to a single List<T> (1D array).

Benefit: This change significantly improves read/write performance and iteration speed by leveraging memory cache locality, as confirmed by benchmarks (up to 1.39x faster for random lookups).

Implementation: Now uses Column-Major indexing (k = x * height + y) to map 2D coordinates to the 1D index.

Fixes & API Consistency

Assignment Operator Fix: The indexed assignment operator (array[x][y] = value) is no longer supported for modifying elements in the 1D-backed structure.

The operator [] method now returns a copy (List<T>) of the column data, making direct modification via indices ineffective.

Action Required: Users must use the dedicated methods for writing and reading:

Set Value: Use array.setValue(x, y, value)

Get Value: Use array.getValue(x, y)

## 1.5.0
  * added getRowOrNull and getValueOrNull methods

## 1.4.0
  added whereabout methods
## 1.3.0
  -

## 1.2.0
* added where and whereType 

## 1.1.0
* remove resize width and height

## 1.0.1
* fix readme

## 1.0.0
* array2d release

