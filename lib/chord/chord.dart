import 'package:node_shims/node_shims.dart';

/**
 * [![npm version](https://img.shields.io/npm/v/tonal-chord.svg)](https://www.npmjs.com/package/tonal-chord)
 * [![tonal](https://img.shields.io/badge/tonal-chord-yellow.svg)](https://www.npmjs.com/browse/keyword/tonal)
 *
 * `tonal-chord` is a collection of functions to manipulate musical chords
 *
 * This is part of [tonal](https://www.npmjs.com/package/tonal) music theory library.
 *
 * @example
 * // es6
 * import * as Chord from "tonal-chord"
 * // es5
 * const Chord = require("tonal-chord")
 *
 * @example
 * Chord.notes("CMaj7") // => ["C", "E", "G", "B"]
 *
 *  Chord
 */
import '../note/note.dart' as note;
import '../distance/distance.dart' as distance;
import '../dictionary/dictionary.dart' as dict;
import '../pcset/pcset.dart' as pcset;

/**
 * Return the available chord names
 *
 * @function
 * 
 * 
 *
 * @example
 * Chord.names() // => ["maj7", ...]
 */
final Function names = dict.chord.names;

final NO_CHORD = {
  'name': null,
  'names': [],
  'intervals': [],
  'chroma': null,
  'setnum': null
};

final properties = (name) {
  final intervals = dict.chord.list(name);
  if (falsey(intervals)) return NO_CHORD;
  final s = {"intervals": intervals, "name": name};
  s['chroma'] = pcset.chroma(intervals);
  s['setnum'] = int.parse(s['chroma'], radix: 2);
  s['names'] = dict.chord.names(s['chroma']);
  return s;
};

final memo = ([fn, Map cache]) => ([str]) {
      if (cache == null) cache = {};
      return cache[str] ?? (cache[str] = fn(str));
    };

/**
 * Get chord properties. It returns an object with:
 *
 * - name: the chord name
 * - names: a list with all possible names (includes the current)
 * - intervals: an array with the chord intervals
 * - chroma:  chord croma (see pcset)
 * - setnum: chord chroma number
 *
 * @function
 * 
 * 
 * set to null if not valid chord name
 */
final props = memo(properties);

/**
 * Get chord intervals. It always returns an array
 *
 * @function
 * 
 * 
 */
final intervals = ([name]) => props(tokenize(name)[1])['intervals'];

/**
 * Get the chord notes of a chord. This function accepts either a chord name
 * (for example: "Cmaj7") or a list of notes.
 *
 * It always returns an array, even if the chord is not found.
 *
 * @function
 * 
 * 
 * 
 *
 * @example
 * Chord.notes("Cmaj7") // => ["C", "E", "G", "B"]
 * Chord.notes("C", "maj7") // => ["C", "E", "G", "B"]
 */
notes(nameOrTonic, [name]) {
  if (truthy(name))
    return props(name)['intervals']
        .map(distance.transpose(nameOrTonic))
        .toList();
  final tokenized = tokenize(nameOrTonic);
  final tonic = tokenized[0];
  final type = tokenized[1];
  return props(type)['intervals'].map(distance.transpose(tonic)).toList();
}

/**
 * Check if a given name correspond to a chord in the dictionary
 *
 * @function
 * 
 * 
 * @example
 * Chord.exists("CMaj7") // => true
 * Chord.exists("Maj7") // => true
 * Chord.exists("Ablah") // => false
 */
final exists = (name) => dict.chord.list(tokenize(name)[1]) != null;

/**
 * Get all chords names that are a superset of the given one
 * (has the same notes and at least one more)
 *
 * @function
 * 
 * 
 */
final supersets = (name) {
  if (intervals(name).length == 0) return [];
  var ivls = intervals(name);
  final isSuperset = pcset.isSupersetOf(ivls);
  return dict.chord
      .names()
      .where((name) => isSuperset(dict.chord.list(name)) as bool);
};

/**
 * Find all chords names that are a subset of the given one
 * (has less notes but all from the given chord)
 *
 * @function
 * 
 * 
 */
final subsets = (name) {
  final isSubset = pcset.isSubsetOf(intervals(name));
  return dict.chord
      .names()
      .where((name) => isSubset(dict.chord.list(name)) as bool);
};

// 6, 64, 7, 9, 11 and 13 are consider part of the chord

// (see https://github.com/danigb/tonal/issues/55)
final NUM_TYPES = new RegExp(r'^(6|64|7|9|11|13)$');

/**
 * Tokenize a chord name. It returns an array with the tonic and chord type
 * If not tonic is found, all the name is considered the chord name.
 *
 * This function does NOT check if the chord type exists or not. It only tries
 * to split the tonic and chord type.
 *
 * @function
 * 
 * 
 * @example
 * Chord.tokenize("Cmaj7") // => [ "C", "maj7" ]
 * Chord.tokenize("C7") // => [ "C", "7" ]
 * Chord.tokenize("mMaj7") // => [ "", "mMaj7" ]
 * Chord.tokenize("Cnonsense") // => [ "C", "nonsense" ]
 */
tokenize(name) {
  final p = note.tokenize(name);
  if (p[0] == "") return ["", name];

  // aug is augmented (see https://github.com/danigb/tonal/issues/55)
  if (p[0] == "A" && p[3] == "ug") return ["", "aug"];

  if (NUM_TYPES.hasMatch(p[2])) {
    return [p[0] + p[1], p[2] + p[3]];
  } else {
    return [p[0] + p[1] + p[2], p[3]];
  }
}
