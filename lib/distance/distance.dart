/**
 * [![npm version](https://img.shields.io/npm/v/tonal-distance.svg)](https://www.npmjs.com/package/tonal-distance)
 * [![tonal](https://img.shields.io/badge/tonal-distance-yellow.svg)](https://github.com/danigb/tonal/tree/master/packages/tonal/distance)
 *
 * Transpose notes by intervals and find distances between notes
 *
 * @example
 * // es6
 * import * as Distance from "tonal-distance"
 * Distance.interval("C3", "C4") // => "1P"
 *
 * @example
 * // es6 import selected functions
 * import { interval, semitones, transpose } from "tonal-distance"
 *
 * semitones("C" ,"D") // => 2
 * interval("C4", "G4") // => "5P"
 * transpose("C4", "P5") // => "G4"
 *
 * @example
 * // included in tonal facade
 * const Tonal = require("tonal");
 * Tonal.Distance.transpose("C4", "P5")
 * Tonal.Distance.transposeBy("P5", "C4")
 *
 *  Distance
 */
import "../note/note.dart" as note;
import "../interval/interval.dart" as ivl;
// Map from letter step to number of fifths starting from "C":

// { C: 0, D: 2, E: 4, F: -1, G: 1, A: 3, B: 5 }
final FIFTHS = [0, 2, 4, -1, 1, 3, 5];

// Given a number of fifths, return the octaves they span
final fOcts = (f) => ((f * 7) / 12).floor();

// Get the number of octaves it span each step
final FIFTH_OCTS = FIFTHS.map(fOcts).toList();

final encode = (map) {
  var step = map['step'], alt = map['alt'], oct = map['oct'], dir = map['dir'];
  if (dir == null) dir = 1;

  final f = FIFTHS[step] + 7 * alt;
  if (oct == null) return [dir * f];
  final o = oct - FIFTH_OCTS[step] - 4 * alt;
  return [dir * f, dir * o];
};

// We need to get the steps from fifths
// Fifths for CDEFGAB are [ 0, 2, 4, -1, 1, 3, 5 ]
// We add 1 to fifths to avoid negative numbers, so:
// for ["F", "C", "G", "D", "A", "E", "B"] we have:
final STEPS = [3, 0, 4, 1, 5, 2, 6];

// Return the number of fifths as if it were unaltered
unaltered(f) {
  final i = (f + 1) % 7;
  return i < 0 ? 7 + i : i;
}

final decode = (f, [o, dir]) {
  final step = STEPS[unaltered(f)];
  final alt = ((f + 1) / 7).floor();
  if (o == null) return {"step": step, "alt": alt, "dir": dir};
  final oct = o + 4 * alt + FIFTH_OCTS[step];
  return {"step": step, "alt": alt, "oct": oct, "dir": dir};
};

final memo = ([fn, Map cache]) => ([str]) {
      if (cache == null) cache = {};
      return cache[str] ?? (cache[str] = fn(str));
    };

final encoder = (props) => memo((str) {
      final p = props(str);
      return p['name'] == null ? null : encode(p);
    });

final encodeNote = encoder(note.props);
final encodeIvl = encoder(ivl.props);

/**
 * Transpose a note by an interval. The note can be a pitch class.
 *
 * This function can be partially applied.
 *
 * 
 * 
 * 
 * @example
 * import { tranpose } from "tonal-distance"
 * transpose("d3", "3M") // => "F#3"
 * // it works with pitch classes
 * transpose("D", "3M") // => "F#"
 * // can be partially applied
 * ["C", "D", "E", "F", "G"].map(transpose("M3)) // => ["E", "F#", "G#", "A", "B"]
 */
transpose(_note, [interval]) {
  if (_note == null) return null;
  if (interval == null) return (i) => transpose(_note, i);
  final n = encodeNote(_note);
  final i = encodeIvl(interval);
  if (n == null || i == null) return null;
  final tr = n.length == 1 ? [n[0] + i[0]] : [n[0] + i[0], n[1] + i[1]];
  return note.build(decode(tr[0], tr.length > 1 ? tr[1] : null));
}

