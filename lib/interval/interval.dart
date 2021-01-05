import 'dart:core';
import 'dart:core' as core;
import 'package:node_shims/node_shims.dart';

/**
 * [![npm version](https://img.shields.io/npm/v/tonal-interval.svg)](https://www.npmjs.com/package/tonal-interval)
 * [![tonal](https://img.shields.io/badge/tonal-interval-yellow.svg)](https://www.npmjs.com/browse/keyword/tonal)
 *
 * `tonal-interval` is a collection of functions to create and manipulate music intervals.
 *
 * The intervals are strings in shorthand notation. Two variations are supported:
 *
 * - standard shorthand notation: type and number, for example: "M3", "d-4"
 * - inverse shorthand notation: number and then type, for example: "3M", "-4d"
 *
 * The problem with the standard shorthand notation is that some strings can be
 * parsed as notes or intervals, for example: "A4" can be note A in 4th octave
 * or an augmented four. To remove ambiguity, the prefered notation in tonal is the
 * inverse shortand notation.
 *
 * This is part of [tonal](https://www.npmjs.com/package/tonal) music theory library.
 *
 * ## Usage
 *
 * ```js
 * // es6
 * import * as Interval from "tonal-interval"
 * // es5
 * const Interval = require("tonal-interval")
 * // part of tonal
 * import { Interval } from "tonal"
 *
 * Interval.semitones("4P") // => 5
 * Interval.invert("3m") // => "6M"
 * Interval.simplify("9m") // => "2m"
 * ```
 *
 * ## Install
 *
 * [![npm install tonal-interval](https://nodei.co/npm/tonal-interval.png?mini=true)](https://npmjs.org/package/tonal-interval/)
 *
 * ## API Documentation
 *
 *  Interval
 */

// shorthand tonal notation (with quality after number)
const IVL_TNL = "([-+]?\\d+)(d{1,4}|m|M|P|A{1,4})";
// standard shorthand notation (with quality before number)
const IVL_STR = "(AA|A|P|M|m|d|dd)([-+]?\\d+)";
final REGEX = new RegExp("^" + IVL_TNL + "|" + IVL_STR + "\$");
final SIZES = [0, 2, 4, 5, 7, 9, 11];
const TYPES = "PMMPPMM";
final CLASSES = [0, 1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1];
final NAMES = "1P 2m 2M 3m 3M 4P 5P 6m 6M 7m 7M 8P".split(" ");

/**
 * List basic (perfect, major, minor) interval names within a octave
 * 
 * 
 * @example
 * Interval.names() // => [ "1P", "2m", "2M", "3m", "3M", "4P", "5P", "6m", "6M", "7m", "7M", "8P" ]
 * Interval.names("P") // => [ "1P", "4P", "5P", "8P" ]
 * Interval.names("PM") // => [ "1P", "2M", "3M", "4P", "5P", "6M", "7M", "8P" ]
 * Interval.names("Pm") // => [ "1P", "2m", "3m", "4P", "5P", "6m", "7m", "8P" ]
 * Interval.names("d") // => []
 */
final names = ([types]) => types is! String
    ? List.from(NAMES)
    : NAMES.where((n) => types.indexOf(n[1]) != -1);

final tokenize = ([str]) {
  final m = REGEX.firstMatch('$str');
  if (m == null) return null;
  return (truthy(m.group(1))
      ? [m.group(1), m.group(2)]
      : [m.group(4), m.group(3)]);
};

final NO_IVL = {
  'name': null,
  'num': null,
  'q': null,
  'step': null,
  'alt': null,
  'dir': null,
  'type': null,
  'simple': null,
  'semitones': null,
  'chroma': null,
  'oct': null
};

final fillStr = (String s, n) => List.filled(n.abs() + 1, '').join(s);

// export for tests only
final qToAlt = (String type, [String q]) {
  if (q == null) return null;
  if (q == "M" && type == "M") return 0;
  if (q == "P" && type == "P") return 0;
  if (q == "m" && type == "M") return -1;
  if (new RegExp(r'^A+$').hasMatch(q)) return q.length;
  if (new RegExp(r'^d+$').hasMatch(q))
    return type == "P" ? -q.length : -q.length - 1;
  return null;
};

