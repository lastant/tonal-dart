import 'dart:math';

import 'package:node_shims/node_shims.dart';

/**
 * [![npm version](https://img.shields.io/npm/v/tonal-array.svg?style=flat-square)](https://www.npmjs.com/package/tonal-array)
 *
 * Tonal array utilities. Create ranges, sort notes, ...
 *
 * @example
 * import * as Array;
 * Array.sort(["f", "a", "c"]) // => ["C", "F", "A"]
 *
 * @example
 * const Array = require("tonal-array")
 * Array.range(1, 4) // => [1, 2, 3, 4]
 *
 *  Array
 */
import "../note/note.dart" show props, name;

// ascending range
ascR(b, n) {
  var a = List.filled(n, 0);
  for (; truthy(n--); a[n] = n + b);
  return a;
}

// descending range
descR(b, n) {
  var a = List.filled(n, 0);
  for (; truthy(n--); a[n] = b - n);
  return a;
}

/**
 * Create a numeric range
 *
 * 
 * 
 * 
 *
 * @example
 * Array.range(-2, 2) // => [-2, -1, 0, 1, 2]
 * Array.range(2, -2) // => [2, 1, 0, -1, -2]
 */
range([a, b]) {
  return a == null || b == null
      ? []
      : a < b ? ascR(a, b - a + 1) : descR(a, a - b + 1);
}

/**
 *
 * Rotates a list a number of times. It"s completly agnostic about the
 * contents of the list.
 *
 * 
 * 
 * 
 * @example
 * Array.rotate(1, [1, 2, 3]) // => [2, 3, 1]
 */
rotate(times, List arr) {
  var len = arr.length;
  var n = ((times % len) + len) % len;
  return arr.getRange(n, len).toList()..addAll(arr.getRange(0, n));
}

/**
 * Return a copy of the array with the null values removed
 * @function
 * 
 * 
 *
 * @example
 * Array.compact(["a", "b", null, "c"]) // => ["a", "b", "c"]
 */
final List Function(List) compact =
    (List arr) => arr.where((n) => n == 0 || truthy(n)).toList();
// a function that get note heights (with negative number for pitch classes)
final height = (name) {
  final m = props(name)['midi'];
  return m != null ? m : props(name + "-100")['midi'];
};
/**
 * Sort an array of notes in ascending order
 *
 * 
 * 
 */
List sort(List src) {
  return compact(src.map(name).toList())..sort((a, b) => height(a) - height(b));
}

/**
 * Get sorted notes with duplicates removed
 *
 * @function
 * 
 */
List unique(List arr) {
  return sort(arr).toSet().toList();
}

/**
 * Randomizes the order of the specified array in-place, using the Fisher–Yates shuffle.
 *
 * @private
 * @function
 * 
 * 
 *
 * @example
 * Array.shuffle(["C", "D", "E", "F"])
 */
var shuffle = (arr, [rnd]) {
  if (rnd == null) rnd = Random().nextDouble;
  var i, t;
  var m = arr.length;
  while (truthy(m)) {
    i = ((rnd() * m--).floor()) | 0;
    t = arr[m];
    arr[m] = arr[i];
    arr[i] = t;
  }
  return arr;
};
/**
 * Get all permutations of an array
 * http://stackoverflow.com/questions/9960908/permutations-in-javascript
 *
 * 
 * 
 */
final List Function(List) permutations = (List arr) {
  if (arr.length == 0) return [[]];
  return permutations(arr.getRange(1, arr.length).toList()).fold([],
      (acc, perm) {
    return concat([
      acc,
      arr.map((e) {
        var newPerm = List.from(perm);
        newPerm.insert(arr.indexOf(e), arr[0]);
        return newPerm;
      })
    ]);
  });
};
