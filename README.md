A 2D array implementation tailored for game development.

## Features
* [List key features, e.g., Efficient element access, Support for specific data types (int, float, etc.), Bounds checking for safety,  Customizable size]

## Usage
``` dart
void main(){
final array2d = Array2D<String>(10,10,valueBuilder: (x,y)=> "x:$x, y:$y");
print(array2d[0][0]);
print(array2d[10][10]);
array2d[10][10] = "new value";
print(array2d[10][10]);
}

```


