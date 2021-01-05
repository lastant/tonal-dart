import 'dart:math';
import 'package:node_shims/node_shims.dart';

/**
 * [![npm version](https://img.shields.io/npm/v/tonal-scale.svg?style=flat-square)](https://www.npmjs.com/package/tonal-scale)
 *
 * A scale is a collection of pitches in ascending or descending order.
 *
 * This module provides functions to get and manipulate scales.
 *
 * @example
 * // es6
 * import * as Scale from "tonal-scale"
 * // es5
 * const Scale = require("tonal-scale");
 *
 * @example
 * Scale.notes("Ab bebop") // => [ "Ab", "Bb", "C", "Db", "Eb", "F", "Gb", "G" ]
 * Scale.names() => ["major", "minor", ...]
 *  Scale
 */
import '../note/note.dart' as note;
import '../pcset/pcset.dart' as pcset;
import '../distance/distance.dart' as distance;
import '../dictionary/dictionary.dart' as dictionary;
import '../array/array.dart' as array;

final NO_SCALE = {
  'name': null,
  'intervals': [],
  'names': [],
  'chroma': null,
  'setnum': null
};

final properties = (name) {
  final intervals = dictionary.scale.list(name);
  if (falsey(intervals)) return NO_SCALE;
  final s = {"intervals": intervals, "name": name};
  s['chroma'] = pcset.chroma(intervals);
  s['setnum'] = int.parse(s['chroma'], radix: 2);
  s['names'] = dictionary.scale.names(s['chroma']);
  return s;
};

final memoize = ([fn, Map cache]) => ([str]) {
      if (cache == null) cache = {};
      return cache[str] ?? (cache[str] = fn(str));
    };

/**
 * Get scale properties. It returns an object with:
 * - name: the scale name
 * - names: a list with all possible names (includes the current)
 * - intervals: an array with the scale intervals
 * - chroma:  scale croma (see pcset)
 * - setnum: scale chroma number
 *
 * @function
 * 
 * 
 */
final props = memoize(properties, {});

/**
 * Return the available scale names
 *
 * @function
 * 
 * 
 *
 * @example
 * Scale.names() // => ["maj7", ...]
 */
final Function names = dictionary.scale.names;

/**
 * Given a scale name, return its intervals. The name can be the type and
 * optionally the tonic (which is ignored)
 *
 * It retruns an empty array when no scale found
 *
 * @function
 * 
 * 
 * array if no scale found
 * @example
 * Scale.intervals("major") // => [ "1P", "2M", "3M", "4P", "5P", "6M", "7M" ]
 */
final intervals = (name) {
  final p = tokenize(name);
  return props(p[1])['intervals'];
};

/**
 * Get the notes (pitch classes) of a scale.
 *
 * Note that it always returns an array, and the values are only pitch classes.
 *
 * @function
 * 
 * 
 * 
 * 
 *
 * @example
 * Scale.notes("C", "major") // => [ "C", "D", "E", "F", "G", "A", "B" ]
 * Scale.notes("C major") // => [ "C", "D", "E", "F", "G", "A", "B" ]
 * Scale.notes("C4", "major") // => [ "C", "D", "E", "F", "G", "A", "B" ]
 * Scale.notes("A4", "no-scale") // => []
 * Scale.notes("blah", "major") // => []
 */
notes(nameOrTonic, [name]) {
  final p = tokenize(nameOrTonic);
  name = name ?? p[1];
  return intervals(name).map(distance.transpose(p[0])).toList();
}

/**
 * Check if the given name is a known scale from the scales dictionary
 *
 * @function
 * 
 * 
 */
exists(name) {
  final p = tokenize(name);
  return dictionary.scale.list(p[1]) != null;
}

/**
 * Given a string with a scale name and (optionally) a tonic, split
 * that components.
 *
 * It retuns an array with the form [ name, tonic ] where tonic can be a
 * note name or null and name can be any arbitrary string
 * (this function doesn"t check if that scale name exists)
 *
 * @function
 * 
 * 
 * @example
 * Scale.tokenize("C mixolydean") // => ["C", "mixolydean"]
 * Scale.tokenize("anything is valid") // => ["", "anything is valid"]
 * Scale.tokenize() // => ["", ""]
 */
tokenize([str]) {
  if (str is! String) return ["", ""];
  final i = str.indexOf(" ");
  final tonic =
      note.name(i > 0 ? str.substring(0, i) : '') ?? note.name(str) ?? "";
  final name =
      tonic != "" ? str.substring(min<int>(tonic.length + 1, str.length)) : str;
  return [tonic, name.length > 0 ? name : ""];
}

/**
 * Find mode names of a scale
 *
 * @function
 * 
 * @example
 * Scale.modeNames("C pentatonic") // => [
 *   ["C", "major pentatonic"],
 *   ["D", "egyptian"],
 *   ["E", "malkos raga"],
 *   ["G", "ritusen"],
 *   ["A", "minor pentatonic"]
 * ]
 */
final modeNames = (name) {
  final ivls = intervals(name);
  final tonics = notes(name);

  return pcset
      .modes(ivls)
      .asMap()
      .entries
      .map((entry) {
        final chroma = entry.value;
        final i = entry.key;
        final names = dictionary.scale.names(chroma);
        final name = names.length > 0 ? names[0] : null;
        if (truthy(name)) return [tonics[i] ?? ivls[i], name];
      })
      .where((x) => truthy(x))
      .toList();
};
/**
 * Get all chords that fits a given scale
 *
 * @function
 * 
 * 
 *
 * @example
 * Scale.chords("pentatonic") // => ["5", "64", "M", "M6", "Madd9", "Msus2"]
 */
final chords = (name) {
  final inScale = pcset.isSubsetOf(intervals(name));
  return dictionary.chord
      .names()
      .where((name) => inScale(dictionary.chord.list(name)) as bool)
      .toList();
};

/**
 * Given an array of notes, return the scale: a pitch class set starting from
 * the first note of the array
 *
 * @function
 * 
 * 
 * @example
 * Scale.toScale(['C4', 'c3', 'C5', 'C4', 'c4']) // => ["C"]
 * Scale.toScale(['D4', 'c#5', 'A5', 'F#6']) // => ["D", "F#", "A", "C#"]
 */
final toScale = (notes) {
  final pcset = array.compact(notes.map(note.pc).toList());
  if (pcset.length == 0) return pcset;
  final tonic = pcset[0];
  final scale = array.unique(pcset);
  return array.rotate(scale.indexOf(tonic), scale);
};

/**
 * Get all scales names that are a superset of the given one
 * (has the same notes and at least one more)
 *
 * @function
 * 
 * 
 * @example
 * Scale.supersets("major") // => ["bebop", "bebop dominant", "bebop major", "chromatic", "ichikosucho"]
 */
final supersets = (name) {
  if (intervals(name).length == 0) return [];
  final isSuperset = pcset.isSupersetOf(intervals(name));
  return dictionary.scale
      .names()
      .where((name) => isSuperset(dictionary.scale.list(name)) as bool);
};

/**
 * Find all scales names that are a subset of the given one
 * (has less notes but all from the given scale)
 *
 * @function
 * 
 * 
 *
 * @example
 * Scale.subsets("major") // => ["ionian pentatonic", "major pentatonic", "ritusen"]
 */
final subsets = (name) {
  final isSubset = pcset.isSubsetOf(intervals(name));
  return dictionary.scale
      .names()
      .where((name) => isSubset(dictionary.scale.list(name)) as bool);
};