// export for tests only
final altToQ = (String type, [alt]) {
  if (alt == null) return null;
  if (alt == 0)
    return type == "M" ? "M" : "P";
  else if (alt == -1 && type == "M")
    return "m";
  else if (alt > 0)
    return fillStr("A", alt);
  else if (alt < 0)
    return fillStr("d", type == "P" ? alt : alt + 1);
  else
    return null;
};

final numToStep = (n) => (n.abs() - 1) % 7;

final properties = ([String str]) {
  final t = tokenize(str);
  if (t == null) return NO_IVL;
  final p = {
    'num': 0,
    'q': "d",
    'name': "",
    'type': "M",
    'step': 0,
    'dir': -1,
    'simple': 1,
    'alt': 0,
    'oct': 0,
    'semitones': 0,
    'chroma': 0,
    'ic': 0
  };
  p['num'] = int.parse(t[0].toString());
  p['q'] = t[1];
  p['step'] = numToStep(p['num']);
  p['type'] = TYPES[p['step']];
  if (p['type'] == "M" && p['q'] == "P") return NO_IVL;
  p['name'] = "" + p['num'].toString() + p['q'];
  p['dir'] = (p['num'] as int) < 0 ? -1 : 1;
  p['simple'] = (p['num'] == 8 || p['num'] == -8
      ? p['num']
      : (p['dir'] as int) * ((p['step'] as int) + 1));
  p['alt'] = qToAlt(p['type'], p['q']);
  p['oct'] = (((p['num'] as int).abs() - 1) / 7).floor();
  p['semitones'] =
      (p['dir'] as int) * (SIZES[p['step']] + p['alt'] + 12 * p['oct']);
  p['chroma'] =
      ((((p['dir'] as int) * (SIZES[p['step']] + p['alt'])) % 12) + 12) % 12;
  return p;
};

final cache = {};
/**
 * Get interval properties. It returns an object with:
 *
 * - name: name
 * - num: number
 * - q: quality
 * - step: step
 * - alt: alteration
 * - dir: direction (1 ascending, -1 descending)
 * - type: "P" or "M" for perfectable or majorable
 * - simple: the simplified number
 * - semitones: the size in semitones
 * - chroma: the interval chroma
 * - ic: the interval class
 *
 * @function
 * 
 * 
 */
props([String str]) {
  if (str is! String) return NO_IVL;
  return cache[str] ?? (cache[str] = properties(str));
}

/**
 * Get the number of the interval
 *
 * @function
 * 
 * 
 * @example
 * Interval.num("m2") // => 2
 * Interval.num("P9") // => 9
 * Interval.num("P-4") // => -4
 */
final num = (str) => props(str)['num'];
/**
 * Get interval name. Can be used to test if it"s an interval. It accepts intervals
 * as pitch or string in shorthand notation or tonal notation. It returns always
 * intervals in tonal notation.
 *
 * @function
 * 
 * 
 * @example
 * Interval.name("m-3") // => "-3m"
 * Interval.name("3") // => null
 */
final name = ([str]) => str is String ? props(str)['name'] : null;
/**
 * Get size in semitones of an interval
 *
 * @function
 * 
 * 
 * @example
 * import { semitones } from "tonal-interval"
 * semitones("P4") // => 5
 * // or using tonal
 * Tonal.Interval.semitones("P5") // => 7
 */
final semitones = (str) => props(str)['semitones'];
/**
 * Get the chroma of the interval. The chroma is a number between 0 and 7
 * that represents the position within an octave (pitch set)
 *
 * @function
 * 
 * 
 */