/**
 * Transpose a pitch class by a number of perfect fifths.
 *
 * It can be partially applied.
 *
 * @function
 * 
 * 
 * 
 *
 * @example
 * import { trFifths } from "tonal-transpose"
 * [0, 1, 2, 3, 4].map(trFifths("C")) // => ["C", "G", "D", "A", "E"]
 * // or using tonal
 * Distance.trFifths("G4", 1) // => "D"
 */
trFifths(_note, [fifths]) {
  if (fifths == null) return (f) => trFifths(_note, f);
  final n = encodeNote(_note);
  if (n == null) return null;
  return note.build(decode(n[0] + fifths));
}

/**
 * Get the distance in fifths between pitch classes
 *
 * Can be partially applied.
 *
 * 
 * 
 */
fifths(from, to) {
  if (to == null) return (to) => fifths(from, to);
  final f = encodeNote(from);
  final t = encodeNote(to);
  if (t == null || f == null) return null;
  return t[0] - f[0];
}

/**
 * The same as transpose with the arguments inverted.
 *
 * Can be partially applied.
 *
 * 
 * 
 * 
 * @example
 * import { tranposeBy } from "tonal-distance"
 * transposeBy("3m", "5P") // => "7m"
 */
transposeBy(interval, [note]) {
  if (note == null) return (n) => transpose(n, interval);
  return transpose(note, interval);
}

final isDescending = (e) => e[0] * 7 + e[1] * 12 < 0;
final decodeIvl =
    (i) => isDescending(i) ? decode(-i[0], -i[1], -1) : decode(i[0], i[1], 1);

addIntervals(ivl1, ivl2, dir) {
  final i1 = encodeIvl(ivl1);
  final i2 = encodeIvl(ivl2);
  if (i1 == null || i2 == null) return null;
  final i = [i1[0] + dir * i2[0], i1[1] + dir * i2[1]];
  return ivl.build(decodeIvl(i));
}

/**
 * Add two intervals
 *
 * Can be partially applied.
 *
 * 
 * 
 * 
 * @example
 * import { add } from "tonal-distance"
 * add("3m", "5P") // => "7m"
 */
add(ivl1, [ivl2]) {
  if (ivl2 == null) return (i2) => add(ivl1, i2);
  return addIntervals(ivl1, ivl2, 1);
}

/**
 * Subtract two intervals
 *
 * Can be partially applied
 *
 * 
 * 
 * 
 */
subtract(ivl1, ivl2) {
  if (ivl2 == null) return (i2) => add(ivl1, i2);
  return addIntervals(ivl1, ivl2, -1);
}

/**
 * Find the interval between two pitches. It works with pitch classes
 * (both must be pitch classes and the interval is always ascending)
 *
 * Can be partially applied
 *
 * 
 * 
 * 
 *
 * @example
 * import { interval } from "tonal-distance"
 * interval("C2", "C3") // => "P8"
 * interval("G", "B") // => "M3"
 *
 * @example
 * import * as Distance from "tonal-distance"
 * Distance.interval("M2", "P5") // => "P4"
 */
interval(from, [to]) {
  if (to == null) return (t) => interval(from, t);
  final f = encodeNote(from);
  final t = encodeNote(to);
  if (f == null || t == null || f.length != t.length) return null;
  final d = f.length == 1
      ? [t[0] - f[0], -(((t[0] - f[0]) * 7) / 12).floor()]
      : [t[0] - f[0], t[1] - f[1]];
  return ivl.build(decodeIvl(d));
}

/**
 * Get the distance between two notes in semitones
 *
 * 
 * 
 * 
 * @example
 * import { semitones } from "tonal-distance"
 * semitones("C3", "A2") // => -3
 * // or use tonal
 * Tonal.Distance.semitones("C3", "G3") // => 7
 */
semitones(from, [to]) {
  if (to == null) return (t) => semitones(from, t);
  final f = note.props(from);
  final t = note.props(to);
  return f['midi'] != null && t['midi'] != null
      ? t['midi'] - f['midi']
      : f['chroma'] != null && t['chroma'] != null
          ? (t['chroma'] - f['chroma'] + 12) % 12
          : null;
}
