/**
 * [![npm version](https://img.shields.io/npm/v/tonal-pcset.svg?style=flat-square)](https://www.npmjs.com/package/tonal-pcset)
 * [![tonal](https://img.shields.io/badge/tonal-pcset-yellow.svg?style=flat-square)](https://www.npmjs.com/browse/keyword/tonal)
 *
 * `tonal-pcset` is a collection of functions to work with pitch class sets, oriented
 * to make comparations (isEqual, isSubset, isSuperset)
 *
 * This is part of [tonal](https://www.npmjs.com/package/tonal) music theory library.
 *
 * You can install via npm: `npm i --save tonal-pcset`
 *
 * ```js
 * // es6
 * import PcSet from "tonal-pcset"
 * var PcSet = require("tonal-pcset")
 *
 * PcSet.isEqual("c2 d5 e6", "c6 e3 d1") // => true
 * ```
 *
 * ## API documentation
 *
 *  PcSet
 */
import '../note/note.dart' as note;
import '../interval/interval.dart' as ivl;
import '../array/array.dart' as array;

final chr = (str) => note.chroma(str) ?? ivl.chroma(str) ?? 0;
final pcsetNum = (set) => int.parse(chroma(set), radix: 2);
final clen = (String chroma) => chroma.replaceAll(new RegExp(r'0'), "").length;

/**
 * Get chroma of a pitch class set. A chroma identifies each set uniquely.
 * It"s a 12-digit binary each presenting one semitone of the octave.
 *
 * Note that this function accepts a chroma as parameter and return it
 * without modification.
 *
 * 
 * 
 * @example
 * PcSet.chroma(["C", "D", "E"]) // => "1010100000000"
 */
String chroma(set) {
  if (isChroma(set)) return set;
  if (set is! List) return "";
  var b = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  set.map(chr).forEach((i) {
    b[i] = 1;
  });
  return b.join("");
}

var all = null;
/**
 * Get a list of all possible chromas (all possible scales)
 * More information: http://allthescales.org/
 * 
 *
 */
chromas([n]) {
  all = all ??
      array.range(2048, 4095).map((int n) => n.toRadixString(2)).toList();
  return n is num ? all.where((chroma) => clen(chroma) == n) : List.from(all);
}

/**
 * Given a a list of notes or a pcset chroma, produce the rotations
 * of the chroma discarding the ones that starts with "0"
 *
 * This is used, for example, to get all the modes of a scale.
 *
 * 
 * 
 * the rotations that starts with "0"
 * 
 *
 * @example
 * PcSet.modes(["C", "D", "E"]).map(PcSet.intervals)
 */
modes(set, [normalize]) {
  normalize = normalize != false;
  var binary = chroma(set).split("");
  return array.compact(binary.asMap().entries.map((entry) {
    int i = entry.key;
    var r = array.rotate(i, binary);
    return normalize && r[0] == "0" ? null : r.join("");
  }).toList());
}

var REGEX = new RegExp(r'^[01]{12}$');
/**
 * Test if the given string is a pitch class set chroma.
 * 
 * 
 * @example
 * PcSet.isChroma("101010101010") // => true
 * PcSet.isChroma("101001") // => false
 */
isChroma(set) {
  return set is String && REGEX.hasMatch(set);
}

var IVLS = "1P 2m 2M 3m 3M 4P 5d 5P 6m 6M 7m 7M".split(" ");
/**
 * Given a pcset (notes or chroma) return it"s intervals
 * 
 * 
 * @example
 * PcSet.intervals("1010100000000") => ["1P", "2M", "3M"]
 */
intervals(String set) {
  if (!isChroma(set)) return [];
  return array.compact(set.split("").asMap().entries.map((entry) {
    var d = entry.value, i = entry.key;
    return d == "1" ? IVLS[i] : null;
  }).toList());
}

/**
 * Test if two pitch class sets are identical
 *
 * 
 * 
 * 
 * @example
 * PcSet.isEqual(["c2", "d3"], ["c5", "d2"]) // => true
 */
isEqual(s1, s2) {
  if (s2 == null) return (s) => isEqual(s1, s);
  return chroma(s1) == chroma(s2);
}

/**
 * Create a function that test if a collection of notes is a
 * subset of a given set
 *
 * The function can be partially applied
 *
 * 
 * 
 * 
 * @example
 * const inCMajor = PcSet.isSubsetOf(["C", "E", "G"])
 * inCMajor(["e6", "c4"]) // => true
 * inCMajor(["e6", "c4", "d3"]) // => false
 */
isSubsetOf(set, [notes]) {
  if (notes != null) return isSubsetOf(set)(notes);
  set = pcsetNum(set);
  bool Function(dynamic) isSubset = (notes) {
    notes = pcsetNum(notes);
    return notes != set && ((notes as int) & (set as int)) == notes;
  };
  return isSubset;
}

/**
 * Create a function that test if a collectio of notes is a
 * superset of a given set (it contains all notes and at least one more)
 *
 * 
 * 
 * 
 * @example
 * const extendsCMajor = PcSet.isSupersetOf(["C", "E", "G"])
 * extendsCMajor(["e6", "a", "c4", "g2"]) // => true
 * extendsCMajor(["c6", "e4", "g3"]) // => false
 */
isSupersetOf(set, [notes]) {
  if (notes != null) return isSupersetOf(set)(notes);
  set = pcsetNum(set);
  return (notes) {
    notes = pcsetNum(notes);
    return notes != set && ((notes as int) | (set as int)) == notes;
  };
}

/**
 * Test if a given pitch class set includes a note
 * 
 * 
 * 
 * @example
 * PcSet.includes(["C", "D", "E"], "C4") // => true
 * PcSet.includes(["C", "D", "E"], "C#4") // => false
 */
includes(set, [note]) {
  if (note != null) return includes(set)(note);
  set = chroma(set);
  return (note) {
    return set[chr(note)] == "1";
  };
}

/**
 * Filter a list with a pitch class set
 *
 * 
 * 
 * 
 *
 * @example
 * PcSet.filter(["C", "D", "E"], ["c2", "c#2", "d2", "c3", "c#3", "d3"]) // => [ "c2", "d2", "c3", "d3" ])
 * PcSet.filter(["C2"], ["c2", "c#2", "d2", "c3", "c#3", "d3"]) // => [ "c2", "c3" ])
 */
filter(set, notes) {
  if (notes == null) return (n) => filter(set, n);
  return notes.where(includes(set)).toList();
}