final chroma = (str) => props(str)['chroma'];
/**
 * Get the [interval class](https://en.wikipedia.org/wiki/Interval_class)
 * number of a given interval.
 *
 * In musical set theory, an interval class is the shortest distance in
 * pitch class space between two unordered pitch classes
 *
 * @function
 * 
 * 
 *
 * @example
 * Interval.ic("P8") // => 0
 * Interval.ic("m6") // => 4
 * Interval.ic(10) // => 2
 * ["P1", "M2", "M3", "P4", "P5", "M6", "M7"].map(ic) // => [0, 2, 4, 5, 5, 3, 1]
 */
final ic = ([ivl]) {
  if (ivl is String) ivl = props(ivl)['chroma'];
  return ivl is core.num ? CLASSES[ivl % 12] : null;
};
/**
 * Given a interval property object, get the interval name
 *
 * The properties must contain a `num` *or* `step`, and `alt`:
 *
 * - num: the interval number
 * - step: the interval step (overrides the num property)
 * - alt: the interval alteration
 * - oct: (Optional) the number of octaves
 * - dir: (Optional) the direction
 *
 * @function
 * 
 *
 * 
 * @example
 * Interval.build({ step: 1, alt: -1, oct: 0, dir: 1 }) // => "1d"
 * Interval.build({ num: 9, alt: -1 }) // => "9m"
 */
final build = ([map]) {
  if (map == null) return null;
  var num = map['num'],
      step = map['step'],
      alt = map['alt'],
      oct = map['oct'],
      dir = map['dir'];
  if (oct == null) oct = 1;

  if (step != null) num = step + 1 + 7 * oct;
  if (num == null) return null;
  if (alt is! core.num) return null;
  final d = dir is! core.num ? "" : dir < 0 ? "-" : "";
  // const d = dir < 0 ? "-" : "";
  final type = TYPES[numToStep(num)];
  return (d + num.toString() + altToQ(type, alt));
};

/**
 * Get the simplified version of an interval.
 *
 * @function
 * 
 * 
 *
 * @example
 * Interval.simplify("9M") // => "2M"
 * ["8P", "9M", "10M", "11P", "12P", "13M", "14M", "15P"].map(Interval.simplify)
 * // => [ "8P", "2M", "3M", "4P", "5P", "6M", "7M", "8P" ]
 * Interval.simplify("2M") // => "2M"
 * Interval.simplify("-2M") // => "7m"
 */
final simplify = (str) {
  final p = props(str);
  if (p == NO_IVL) return null;
  final intervalProps = p;
  return intervalProps['simple'].toString() + intervalProps['q'];
};

/**
 * Get the inversion (https://en.wikipedia.org/wiki/Inversion_(music)#Intervals)
 * of an interval.
 *
 * @function
 * 
 * notation or interval array notation
 * 
 *
 * @example
 * Interval.invert("3m") // => "6M"
 * Interval.invert("2M") // => "7m"
 */
final invert = (str) {
  final p = props(str);
  if (p == NO_IVL) return null;
  final intervalProps = p;
  final step = (7 - intervalProps['step']) % 7;
  final alt = intervalProps['type'] == "P"
      ? -intervalProps['alt']
      : -(intervalProps['alt'] + 1);
  return build({
    "step": step,
    "alt": alt,
    "oct": intervalProps['oct'],
    "dir": intervalProps['dir']
  });
};

// interval numbers
var IN = [1, 2, 2, 3, 3, 4, 5, 5, 6, 6, 7, 7];
// interval qualities
var IQ = "P m M m M P d P m M m M".split(" ");

/**
 * Get interval name from semitones number. Since there are several interval
 * names for the same number, the name it"s arbitraty, but deterministic.
 *
 * @function
 * 
 * 
 * @example
 * import { fromSemitones } from "tonal-interval"
 * fromSemitones(7) // => "5P"
 * // or using tonal
 * Tonal.Distance.fromSemitones(-7) // => "-5P"
 */
final fromSemitones = (core.num num) {
  var d = num < 0 ? -1 : 1;
  var n = num.abs();
  var c = n % 12;
  var o = (n / 12).floor();
  return (d * (IN[c] + 7 * o)).toString() + IQ[c];
};
